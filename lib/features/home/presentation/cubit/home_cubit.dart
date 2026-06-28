import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/features/home/domain/services/home_dashboard_service.dart';
import 'package:werdi/features/home/presentation/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required HomeDashboardService dashboardService})
      : _dashboardService = dashboardService,
        super(const HomeState());

  final HomeDashboardService _dashboardService;

  Future<void> initialize() => _load(showFullLoader: true);

  Future<void> refresh() => _load(showFullLoader: false);

  Future<void> _load({required bool showFullLoader}) async {
    if (showFullLoader) {
      emit(state.copyWith(isLoading: true));
    } else {
      emit(state.copyWith(isRefreshing: true));
    }

    try {
      final data = await _dashboardService.load(
        dailyTargetAyahs: state.dailyTargetAyahs,
      );
      emit(state.copyWith(
        isLoading: false,
        isRefreshing: false,
        userName: data.userName,
        motivationSubtitle: data.motivationSubtitle,
        reviewDueCount: data.reviewDueCount,
        overdueReviewCount: data.overdueReviewCount,
        currentSurahName: data.currentSurahName,
        lastMemorizedContext: data.lastMemorizedContext,
        lastReviewContext: data.lastReviewContext,
        dailyCompletedAyahs: data.dailyCompletedAyahs,
        totalMemorizationProgress: data.totalMemorizationProgress,
        currentSurahProgress: data.currentSurahProgress,
        currentMilestoneAyahs: data.currentMilestoneAyahs,
        nextMilestoneAyahs: data.nextMilestoneAyahs,
        streakDays: data.streakDays,
        weeklyMemorizedAyahs: data.weeklyMemorizedAyahs,
        weeklyReviewedAyahs: data.weeklyReviewedAyahs,
        weeklySessions: data.weeklySessions,
        weeklyProgress: data.weeklyProgress,
        badges: data.badges,
        nextBadgeTitle: data.nextBadgeTitle,
        dailyQuote: data.dailyQuote,
        recommendedNextStep: data.recommendedNextStep,
        recommendedPlanAction: data.recommendedPlanAction,
      ));
    } catch (_) {
      emit(state.copyWith(isLoading: false, isRefreshing: false));
    }
  }
}
