import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/features/home/domain/services/home_dashboard_service.dart';
import 'package:werdi/features/home/presentation/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required HomeDashboardService dashboardService})
      : _dashboardService = dashboardService,
        super(const HomeState());

  final HomeDashboardService _dashboardService;
  bool _loading = false;

  Future<void> initialize() => _load(silent: true);

  Future<void> refresh() => _load(silent: false);

  Future<void> _load({required bool silent}) async {
    if (_loading) return;
    _loading = true;

    if (!silent) {
      emit(state.copyWith(isRefreshing: true));
    }

    try {
      final data = await _dashboardService
          .load(dailyTargetAyahs: state.dailyTargetAyahs)
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              if (kDebugMode) {
                debugPrint(
                  'HomeDashboardService.load timed out — using fallback',
                );
              }
              return HomeDashboardSnapshot.fallback();
            },
          );
      if (!isClosed) {
        emit(_stateFromSnapshot(data));
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('HomeCubit._load failed: $error\n$stackTrace');
      }
      if (!isClosed) {
        emit(_stateFromSnapshot(HomeDashboardSnapshot.fallback()));
      }
    } finally {
      _loading = false;
    }
  }

  HomeState _stateFromSnapshot(HomeDashboardSnapshot data) {
    return state.copyWith(
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
    );
  }
}
