import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quran/quran.dart' as quran_pkg;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:werdi/core/audio/audio_playback.dart';
import 'package:werdi/core/audio/voice_recorder_service.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/core/services/reciter_preferences.dart';
import 'package:werdi/features/quran/domain/models/quran_audio_reciter.dart';
import 'package:werdi/features/quran/domain/repositories/quran_repository.dart';
import 'package:werdi/features/tasmee3/domain/models/ayah_evaluation_snapshot.dart';
import 'package:werdi/features/tasmee3/domain/models/ayah_range.dart';
import 'package:werdi/features/tasmee3/domain/models/tasmee3_result.dart';
import 'package:werdi/features/tasmee3/domain/models/tasmee3_session.dart';
import 'package:werdi/features/tasmee3/domain/repositories/tasmee3_repository.dart';
import 'package:werdi/features/tasmee3/domain/services/ayah_speech_evaluator.dart';
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
  QuranAudioReciter? _selectedReciter;
  String? _speechLocaleId;

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
      expectedWords: const [],
      expectedWordCorrect: const [],
      evaluationReady: false,
      ayahEvaluations: const {},
      isListening: false,
      clearSpeechError: true,
      ayahRecordingPaths: const {},
      isPlayingUserRecording: false,
      isLoading: false,
    ));
    await _ensureSpeechReady();
  }

  void revealCurrentAyah() => emit(state.copyWith(isRevealed: true));

  Future<void> confirmAndNextAyah() async {
    if (!state.evaluationReady) return;
    final grade = _gradeFromAccuracy(state.spokenAccuracy);
    await _advanceWithGrade(grade);
  }

  Future<void> gradeAyah(AyahGrade grade) async {
    await _advanceWithGrade(grade);
  }

  Future<void> _advanceWithGrade(AyahGrade grade) async {
    await stopListening();
    await stopUserRecordingPlayback();

    final snapshot = AyahEvaluationSnapshot(
      ayahNumber: state.currentAyahNumber,
      expectedText: state.currentAyahText ?? '',
      spokenText: state.spokenText,
      expectedWords: state.expectedWords,
      expectedWordCorrect: state.expectedWordCorrect,
      accuracyPercent: state.spokenAccuracy,
      gradeLabel: grade.label,
    );
    final evaluations = Map<int, AyahEvaluationSnapshot>.from(state.ayahEvaluations)
      ..[state.currentAyahNumber] = snapshot;

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
        ayahEvaluations: evaluations,
      ));
    } else {
      emit(state.copyWith(
        grades: newGrades,
        ayahEvaluations: evaluations,
        currentAyahIndex: state.currentAyahIndex + 1,
        isRevealed: false,
        spokenText: '',
        spokenWords: const [],
        spokenWordMatches: const [],
        spokenAccuracy: 0,
        expectedWords: const [],
        expectedWordCorrect: const [],
        evaluationReady: false,
        isListening: false,
        clearSpeechError: true,
      ));
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
      expectedWords: const [],
      expectedWordCorrect: const [],
      evaluationReady: false,
      ayahEvaluations: const {},
      isListening: false,
      clearSpeechError: true,
      ayahRecordingPaths: const {},
      isPlayingUserRecording: false,
    ));
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
      expectedWords: const [],
      expectedWordCorrect: const [],
      evaluationReady: false,
      ayahEvaluations: const {},
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
    if (state.evaluationReady) return;
    await _ensureSpeechReady();
    if (!state.speechAvailable) return;

    final ayahText = state.currentAyahText ?? '';
    if (ayahText.isEmpty) return;

    await _voiceRecorder.cancel();
    emit(state.copyWith(isRecordingForPlayback: false));

    if (_speech.isListening) {
      await _speech.stop();
    }

    final localeId = _speechLocaleId;
    if (localeId == null) {
      emit(state.copyWith(
        speechAvailable: false,
        speechError: 'arabic_not_available',
      ));
      return;
    }

    emit(state.copyWith(
      isListening: true,
      clearSpeechError: true,
      spokenText: '',
      spokenWords: const [],
      spokenWordMatches: const [],
      spokenAccuracy: 0,
      expectedWords: const [],
      expectedWordCorrect: const [],
      evaluationReady: false,
      isPlayingUserRecording: false,
    ));

    try {
      await _speech.listen(
        listenOptions: stt.SpeechListenOptions(
          localeId: localeId,
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
          cancelOnError: false,
          listenFor: const Duration(minutes: 3),
          pauseFor: const Duration(seconds: 15),
        ),
        onResult: (result) {
          if (state.status != Tasmee3FlowStatus.testing) return;
          final spoken = result.recognizedWords.trim();
          if (spoken.isEmpty) return;
          _applySpeechResult(expected: ayahText, spoken: spoken);
          emit(state.copyWith(isListening: !result.finalResult));
          if (result.finalResult) {
            unawaited(_finalizeListening());
          }
        },
      );
    } catch (_) {
      emit(state.copyWith(
        isListening: false,
        speechError: 'speech_recognition_error',
      ));
    }
  }

  Future<void> finishListeningAndEvaluate() async {
    await _finalizeListening();
  }

  Future<void> _finalizeListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    if (state.isRecordingForPlayback) {
      await _saveVoiceRecording();
      emit(state.copyWith(isRecordingForPlayback: false));
    }

    final ayahText = state.currentAyahText ?? '';
    final spoken = state.spokenText.trim();

    if (spoken.isEmpty) {
      emit(state.copyWith(
        isListening: false,
        evaluationReady: false,
        speechError: 'speech_timeout',
      ));
      return;
    }

    final evaluation = AyahSpeechEvaluation.evaluate(
      expected: ayahText,
      spoken: spoken,
    );

    if (evaluation.isMostlyNonArabic) {
      emit(state.copyWith(
        isListening: false,
        evaluationReady: false,
        speechError: 'wrong_language',
        expectedWords: evaluation.expectedWords,
        expectedWordCorrect: evaluation.expectedWordCorrect,
      ));
      return;
    }

    emit(state.copyWith(
      isListening: false,
      evaluationReady: true,
      clearSpeechError: true,
      spokenWords: evaluation.spokenWords,
      spokenWordMatches: evaluation.spokenWordMatches,
      spokenAccuracy: evaluation.accuracyPercent,
      expectedWords: evaluation.expectedWords,
      expectedWordCorrect: evaluation.expectedWordCorrect,
    ));
  }

  void _applySpeechResult({
    required String expected,
    required String spoken,
  }) {
    final evaluation = AyahSpeechEvaluation.evaluate(
      expected: expected,
      spoken: spoken,
    );
    if (evaluation.isMostlyNonArabic) return;
    emit(state.copyWith(
      spokenText: spoken,
      spokenWords: evaluation.spokenWords,
      spokenWordMatches: evaluation.spokenWordMatches,
      spokenAccuracy: evaluation.accuracyPercent,
      expectedWords: evaluation.expectedWords,
      expectedWordCorrect: evaluation.expectedWordCorrect,
    ));
  }

  Future<void> stopListening() async {
    await _finalizeListening();
  }

  /// Records a short clip for self-review (does not run during speech recognition).
  Future<void> startPlaybackRecording() async {
    if (state.status != Tasmee3FlowStatus.testing) return;
    await stopListening();
    await stopUserRecordingPlayback();
    final micPermission = await Permission.microphone.request();
    if (!micPermission.isGranted) {
      emit(state.copyWith(speechError: 'microphone_permission_denied'));
      return;
    }
    await _voiceRecorder.cancel();
    final fileName =
        'tasmee3_${state.selectedSurahNumber}_${state.currentAyahNumber}.m4a';
    final started = await _voiceRecorder.start(fileName: fileName);
    if (!started) return;
    emit(state.copyWith(
      isRecordingForPlayback: true,
      clearSpeechError: true,
    ));
  }

  Future<void> stopPlaybackRecording() async {
    if (!state.isRecordingForPlayback) return;
    await _saveVoiceRecording();
    emit(state.copyWith(isRecordingForPlayback: false));
  }

  Future<void> _ensureSpeechReady() async {
    if (_speechInitialized && state.speechAvailable) return;

    final micPermission = await Permission.microphone.request();
    if (!micPermission.isGranted) {
      emit(state.copyWith(
        speechAvailable: false,
        speechError: 'microphone_permission_denied',
      ));
      return;
    }

    if (Platform.isIOS) {
      final speechPermission = await Permission.speech.request();
      if (!speechPermission.isGranted) {
        emit(state.copyWith(
          speechAvailable: false,
          speechError: 'microphone_permission_denied',
        ));
        return;
      }
    }

    if (!_speechInitialized) {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (state.isListening) {
              emit(state.copyWith(isListening: false));
            }
          }
        },
        onError: _handleSpeechError,
      );
      _speechInitialized = true;
      if (available) {
        _speechLocaleId = await _resolveSpeechLocale();
      }
      final hasArabic = _speechLocaleId != null;
      emit(state.copyWith(
        speechAvailable: available && hasArabic,
        speechError: !available
            ? 'speech_not_available'
            : (!hasArabic ? 'arabic_not_available' : null),
        clearSpeechError: available && hasArabic,
      ));
      return;
    }

    // Mic permission granted after a prior failed attempt.
    try {
      _speechLocaleId ??= await _resolveSpeechLocale();
      final hasArabic = _speechLocaleId != null;
      emit(state.copyWith(
        speechAvailable: hasArabic,
        speechError: hasArabic ? null : 'arabic_not_available',
        clearSpeechError: hasArabic,
      ));
    } catch (_) {
      emit(state.copyWith(
        speechAvailable: false,
        speechError: 'speech_not_available',
      ));
    }
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    if (state.status != Tasmee3FlowStatus.testing) return;
    final msg = error.errorMsg.toLowerCase();
    if (msg.contains('no_match') || msg.contains('no match')) {
      return;
    }
    if (msg.contains('timeout')) {
      if (state.spokenText.trim().isNotEmpty) {
        unawaited(_finalizeListening());
      } else {
        emit(state.copyWith(isListening: false, speechError: 'speech_timeout'));
      }
      return;
    }
    emit(state.copyWith(
      isListening: false,
      speechError:
          error.permanent ? 'speech_not_available' : 'speech_recognition_error',
    ));
  }

  Future<String?> _resolveSpeechLocale() async {
    try {
      final locales = await _speech.locales();
      if (locales.isEmpty) return null;
      const preferred = [
        'ar_SA',
        'ar-SA',
        'ar_EG',
        'ar-EG',
        'ar_AE',
        'ar-AE',
        'ar',
      ];
      for (final pref in preferred) {
        for (final locale in locales) {
          final id = locale.localeId;
          if (id == pref ||
              id.replaceAll('-', '_') == pref.replaceAll('-', '_')) {
            return id;
          }
        }
      }
      for (final locale in locales) {
        if (locale.localeId.toLowerCase().startsWith('ar')) {
          return locale.localeId;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
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

  Future<void> _saveVoiceRecording() async {
    final path = await _voiceRecorder.stop();
    if (path == null || path.isEmpty) return;
    final paths = Map<int, String>.from(state.ayahRecordingPaths)
      ..[state.currentAyahNumber] = path;
    emit(state.copyWith(ayahRecordingPaths: paths));
  }

  @override
  Future<void> close() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    await _voiceRecorder.cancel();
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
}
