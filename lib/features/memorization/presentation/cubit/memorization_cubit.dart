import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/core/audio/audio_playback.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/core/services/reciter_preferences.dart';
import 'package:werdi/features/memorization/domain/repositories/memorization_repository.dart';
import 'package:werdi/features/memorization/presentation/cubit/memorization_state.dart';
import 'package:werdi/features/quran/domain/models/quran_audio_reciter.dart';
import 'package:werdi/features/quran/domain/repositories/quran_repository.dart';
import 'package:werdi/features/review/domain/models/review_item.dart';
import 'package:werdi/features/review/domain/repositories/review_repository.dart';
import 'package:werdi/shared/repositories/audio_repository.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

class MemorizationCubit extends Cubit<MemorizationState> {
  MemorizationCubit({
    required MemorizationRepository repository,
    required QuranRepository quranRepository,
    required AudioRepository audioRepository,
    required UserProgressRepository progressRepository,
    required AppPreferences preferences,
    ReviewRepository? reviewRepository,
    this.initialSurahNumber,
  })  : _repository = repository,
        _quranRepository = quranRepository,
        _audio = audioRepository,
        _progressRepository = progressRepository,
        _preferences = preferences,
        _reviewRepository = reviewRepository,
        super(const MemorizationState()) {
    initialize();
  }

  final int? initialSurahNumber;
  final MemorizationRepository _repository;
  final QuranRepository _quranRepository;
  final AudioRepository _audio;
  final UserProgressRepository _progressRepository;
  final AppPreferences _preferences;
  final ReviewRepository? _reviewRepository;

  QuranAudioReciter? _selectedReciter;
  StreamSubscription<void>? _playbackCompletionSub;
  int _remainingRepeats = 1;
  bool _isHandlingCompletion = false;

  Future<void> initialize() async {
    _bindPlaybackCompletion();
    _selectedReciter = await ReciterPreferences.loadSelected(_preferences);
    final surahs = await _quranRepository.getSurahs();

    final targetSurah = initialSurahNumber != null
        ? (surahs.cast<dynamic>().where((s) => s.number == initialSurahNumber).firstOrNull ?? (surahs.isNotEmpty ? surahs.first : null))
        : (surahs.isNotEmpty ? surahs.first : null);
    final maxEnd = targetSurah != null
        ? (targetSurah.verseCount < 10 ? targetSurah.verseCount : 10)
        : 10;
    emit(state.copyWith(
      phase: MemorizationPhase.setup,
      availableSurahs: List.from(surahs),
      selectedSurahNumber: targetSurah?.number ?? 1,
      selectedSurahName: targetSurah?.nameArabic ?? '',
      selectedVerseCount: targetSurah?.verseCount ?? maxEnd,
      ayahStart: 1,
      ayahEnd: maxEnd,
      selectedReciterName: _selectedReciter?.name,
    ));
  }

  void selectSurah(int surahNumber) {
    final surah = state.availableSurahs
        .where((s) => s.number == surahNumber)
        .firstOrNull;
    if (surah == null) return;
    final maxEnd = surah.verseCount < 10 ? surah.verseCount : 10;
    emit(state.copyWith(
      selectedSurahNumber: surahNumber,
      selectedSurahName: surah.nameArabic,
      selectedVerseCount: surah.verseCount,
      ayahStart: 1,
      ayahEnd: maxEnd,
    ));
  }

  void setAyahRange(int start, int end) {
    emit(state.copyWith(ayahStart: start, ayahEnd: end));
  }

  Future<void> startSession() async {
    emit(state.copyWith(phase: MemorizationPhase.loading));
    _selectedReciter = await ReciterPreferences.loadSelected(_preferences);
    final ayahs = await _repository.getSessionAyahs(
      surahNumber: state.selectedSurahNumber,
      ayahStart: state.ayahStart,
      ayahEnd: state.ayahEnd,
    );
    emit(state.copyWith(
      phase: MemorizationPhase.session,
      ayahs: ayahs,
      currentIndex: 0,
      isPlaying: false,
      memorizedAyahNumbers: const {},
      difficultAyahNumbers: const {},
      selectedReciterName: _selectedReciter?.name,
    ));
    await _loadAndPlayCurrentAyah(autoPlay: false);
  }

  void backToSetup() {
    _audio.stop();
    emit(state.copyWith(phase: MemorizationPhase.setup, isPlaying: false));
  }

  void startTestSession() {
    emit(state.copyWith(phase: MemorizationPhase.testSession));
  }

