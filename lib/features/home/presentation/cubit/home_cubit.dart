import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/features/home/presentation/cubit/home_state.dart';
import 'package:werdi/features/review/data/repositories/review_repository_impl.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required UserProgressRepository progressRepository,
    required LocalReviewRepository reviewRepository,
    required AppPreferences preferences,
  })  : _progressRepository = progressRepository,
        _reviewRepository = reviewRepository,
        _preferences = preferences,
        super(const HomeState());

  final UserProgressRepository _progressRepository;
  final LocalReviewRepository _reviewRepository;
  final AppPreferences _preferences;

  static const _lastReadKey = 'quran_last_read_surah';

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true));

    final localResults = await Future.wait([
      _reviewRepository.getReviewItems(),
      _preferences.getString(_lastReadKey),
    ]);

    final reviewItems = localResults[0] as List<dynamic>;
    final lastReadSurah = localResults[1] as String?;
    final pendingCount = reviewItems.where((i) => !(i.reviewed as bool)).length;
    final overdueCount =
        reviewItems.where((i) => i.difficult as bool).length;

    final currentSurah =
        lastReadSurah?.replaceFirst('سورة ', '') ?? state.currentSurahName;
    final lastContext =
        lastReadSurah ?? state.lastMemorizedContext;

    emit(state.copyWith(
      reviewDueCount: pendingCount,
      overdueReviewCount: overdueCount,
      currentSurahName: currentSurah,
      lastMemorizedContext: lastContext,
    ));

    try {
      final snapshot = await _progressRepository.getProgress(
        userId: AppConstants.localUserId,
      );
      final totalProgress =
          (snapshot.memorizedAyahCount / 6236).clamp(0.0, 1.0);
      final dailyCompleted =
          snapshot.memorizedAyahCount % state.dailyTargetAyahs;

      emit(state.copyWith(
        isLoading: false,
        dailyCompletedAyahs: dailyCompleted,
        totalMemorizationProgress: totalProgress,
        currentMilestoneAyahs: snapshot.memorizedAyahCount,
        streakDays: snapshot.streakDays,
        weeklyMemorizedAyahs: snapshot.memorizedAyahCount,
        weeklyReviewedAyahs: snapshot.reviewedItemsCount,
      ));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
