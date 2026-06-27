import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quran/quran.dart' as quran_pkg;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:werdi/core/audio/audio_playback.dart';
import 'package:werdi/core/audio/voice_recorder_service.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/core/services/reciter_preferences.dart';
import 'package:werdi/features/quran/domain/models/quran_audio_reciter.dart';
import 'package:werdi/features/quran/domain/repositories/quran_repository.dart';
import 'package:werdi/features/tasmee3/domain/models/ayah_range.dart';
import 'package:werdi/features/tasmee3/domain/models/tasmee3_result.dart';
import 'package:werdi/features/tasmee3/domain/models/tasmee3_session.dart';
import 'package:werdi/features/tasmee3/domain/repositories/tasmee3_repository.dart';
import 'package:werdi/features/tasmee3/presentation/cubit/tasmee3_state.dart';
import 'package:werdi/shared/repositories/audio_repository.dart';

class Tasmee3Cubit extends Cubit<Tasmee3State> {
  Tasmee3Cubit({
    required Tasmee3Repository repository,
    required QuranRepository quranRepository,
    required AudioRepository audioRepository,
    required AppPreferences preferences,
  })  : _repository = repository,
        _quranRepository = quranRepository,
        _audio = audioRepository,
        _preferences = preferences,
        super(const Tasmee3State()) {
    _userRecordingSubscription = _userRecordingPlayer.playerStateStream.listen(
      (playerState) {
        if (playerState.processingState == ProcessingState.completed &&
            !playerState.playing) {
          if (state.isPlayingUserRecording) {
            emit(state.copyWith(isPlayingUserRecording: false));
          }
        }
      },
    );
  }

