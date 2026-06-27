import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quran/quran.dart' as quran_pkg;
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:werdi/core/audio/audio_playback.dart';
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
        super(const Tasmee3State());

  final Tasmee3Repository _repository;
  final QuranRepository _quranRepository;
  final AudioRepository _audio;
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

    final ready = await _ensureSpeechReady();
    if (!ready) return;

    final ayahText = state.currentAyahText ?? '';
    if (ayahText.isEmpty) return;

    if (_speech.isListening) await _speech.stop();

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
          listenFor: const Duration(minutes: 3),
          pauseFor: const Duration(seconds: 20),
        ),
        onResult: (result) {
          if (state.status != Tasmee3FlowStatus.testing) return;
          final spoken = result.recognizedWords.trim();
          if (spoken.isEmpty) return;
          final evaluation = AyahSpeechEvaluation.evaluate(
            expected: ayahText,
            spoken: spoken,
          );
          if (evaluation.isMostlyNonArabic) return;
          emit(state.copyWith(
            spokenText: spoken,
            spokenAccuracy: evaluation.accuracyPercent,
            ayahWords: evaluation.expectedWords,
            expectedWordCorrect: evaluation.expectedWordCorrect,
            isListening: !result.finalResult,
          ));
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
    if (_speech.isListening) await _speech.stop();

    final ayahText = state.currentAyahText ?? '';
    final spoken = state.spokenText.trim();

    if (spoken.isEmpty) {
      emit(state.copyWith(
        isListening: false,
        speechError: 'speech_timeout',
      ));
      return;
    }

    final evaluation = AyahSpeechEvaluation.evaluate(
      expected: ayahText,
      spoken: spoken,
    );

    if (evaluation.isMostlyNonArabic) {
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

    emit(state.copyWith(
      isListening: false,
      evaluationReady: true,
      clearSpeechError: true,
      spokenText: evaluation.spokenText,
      spokenAccuracy: evaluation.accuracyPercent,
      ayahWords: evaluation.expectedWords,
      expectedWordCorrect: evaluation.expectedWordCorrect,
    ));
  }

  Future<void> confirmAndNextAyah() async {
    if (!state.evaluationReady) return;
    final grade = _gradeFromAccuracy(state.spokenAccuracy);
    await _advanceWithGrade(grade);
  }

  Future<void> _advanceWithGrade(AyahGrade grade) async {
    await _stopSpeech();

    final snapshot = AyahEvaluationSnapshot(
      ayahNumber: state.currentAyahNumber,
      expectedText: state.currentAyahText ?? '',
      spokenText: state.spokenText,
      expectedWords: state.ayahWords,
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
        spokenText: '',
        spokenAccuracy: 0,
        ayahWords: const [],
        expectedWordCorrect: const [],
        evaluationReady: false,
        isListening: false,
        clearSpeechError: true,
      ));
    }
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
    if (!mic.isGranted) {
      emit(state.copyWith(
        speechAvailable: false,
        speechError: 'microphone_permission_denied',
      ));
      return false;
    }
    if (Platform.isIOS) {
      final speech = await Permission.speech.request();
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
      _speechInitialized = true;
      if (!ok) {
        emit(state.copyWith(
          speechAvailable: false,
          speechError: 'speech_not_available',
        ));
        return false;
      }
      _speechLocaleId = await _resolveBestLocale();
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
    if (accuracy >= 85) return AyahGrade.known;
    if (accuracy >= 60) return AyahGrade.hesitant;
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

  Future<void> toggleReciterAyah(int ayahNumber) async {
    if (state.isReciterAyahPlaying &&
        state.playingReciterAyahNumber == ayahNumber) {
      await stopReciterAyah();
      return;
    }
    await stopReciterAyah();
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

  @override
  Future<void> close() async {
    if (_speech.isListening) await _speech.stop();
    await stopAudioTest();
    await stopReciterAyah();
    return super.close();
  }
}