  Future<void> togglePlay() async {
    if (state.isPlaying) {
      await _audio.pause();
      emit(state.copyWith(isPlaying: false));
    } else {
      _remainingRepeats = state.repeatCount;
      if (_selectedReciter == null) {
        await _loadAndPlayCurrentAyah(autoPlay: true);
        return;
      }
      await _audio.play();
      emit(state.copyWith(isPlaying: true));
    }
  }

  Future<void> nextAyah() async {
    if (state.isLastAyah) return;
    final wasPlaying = state.isPlaying;
    await _audio.stop();
    emit(state.copyWith(
      currentIndex: state.currentIndex + 1,
      isPlaying: false,
    ));
    await _loadAndPlayCurrentAyah(autoPlay: wasPlaying);
  }

  Future<void> previousAyah() async {
    if (state.isFirstAyah) return;
    final wasPlaying = state.isPlaying;
    await _audio.stop();
    emit(state.copyWith(
      currentIndex: state.currentIndex - 1,
      isPlaying: false,
    ));
    await _loadAndPlayCurrentAyah(autoPlay: wasPlaying);
  }

  Future<void> setRepeatCount(int count) async {
    emit(state.copyWith(repeatCount: count));
  }

  Future<void> setPlaybackSpeed(double speed) async {
    emit(state.copyWith(playbackSpeed: speed));
    await _audio.setSpeed(speed);
  }

  Future<void> toggleMemorized() async {
    final current = state.currentAyah;
    if (current == null) return;
    final set = Set<int>.from(state.memorizedAyahNumbers);
    final adding = !set.contains(current.number);
    if (adding) {
      set.add(current.number);
    } else {
      set.remove(current.number);
    }
    emit(state.copyWith(memorizedAyahNumbers: set));
    if (adding) {
      _reviewRepository?.upsertItem(ReviewItem(
        id: '${state.selectedSurahNumber}_${state.ayahStart}_${state.ayahEnd}',
        title: 'سورة ${state.selectedSurahName} (${state.ayahStart} - ${state.ayahEnd})',
        subtitle: 'حُفِظ مؤخراً - يحتاج مراجعة',
        priority: ReviewPriority.high,
        surahNumber: state.selectedSurahNumber,
        ayahStart: state.ayahStart,
        ayahEnd: state.ayahEnd,
      ));
    }
    try {
      await _progressRepository.saveMemorizationProgress(
        userId: AppConstants.localUserId,
        surahNumber: state.selectedSurahNumber,
        ayahNumber: current.number,
        progress: set.length / state.ayahs.length,
      );
    } catch (_) {}
  }

  void toggleShowText() {
    emit(state.copyWith(showAyahText: !state.showAyahText));
  }

  void toggleDifficult() {
    final current = state.currentAyah;
    if (current == null) return;
    final set = Set<int>.from(state.difficultAyahNumbers);
    if (set.contains(current.number)) {
      set.remove(current.number);
    } else {
      set.add(current.number);
    }
    emit(state.copyWith(difficultAyahNumbers: set));
  }

  Future<void> _loadAndPlayCurrentAyah({required bool autoPlay}) async {
    final ayah = state.currentAyah;
    if (ayah == null) return;
    _selectedReciter ??= await ReciterPreferences.loadSelected(_preferences);
    final reciter = _selectedReciter;
    if (reciter == null) return;

    try {
      final urls = _quranRepository.getAudioAyahUrls(
        surahNumber: state.selectedSurahNumber,
        ayahNumber: ayah.number,
        reciter: reciter,
      );
      if (urls.isEmpty) return;

      await _audio.setSpeed(state.playbackSpeed);
      if (autoPlay) {
        _remainingRepeats = state.repeatCount;
        await playAudioUrlsWithFallback(_audio, urls: urls);
        emit(state.copyWith(isPlaying: true));
      } else {
        await _audio.loadSource(source: urls.first);
      }
    } catch (_) {
      emit(state.copyWith(isPlaying: false));
    }
  }

  void _bindPlaybackCompletion() {
    _playbackCompletionSub?.cancel();
    _playbackCompletionSub = _audio.onPlaybackCompleted.listen((_) async {
      if (!state.isPlaying || state.phase != MemorizationPhase.session) return;
      if (_isHandlingCompletion) return;
      _isHandlingCompletion = true;
      try {
        if (_remainingRepeats > 1) {
          _remainingRepeats -= 1;
          await _audio.seek(Duration.zero);
          await _audio.play();
          return;
        }
        if (!state.isLastAyah) {
          await nextAyah();
          return;
        }
        emit(state.copyWith(isPlaying: false));
      } finally {
        _isHandlingCompletion = false;
      }
    });
  }

  @override
  Future<void> close() async {
    await _playbackCompletionSub?.cancel();
    await _audio.stop();
    await super.close();
  }
}