  final Tasmee3Repository _repository;
  final QuranRepository _quranRepository;
  final AudioRepository _audio;
  final AppPreferences _preferences;
  final stt.SpeechToText _speech = stt.SpeechToText();
  final VoiceRecorderService _voiceRecorder = VoiceRecorderService();
  final AudioPlayer _userRecordingPlayer = AudioPlayer();
  StreamSubscription<PlayerState>? _userRecordingSubscription;
  bool _speechInitialized = false;
  bool _isAutoGrading = false;
  QuranAudioReciter? _selectedReciter;

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true));
    final results = await Future.wait([
      _repository.getHistory(),
      _quranRepository.getSurahs(),
    ]);
    final history = results[0] as List<dynamic>;
    final surahs = results[1] as List<dynamic>;
    final names = surahs.map((s) => s.nameArabic as String).toList();
    final numbers = surahs.map((s) => s.number as int).toList();
    final verseCounts = surahs.map((s) => s.verseCount as int).toList();
    final initialVerseCount = verseCounts.isNotEmpty ? verseCounts.first : 5;
    emit(state.copyWith(
      isLoading: false,
      availableSurahs: names,
      availableSurahNumbers: numbers,
      availableSurahVerseCounts: verseCounts,
      selectedSurah: names.isNotEmpty ? names.first : state.selectedSurah,
      selectedSurahNumber:
          numbers.isNotEmpty ? numbers.first : state.selectedSurahNumber,
      selectedRange: AyahRange(
        start: 1,
        end: initialVerseCount < 5 ? initialVerseCount : 5,
      ),
      history: List.from(history),
    ));
  }

  void selectSurah(int index) {
    if (index < 0 || index >= state.availableSurahs.length) return;
    final verseCount = state.availableSurahVerseCounts[index];
    emit(state.copyWith(
      selectedSurah: state.availableSurahs[index],
      selectedSurahNumber: state.availableSurahNumbers[index],
      selectedRange: AyahRange(
        start: 1,
        end: verseCount < 5 ? verseCount : 5,
      ),
    ));
  }

  void selectRange(AyahRange range) {
    final maxAyah = state.selectedSurahVerseCount;
    var start = range.start;
    var end = range.end;
    if (start < 1) start = 1;
    if (start > maxAyah) start = maxAyah;
    if (end < start) end = start;
    if (end > maxAyah) end = maxAyah;
    emit(state.copyWith(selectedRange: AyahRange(start: start, end: end)));
  }

  void setRangeStart(int start) {
    selectRange(AyahRange(start: start, end: state.selectedRange.end));
  }

  void setRangeEnd(int end) {
    selectRange(AyahRange(start: state.selectedRange.start, end: end));
  }

  Future<void> startTest() async {
    await stopAudioTest();
    await stopReciterAyah();
    await stopUserRecordingPlayback();
    emit(state.copyWith(isLoading: true));
    final texts = <String>[];
    for (int i = state.selectedRange.start; i <= state.selectedRange.end; i++) {
      try {
        texts.add(quran_pkg.getVerse(state.selectedSurahNumber, i));
      } catch (_) {}
    }
    emit(state.copyWith(
      status: Tasmee3FlowStatus.testing,
      ayahTexts: texts,
      currentAyahIndex: 0,
      isRevealed: false,
      grades: {},
      clearResult: true,
      spokenText: '',
      spokenWords: const [],
      spokenWordMatches: const [],
      spokenAccuracy: 0,
      isListening: false,
      clearSpeechError: true,
      ayahRecordingPaths: const {},
      isPlayingUserRecording: false,
      isLoading: false,
    ));
    unawaited(startListening());
  }

  void revealCurrentAyah() => emit(state.copyWith(isRevealed: true));

  Future<void> gradeAyah(AyahGrade grade) async {
    await stopListening();
    await stopUserRecordingPlayback();
    final newGrades = Map<int, AyahGrade>.from(state.grades)
      ..[state.currentAyahNumber] = grade;

    if (state.isLastAyah) {
      final result = Tasmee3Result(grades: newGrades);
      final session = Tasmee3Session(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        surahName: state.selectedSurah,
        ayahRange: state.selectedRange,
        date: DateTime.now(),
        result: result,
      );
      await _repository.saveSession(session);
      final history = await _repository.getHistory();
      emit(state.copyWith(
        status: Tasmee3FlowStatus.summary,
        grades: newGrades,
        result: result,
        history: history,
      ));
    } else {
      emit(state.copyWith(
        grades: newGrades,
        currentAyahIndex: state.currentAyahIndex + 1,
        isRevealed: false,
        spokenText: '',
        spokenWords: const [],
        spokenWordMatches: const [],
        spokenAccuracy: 0,
        isListening: false,
        clearSpeechError: true,
      ));
      unawaited(_startListeningForNextAyah());
    }
  }

  Future<void> retryTest() async {
    await stopListening();
    await stopReciterAyah();
    await stopUserRecordingPlayback();
    emit(state.copyWith(
      status: Tasmee3FlowStatus.testing,
      currentAyahIndex: 0,
      isRevealed: false,
      grades: {},
      clearResult: true,
      spokenText: '',
      spokenWords: const [],
      spokenWordMatches: const [],
      spokenAccuracy: 0,
      isListening: false,
      clearSpeechError: true,
      ayahRecordingPaths: const {},
      isPlayingUserRecording: false,
    ));
    unawaited(startListening());
  }

  Future<void> backToSetup() async {
    await stopListening();
    await stopAudioTest();
    await stopReciterAyah();
    await stopUserRecordingPlayback();
    emit(state.copyWith(
      status: Tasmee3FlowStatus.setup,
      currentAyahIndex: 0,
      isRevealed: false,
      grades: {},
      clearResult: true,
      spokenText: '',
      spokenWords: const [],
      spokenWordMatches: const [],
      spokenAccuracy: 0,
      isListening: false,
      clearSpeechError: true,
      isAudioTestPlaying: false,
      clearAudioTestError: true,
      ayahRecordingPaths: const {},
      isPlayingUserRecording: false,
      isReciterAyahPlaying: false,
      clearPlayingReciterAyahNumber: true,
    ));
  }

  void openHistory() =>
      emit(state.copyWith(status: Tasmee3FlowStatus.history));

  void setHistoryFilter(String filter) =>
      emit(state.copyWith(historyFilter: filter));

  Future<void> startListening() async {
    if (state.status != Tasmee3FlowStatus.testing) return;
    await _ensureSpeechReady();
    if (!state.speechAvailable) return;

    final ayahText = state.currentAyahText ?? '';
    if (ayahText.isEmpty) return;

    emit(state.copyWith(
      isListening: true,
      clearSpeechError: true,
      spokenText: '',
      spokenWords: const [],
      spokenWordMatches: const [],
      spokenAccuracy: 0,
      isPlayingUserRecording: false,
    ));

    await _startVoiceRecording();

    await _speech.listen(
      listenOptions: stt.SpeechListenOptions(
        localeId: 'ar',
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
      ),
      onResult: (result) {
        if (state.status != Tasmee3FlowStatus.testing) return;
        final spoken = result.recognizedWords.trim();
        final evaluation = _evaluateSpeech(
          expected: ayahText,
          spoken: spoken,
        );
        emit(state.copyWith(
          spokenText: spoken,
          spokenWords: evaluation.words,
          spokenWordMatches: evaluation.matches,
          spokenAccuracy: evaluation.accuracyPercent,
          isListening: !result.finalResult,
        ));
        if (result.finalResult && spoken.isNotEmpty) {
          final autoGrade = _gradeFromAccuracy(evaluation.accuracyPercent);
          unawaited(_autoGradeCurrentAyah(autoGrade));
        }
      },
    );
  }

  Future<void> stopListening() async {
    await _saveVoiceRecording();
    if (!_speechInitialized) return;
    if (_speech.isListening) {
      await _speech.stop();
    }
    if (state.isListening) {
      emit(state.copyWith(isListening: false));
    }
  }

  Future<void> _ensureSpeechReady() async {
    if (_speechInitialized) return;

    final micPermission = await Permission.microphone.request();
    if (!micPermission.isGranted) {
      emit(state.copyWith(
        speechAvailable: false,
        speechError: 'microphone_permission_denied',
      ));
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          emit(state.copyWith(isListening: false));
        }
      },
      onError: (_) {
        emit(state.copyWith(
          isListening: false,
          speechError: 'speech_recognition_error',
        ));
      },
    );
    _speechInitialized = true;
    emit(state.copyWith(
      speechAvailable: available,
      speechError: available ? null : 'speech_not_available',
    ));
  }

  Future<void> toggleAudioTest() async {
    if (state.isAudioTestPlaying) {
      await stopAudioTest();
      return;
    }
    await playAudioTest();
  }

  Future<void> playAudioTest() async {
    try {
      _selectedReciter ??= await ReciterPreferences.loadSelected(_preferences);
      final reciter = _selectedReciter;
      if (reciter == null) {
        emit(state.copyWith(
          isAudioTestPlaying: false,
          audioTestError: 'audio_test_failed',
        ));
        return;
      }
      final urls = _quranRepository.getAudioAyahUrls(
        surahNumber: state.selectedSurahNumber,
        ayahNumber: state.selectedRange.start,
        reciter: reciter,
      );
      if (urls.isEmpty) {
        emit(state.copyWith(
          isAudioTestPlaying: false,
          audioTestError: 'audio_test_failed',
        ));
        return;
      }
      await _audio.stop();
      await playAudioUrlsWithFallback(_audio, urls: urls);
      emit(state.copyWith(
        isAudioTestPlaying: true,
        clearAudioTestError: true,
      ));
    } catch (_) {
      emit(state.copyWith(
        isAudioTestPlaying: false,
        audioTestError: 'audio_test_failed',
      ));
    }
  }

  Future<void> stopAudioTest() async {
    if (!state.isAudioTestPlaying) return;
    await _audio.stop();
    emit(state.copyWith(isAudioTestPlaying: false));
  }

  Future<void> togglePlayUserRecording() async {
    if (state.isPlayingUserRecording) {
      await stopUserRecordingPlayback();
      return;
    }
    final path = state.currentAyahRecordingPath;
    if (path == null) return;
    await stopAudioTest();
    await stopReciterAyah();
    try {
      await _userRecordingPlayer.setFilePath(path);
      await _userRecordingPlayer.play();
      emit(state.copyWith(isPlayingUserRecording: true));
    } catch (_) {
      emit(state.copyWith(isPlayingUserRecording: false));
    }
  }

  Future<void> stopUserRecordingPlayback() async {
    if (!state.isPlayingUserRecording) {
      await _userRecordingPlayer.stop();
      return;
    }
    await _userRecordingPlayer.stop();
    emit(state.copyWith(isPlayingUserRecording: false));
  }

  Future<void> toggleReciterAyah(int ayahNumber) async {
    if (state.isReciterAyahPlaying &&
        state.playingReciterAyahNumber == ayahNumber) {
      await stopReciterAyah();
      return;
    }
    await stopReciterAyah();
    await stopUserRecordingPlayback();
    try {
      _selectedReciter ??= await ReciterPreferences.loadSelected(_preferences);
      final reciter = _selectedReciter;
      if (reciter == null) return;
      final urls = _quranRepository.getAudioAyahUrls(
        surahNumber: state.selectedSurahNumber,
        ayahNumber: ayahNumber,
        reciter: reciter,
      );
      if (urls.isEmpty) return;
      emit(state.copyWith(
        playingReciterAyahNumber: ayahNumber,
        isReciterAyahPlaying: true,
      ));
      await playAudioUrlsWithFallback(_audio, urls: urls);
      await _audio.onPlaybackCompleted.first;
      if (state.playingReciterAyahNumber == ayahNumber &&
          state.isReciterAyahPlaying) {
        emit(state.copyWith(
          isReciterAyahPlaying: false,
          clearPlayingReciterAyahNumber: true,
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        isReciterAyahPlaying: false,
        clearPlayingReciterAyahNumber: true,
      ));
    }
  }

  Future<void> stopReciterAyah() async {
    if (!state.isReciterAyahPlaying && state.playingReciterAyahNumber == null) {
      return;
    }
    await _audio.stop();
    emit(state.copyWith(
      isReciterAyahPlaying: false,
      clearPlayingReciterAyahNumber: true,
    ));
  }

  Future<void> _startVoiceRecording() async {
    await _voiceRecorder.cancel();
    final fileName =
        'tasmee3_${state.selectedSurahNumber}_${state.currentAyahNumber}.m4a';
    await _voiceRecorder.start(fileName: fileName);
  }

  Future<void> _saveVoiceRecording() async {
    final path = await _voiceRecorder.stop();
    if (path == null || path.isEmpty) return;
    final paths = Map<int, String>.from(state.ayahRecordingPaths)
      ..[state.currentAyahNumber] = path;
    emit(state.copyWith(ayahRecordingPaths: paths));
  }

  _SpeechEvaluation _evaluateSpeech({
    required String expected,
    required String spoken,
  }) {
    final spokenWords = _splitWords(spoken);
    final expectedWords = _splitWords(expected);

    if (spokenWords.isEmpty || expectedWords.isEmpty) {
      return const _SpeechEvaluation(
        words: [],
        matches: [],
        accuracyPercent: 0,
      );
    }

    final normalizedSpoken = spokenWords.map(_normalizeArabic).toList();
    final normalizedExpected = expectedWords.map(_normalizeArabic).toList();
    final lcsMatchIndexes = _lcsMatchedSpokenIndexes(
      spoken: normalizedSpoken,
      expected: normalizedExpected,
    );
    final matches = List<bool>.generate(
      spokenWords.length,
      (index) => lcsMatchIndexes.contains(index),
    );
    final correct = lcsMatchIndexes.length;
    final denominator = expectedWords.length;
    final accuracy = denominator == 0 ? 0 : ((correct / denominator) * 100).round();

    return _SpeechEvaluation(
      words: spokenWords,
      matches: matches,
      accuracyPercent: accuracy,
    );
  }

  List<String> _splitWords(String text) => text
      .split(RegExp(r'\s+'))
      .map((w) => w.trim())
      .where((w) => w.isNotEmpty)
      .toList();

  String _normalizeArabic(String text) {
    return text
        .replaceAll(RegExp(r'[\u0640]'), '')
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll(RegExp(r'[\u06DD\u06DE\u06E9]'), '')
        .replaceAll(RegExp(r'[^\u0621-\u063A\u0641-\u064A0-9 ]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ٱ', 'ا')
        .replaceAll('ـ', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Set<int> _lcsMatchedSpokenIndexes({
    required List<String> spoken,
    required List<String> expected,
  }) {
    final m = spoken.length;
    final n = expected.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        if (spoken[i - 1].isNotEmpty && spoken[i - 1] == expected[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
        }
      }
    }

    final matchedSpokenIndexes = <int>{};
    var i = m;
    var j = n;
    while (i > 0 && j > 0) {
      if (spoken[i - 1].isNotEmpty && spoken[i - 1] == expected[j - 1]) {
        matchedSpokenIndexes.add(i - 1);
        i -= 1;
        j -= 1;
      } else if (dp[i - 1][j] >= dp[i][j - 1]) {
        i -= 1;
      } else {
        j -= 1;
      }
    }
    return matchedSpokenIndexes;
  }

  @override
  Future<void> close() async {
    await stopListening();
    await stopAudioTest();
    await stopReciterAyah();
    await stopUserRecordingPlayback();
    await _userRecordingSubscription?.cancel();
    await _userRecordingPlayer.dispose();
    await _voiceRecorder.dispose();
    return super.close();
  }

  AyahGrade _gradeFromAccuracy(int accuracy) {
    if (accuracy >= 85) return AyahGrade.known;
    if (accuracy >= 60) return AyahGrade.hesitant;
    return AyahGrade.unknown;
  }

  Future<void> _autoGradeCurrentAyah(AyahGrade grade) async {
    if (_isAutoGrading) return;
    if (state.status != Tasmee3FlowStatus.testing) return;
    _isAutoGrading = true;
    try {
      await gradeAyah(grade);
    } finally {
      _isAutoGrading = false;
    }
  }

  Future<void> _startListeningForNextAyah() async {
    // Small delay for smoother UI transition between ayahs.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (state.status != Tasmee3FlowStatus.testing) return;
    await startListening();
  }
}

class _SpeechEvaluation {
  const _SpeechEvaluation({
    required this.words,
    required this.matches,
    required this.accuracyPercent,
  });

  final List<String> words;
  final List<bool> matches;
  final int accuracyPercent;
}
