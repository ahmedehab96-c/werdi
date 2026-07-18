import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quran/quran.dart' as quran_pkg;
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/core/audio/audio_playback.dart';
import 'package:werdi/core/audio/quran_audio_session.dart';
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
import 'package:werdi/shared/repositories/user_progress_repository.dart';

class Tasmee3Cubit extends Cubit<Tasmee3State> {
  Tasmee3Cubit({
    required Tasmee3Repository repository,
    required QuranRepository quranRepository,
    required AudioRepository audioRepository,
    required UserProgressRepository progressRepository,
    required AppPreferences preferences,
  })  : _repository = repository,
        _quranRepository = quranRepository,
        _audio = audioRepository,
        _progressRepository = progressRepository,
        _preferences = preferences,
        super(const Tasmee3State());

  final Tasmee3Repository _repository;
  final QuranRepository _quranRepository;
  final AudioRepository _audio;
  final UserProgressRepository _progressRepository;
  final AppPreferences _preferences;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechInitialized = false;
  String _speechLocaleId = 'ar-SA';
  int _localeAttempt = 0;
  QuranAudioReciter? _selectedReciter;

  static const _arabicLocaleFallbacks = [
    'ar-SA',
    'ar_SA',
    'ar-EG',
    'ar_EG',
    'ar-AE',
    'ar',
  ];

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true));
    try {
      final results = await Future.wait([
        _repository.getHistory(),
        _quranRepository.getSurahs(),
      ]);
      if (isClosed) return;
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
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false));
    }
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
    await _stopSpeech();
    emit(state.copyWith(isLoading: true));
    final texts = <String>[];
    for (int i = state.selectedRange.start; i <= state.selectedRange.end; i++) {
      try {
        texts.add(quran_pkg.getVerse(state.selectedSurahNumber, i));
      } catch (_) {}
    }
    _resetAyahSession();
    emit(state.copyWith(
      status: Tasmee3FlowStatus.testing,
      ayahTexts: texts,
      currentAyahIndex: 0,
      grades: {},
      clearResult: true,
      ayahEvaluations: const {},
      isLoading: false,
    ));
    await _ensureSpeechReady();
  }

  void _resetAyahSession() {
    emit(state.copyWith(
      spokenText: '',
      spokenAccuracy: 0,
      ayahWords: const [],
      expectedWordCorrect: const [],
      evaluationReady: false,
      isListening: false,
      clearSpeechError: true,
    ));
  }

  Future<void> startListening() async {
    if (state.status != Tasmee3FlowStatus.testing) return;
    if (state.ayahTexts.isEmpty) return;

    final ready = await _ensureSpeechReady();
    if (isClosed || !ready) return;

    if (_speech.isListening) await _speech.stop();
    if (isClosed) return;

    emit(state.copyWith(
      isListening: true,
      clearSpeechError: true,
      spokenText: '',
      spokenAccuracy: 0,
      ayahWords: const [],
      expectedWordCorrect: const [],
      evaluationReady: false,
    ));

    try {
      await _speech.listen(
        listenOptions: stt.SpeechListenOptions(
          localeId: _speechLocaleId,
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
          cancelOnError: false,
          listenFor: const Duration(minutes: 5),
          // Longer pause so natural ayah pauses do not end recognition early.
          pauseFor: const Duration(seconds: 45),
        ),
        onResult: (result) {
          if (isClosed) return;
          if (state.status != Tasmee3FlowStatus.testing) return;
          final spoken = result.recognizedWords.trim();
          if (spoken.isEmpty) return;

          // Keep listening until the user taps Finish. Engine "final" results
          // often fire mid-recitation and previously hid the Finish button.
          final merged = _mergeSpokenTranscript(state.spokenText, spoken);
          emit(state.copyWith(
            spokenText: merged,
            isListening: true,
            clearSpeechError: true,
          ));
        },
      );
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        isListening: false,
        speechError: 'speech_recognition_error',
      ));
    }
  }

  /// Prefer the longer transcript; if STT resets to a new phrase, append it.
  String _mergeSpokenTranscript(String previous, String incoming) {
    final prev = previous.trim();
    final next = incoming.trim();
    if (prev.isEmpty) return next;
    if (next.isEmpty) return prev;
    if (next.startsWith(prev) || next.contains(prev)) return next;
    if (prev.contains(next)) return prev;
    return '$prev $next';
  }

  Future<void> finishListeningAndEvaluate() async {
    if (_speech.isListening) await _speech.stop();
    if (isClosed) return;

    // Give the engine a brief moment to deliver a last final result.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (isClosed) return;

    final spoken = state.spokenText.trim();
    if (spoken.isEmpty) {
      emit(state.copyWith(
        isListening: false,
        speechError: 'speech_timeout',
      ));
      return;
    }

    if (_isMostlyNonArabicSpoken(spoken)) {
      if (_localeAttempt < _arabicLocaleFallbacks.length - 1) {
        _localeAttempt += 1;
        _speechLocaleId = _arabicLocaleFallbacks[_localeAttempt];
        emit(state.copyWith(
          isListening: false,
          speechError: 'wrong_language',
          evaluationReady: false,
        ));
        return;
      }
      emit(state.copyWith(
        isListening: false,
        speechError: 'wrong_language',
        evaluationReady: false,
      ));
      return;
    }

    final blockEvaluations = AyahSpeechEvaluation.evaluateBlock(
      expectedAyahs: state.ayahTexts,
      spoken: spoken,
    );

    final evaluations = <int, AyahEvaluationSnapshot>{};
    final grades = <int, AyahGrade>{};
    var accuracySum = 0;

    for (var i = 0; i < state.ayahTexts.length; i++) {
      final ayahNum = state.selectedRange.start + i;
      final evaluation = i < blockEvaluations.length
          ? blockEvaluations[i]
          : AyahSpeechEvaluation.evaluate(
              expected: state.ayahTexts[i],
              spoken: spoken,
            );
      final grade = _gradeFromAccuracy(evaluation.accuracyPercent);
      accuracySum += evaluation.accuracyPercent;
      grades[ayahNum] = grade;
      evaluations[ayahNum] = AyahEvaluationSnapshot(
        ayahNumber: ayahNum,
        expectedText: state.ayahTexts[i],
        spokenText: spoken,
        expectedWords: evaluation.expectedWords,
        expectedWordCorrect: evaluation.expectedWordCorrect,
        accuracyPercent: evaluation.accuracyPercent,
        gradeLabel: grade.label,
      );
    }

    final avgAccuracy = state.ayahTexts.isEmpty
        ? 0
        : (accuracySum / state.ayahTexts.length).round();

    emit(state.copyWith(
      isListening: false,
      evaluationReady: true,
      clearSpeechError: true,
      spokenText: spoken,
      spokenAccuracy: avgAccuracy,
      ayahEvaluations: evaluations,
      grades: grades,
      ayahWords: const [],
      expectedWordCorrect: const [],
    ));
  }

  bool _isMostlyNonArabicSpoken(String text) {
    final chars = text.replaceAll(RegExp(r'\s'), '');
    if (chars.isEmpty) return false;
    final arabic =
        RegExp(r'[\u0600-\u06FF]').allMatches(chars).length;
    return arabic / chars.length < 0.4;
  }

  Future<void> confirmAndNextAyah() async {
    if (!state.evaluationReady) return;
    await _finishBlockTest();
  }

  Future<void> _finishBlockTest() async {
    await _stopSpeech();
    if (isClosed) return;
    final result = Tasmee3Result(grades: state.grades);
    final session = Tasmee3Session(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      surahName: state.selectedSurah,
      ayahRange: state.selectedRange,
      date: DateTime.now(),
      result: result,
    );
    await _repository.saveSession(session);
    if (isClosed) return;
    await _progressRepository.recordActivity(userId: AppConstants.localUserId);
    if (isClosed) return;
    final history = await _repository.getHistory();
    if (isClosed) return;
    emit(state.copyWith(
      status: Tasmee3FlowStatus.summary,
      result: result,
      history: history,
    ));
  }

  void syncSelection({
    required String surahName,
    required int surahNumber,
    required int ayahStart,
    required int ayahEnd,
  }) {
    emit(state.copyWith(
      selectedSurah: surahName,
      selectedSurahNumber: surahNumber,
      selectedRange: AyahRange(start: ayahStart, end: ayahEnd),
    ));
  }

  Future<void> retryTest() async {
    await _stopSpeech();
    await stopReciterAyah();
    _localeAttempt = 0;
    _speechLocaleId = _arabicLocaleFallbacks.first;
    emit(state.copyWith(
      status: Tasmee3FlowStatus.testing,
      currentAyahIndex: 0,
      grades: {},
      clearResult: true,
      ayahEvaluations: const {},
      spokenText: '',
      spokenAccuracy: 0,
      ayahWords: const [],
      expectedWordCorrect: const [],
      evaluationReady: false,
      isListening: false,
      clearSpeechError: true,
    ));
  }

  Future<void> backToSetup() async {
    await _stopSpeech();
    await stopAudioTest();
    await stopReciterAyah();
    _localeAttempt = 0;
    emit(state.copyWith(
      status: Tasmee3FlowStatus.setup,
      currentAyahIndex: 0,
      grades: {},
      clearResult: true,
      ayahEvaluations: const {},
      spokenText: '',
      spokenAccuracy: 0,
      ayahWords: const [],
      expectedWordCorrect: const [],
      evaluationReady: false,
      isListening: false,
      clearSpeechError: true,
      isAudioTestPlaying: false,
      clearAudioTestError: true,
      isReciterAyahPlaying: false,
      clearPlayingReciterAyahNumber: true,
    ));
  }

  void openHistory() =>
      emit(state.copyWith(status: Tasmee3FlowStatus.history));

  void setHistoryFilter(String filter) =>
      emit(state.copyWith(historyFilter: filter));

  Future<bool> _ensureSpeechReady() async {
    final mic = await Permission.microphone.request();
    if (isClosed) return false;
    if (!mic.isGranted) {
      emit(state.copyWith(
        speechAvailable: false,
        speechError: 'microphone_permission_denied',
      ));
      return false;
    }
    if (Platform.isIOS) {
      final speech = await Permission.speech.request();
      if (isClosed) return false;
      if (!speech.isGranted) {
        emit(state.copyWith(
          speechAvailable: false,
          speechError: 'microphone_permission_denied',
        ));
        return false;
      }
    }
    if (!_speechInitialized) {
      final ok = await _speech.initialize(onError: _handleSpeechError);
      if (isClosed) return false;
      _speechInitialized = true;
      if (!ok) {
        emit(state.copyWith(
          speechAvailable: false,
          speechError: 'speech_not_available',
        ));
        return false;
      }
      _speechLocaleId = await _resolveBestLocale();
      if (isClosed) return false;
    }
    emit(state.copyWith(speechAvailable: true, clearSpeechError: true));
    return true;
  }

  Future<String> _resolveBestLocale() async {
    try {
      final locales = await _speech.locales();
      for (final pref in _arabicLocaleFallbacks) {
        for (final locale in locales) {
          final id = locale.localeId;
          if (id == pref ||
              id.replaceAll('-', '_') == pref.replaceAll('-', '_') ||
              id.toLowerCase().startsWith('ar')) {
            return id;
          }
        }
      }
    } catch (_) {}
    return _arabicLocaleFallbacks.first;
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    if (isClosed) return;
    if (state.status != Tasmee3FlowStatus.testing) return;
    final msg = error.errorMsg.toLowerCase();
    if (msg.contains('no_match')) return;
    if (msg.contains('timeout') && state.spokenText.trim().isNotEmpty) {
      unawaited(finishListeningAndEvaluate());
      return;
    }
    if (msg.contains('timeout')) {
      emit(state.copyWith(isListening: false, speechError: 'speech_timeout'));
    }
  }

  Future<void> _stopSpeech() async {
    if (_speech.isListening) await _speech.stop();
    if (state.isListening) {
      emit(state.copyWith(isListening: false));
    }
  }

  AyahGrade _gradeFromAccuracy(int accuracy) {
    // Softer thresholds: STT on Quranic Arabic is imperfect.
    if (accuracy >= 70) return AyahGrade.known;
    if (accuracy >= 45) return AyahGrade.hesitant;
    return AyahGrade.unknown;
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
      if (isClosed) return;
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
      if (isClosed) return;
      await playAudioUrlsWithFallback(
        _audio,
        urls: urls,
        metadata: AyahPlaybackMetadata(
          surahNumber: state.selectedSurahNumber,
          surahNameArabic: state.selectedSurah,
          ayahNumber: state.selectedRange.start,
          reciterName: reciter.name,
        ),
      );
      if (isClosed) return;
      emit(state.copyWith(
        isAudioTestPlaying: true,
        clearAudioTestError: true,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        isAudioTestPlaying: false,
        audioTestError: 'audio_test_failed',
      ));
    }
  }

  Future<void> stopAudioTest() async {
    if (!state.isAudioTestPlaying) return;
    await _audio.stop();
    if (isClosed) return;
    emit(state.copyWith(isAudioTestPlaying: false));
  }

  Future<void> toggleReciterAyah(int ayahNumber) async {
    if (state.isReciterAyahPlaying &&
        state.playingReciterAyahNumber == ayahNumber) {
      await stopReciterAyah();
      return;
    }
    await stopReciterAyah();
    if (isClosed) return;
    try {
      _selectedReciter ??= await ReciterPreferences.loadSelected(_preferences);
      if (isClosed) return;
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
      final verseCount = quran_pkg.getVerseCount(state.selectedSurahNumber);
      await playAudioUrlsWithFallback(
        _audio,
        urls: urls,
        metadata: AyahPlaybackMetadata(
          surahNumber: state.selectedSurahNumber,
          surahNameArabic: state.selectedSurah,
          ayahNumber: ayahNumber,
          reciterName: reciter.name,
        ),
        onSkipNext: ayahNumber < verseCount
            ? () {
                if (isClosed) return;
                unawaited(toggleReciterAyah(ayahNumber + 1));
              }
            : null,
        onSkipPrevious: ayahNumber > 1
            ? () {
                if (isClosed) return;
                unawaited(toggleReciterAyah(ayahNumber - 1));
              }
            : null,
      );
      if (isClosed) return;
      try {
        await _audio.onPlaybackCompleted.first.timeout(
          const Duration(minutes: 10),
        );
      } on TimeoutException {
        // Playback stopped or stalled — clear UI state below.
      } on StateError {
        // Stream closed without event (e.g. stop()) — clear UI state below.
      }
      if (isClosed) return;
      if (state.playingReciterAyahNumber == ayahNumber &&
          state.isReciterAyahPlaying) {
        emit(state.copyWith(
          isReciterAyahPlaying: false,
          clearPlayingReciterAyahNumber: true,
        ));
      }
    } catch (_) {
      if (isClosed) return;
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
    if (isClosed) return;
    emit(state.copyWith(
      isReciterAyahPlaying: false,
      clearPlayingReciterAyahNumber: true,
    ));
  }

  @override
  Future<void> close() async {
    try {
      await _speech.cancel();
    } catch (_) {
      if (_speech.isListening) await _speech.stop();
    }
    await stopAudioTest();
    await stopReciterAyah();
    return super.close();
  }
}
