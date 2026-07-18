import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/core/audio/audio_playback.dart';
import 'package:werdi/core/audio/quran_audio_session.dart';
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
    try {
      _selectedReciter = await ReciterPreferences.loadSelected(_preferences);
      if (isClosed) return;
      final surahs = await _quranRepository.getSurahs();
      if (isClosed) return;

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
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(phase: MemorizationPhase.setup));
    }
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
    try {
      _selectedReciter = await ReciterPreferences.loadSelected(_preferences);
      if (isClosed) return;
      final ayahs = await _repository.getSessionAyahs(
        surahNumber: state.selectedSurahNumber,
        ayahStart: state.ayahStart,
        ayahEnd: state.ayahEnd,
      );
      if (isClosed) return;
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
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(phase: MemorizationPhase.setup, isPlaying: false));
    }
  }

  void backToSetup() {
    unawaited(_audio.stop());
    emit(state.copyWith(phase: MemorizationPhase.setup, isPlaying: false));
  }

  Future<void> startTestSession() async {
    await _audio.stop();
    if (isClosed) return;
    emit(state.copyWith(phase: MemorizationPhase.testSession, isPlaying: false));
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

  Future<void> toggleDifficult() async {
    final current = state.currentAyah;
    if (current == null) return;
    final set = Set<int>.from(state.difficultAyahNumbers);
    final markingDifficult = !set.contains(current.number);
    if (markingDifficult) {
      set.add(current.number);
    } else {
      set.remove(current.number);
    }
    emit(state.copyWith(difficultAyahNumbers: set));

    final reviewRepo = _reviewRepository;
    if (reviewRepo == null) return;

    final ayahNumber = current.number;
    final surahNumber = state.selectedSurahNumber;
    final reviewId = '${surahNumber}_ayah_$ayahNumber';
    if (markingDifficult) {
      await reviewRepo.upsertItem(
        ReviewItem(
          id: reviewId,
          title: 'سورة ${state.selectedSurahName} - آية $ayahNumber',
          subtitle: 'آية صعبة - ركّز عليها في المراجعة',
          priority: ReviewPriority.high,
          surahNumber: surahNumber,
          ayahStart: ayahNumber,
          ayahEnd: ayahNumber,
          difficult: true,
        ),
      );
    } else {
      final items = await reviewRepo.getReviewItems();
      final existing = items.where((item) => item.id == reviewId).firstOrNull;
      if (existing != null) {
        await reviewRepo.upsertItem(
          existing.copyWith(
            difficult: false,
            priority: ReviewPriority.medium,
            subtitle: 'تحتاج مراجعة',
          ),
        );
      }
    }
  }

  Future<void> _loadAndPlayCurrentAyah({required bool autoPlay}) async {
    final ayah = state.currentAyah;
    if (ayah == null) return;
    _selectedReciter ??= await ReciterPreferences.loadSelected(_preferences);
    if (isClosed) return;
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
      if (isClosed) return;
      final metadata = AyahPlaybackMetadata(
        surahNumber: state.selectedSurahNumber,
        surahNameArabic: state.selectedSurahName,
        ayahNumber: ayah.number,
        reciterName: reciter.name,
      );
      if (autoPlay) {
        _remainingRepeats = state.repeatCount;
        await playAudioUrlsWithFallback(
          _audio,
          urls: urls,
          metadata: metadata,
          onSkipNext: state.isLastAyah ? null : nextAyah,
          onSkipPrevious: state.isFirstAyah ? null : previousAyah,
        );
        if (isClosed) return;
        emit(state.copyWith(isPlaying: true));
      } else {
        QuranAudioSession.prepare(
          metadata: metadata,
          onSkipNext: state.isLastAyah ? null : nextAyah,
          onSkipPrevious: state.isFirstAyah ? null : previousAyah,
        );
        Object? lastError;
        for (final url in urls) {
          try {
            await _audio.loadSource(source: url);
            return;
          } catch (error) {
            lastError = error;
          }
        }
        if (lastError != null) throw lastError;
      }
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isPlaying: false));
    }
  }

  void _bindPlaybackCompletion() {
    _playbackCompletionSub?.cancel();
    _playbackCompletionSub = _audio.onPlaybackCompleted.listen((_) async {
      if (isClosed) return;
      if (!state.isPlaying || state.phase != MemorizationPhase.session) return;
      if (_isHandlingCompletion) return;
      _isHandlingCompletion = true;
      try {
        if (_remainingRepeats > 1) {
          _remainingRepeats -= 1;
          await _audio.seek(Duration.zero);
          if (isClosed) return;
          await _audio.play();
          return;
        }
        if (!state.isLastAyah) {
          await nextAyah();
          return;
        }
        if (isClosed) return;
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
