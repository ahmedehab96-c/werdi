import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/features/goals/data/repositories/user_goals_repository.dart';
import 'package:werdi/features/goals/domain/models/user_goals.dart';
import 'package:werdi/features/home/domain/services/home_dashboard_service.dart';
import 'package:werdi/features/home/presentation/cubit/home_cubit.dart';
import 'package:werdi/features/home/presentation/cubit/home_state.dart';

import '../../support/fakes.dart';

void main() {
  group('HomeCubit', () {
    late UserGoalsRepository goalsRepository;
    late AppDatabase database;
    late FakeHomeDashboardService dashboardService;
    late HomeCubit cubit;

    setUp(() {
      goalsRepository = UserGoalsRepository(preferences: FakeAppPreferences());
      database = AppDatabase.inMemory();
      dashboardService = FakeHomeDashboardService(
        goalsRepository: goalsRepository,
        database: database,
        snapshot: const HomeDashboardSnapshot(
          userName: 'أحمد',
          motivationSubtitle: 'تابع رحلتك',
          reviewDueCount: 2,
          overdueReviewCount: 1,
          currentSurahName: 'الملك',
          lastMemorizedContext: 'الملك 3',
          lastReviewContext: 'البقرة 10',
          dailyCompletedAyahs: 4,
          totalMemorizationProgress: 0.2,
          currentSurahProgress: 0.5,
          currentMilestoneAyahs: 40,
          nextMilestoneAyahs: 100,
          streakDays: 5,
          weeklyMemorizedAyahs: 12,
          weeklyReviewedAyahs: 6,
          weeklySessions: 3,
          weeklyProgress: [0.2, 0.4, 0.1, 0, 0.3, 0.5, 0.2],
          badges: ['بداية قوية'],
          nextBadgeTitle: 'محفظ نشيط',
          dailyQuote: 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
          recommendedNextStep: 'راجع الآن',
          recommendedPlanAction: HomePlanAction.review,
        ),
      );
      cubit = HomeCubit(
        dashboardService: dashboardService,
        goalsRepository: goalsRepository,
      );
    });

    tearDown(() async {
      await cubit.close();
      await database.close();
    });

    test('initialize loads goals and dashboard snapshot', () async {
      await goalsRepository.save(
        const UserGoals(dailyTargetAyahs: 12, memorizationGoalAyahs: 400),
      );

      await cubit.initialize();

      expect(cubit.state.dailyTargetAyahs, 12);
      expect(cubit.state.memorizationGoalAyahs, 400);
      expect(cubit.state.userName, 'أحمد');
      expect(cubit.state.streakDays, 5);
      expect(cubit.state.isRefreshing, isFalse);
      expect(dashboardService.loadCalls, 1);
    });

    test('refresh sets isRefreshing then clears it', () async {
      await cubit.refresh();

      expect(cubit.state.isRefreshing, isFalse);
      expect(cubit.state.recommendedPlanAction, HomePlanAction.review);
      expect(dashboardService.loadCalls, 1);
    });

    test('falls back when dashboard load throws', () async {
      dashboardService.shouldThrow = true;

      await cubit.refresh();

      expect(cubit.state.currentSurahName, 'الملك');
      expect(cubit.state.isRefreshing, isFalse);
    });
  });

  group('HomeState', () {
    test('computes daily progress and remaining ayahs', () {
      const state = HomeState(
        dailyTargetAyahs: 8,
        dailyCompletedAyahs: 3,
      );

      expect(state.dailyRemainingAyahs, 5);
      expect(state.dailyProgress, closeTo(0.375, 0.001));
      expect(state.hasOverdueReviews, isFalse);
    });
  });
}
