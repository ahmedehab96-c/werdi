import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/features/goals/data/repositories/user_goals_repository.dart';
import 'package:werdi/features/goals/domain/models/user_goals.dart';
import 'package:werdi/features/goals/presentation/cubit/goals_cubit.dart';
import 'package:werdi/features/goals/presentation/cubit/goals_state.dart';

import '../../support/fakes.dart';

void main() {
  group('GoalsCubit', () {
    late UserGoalsRepository goalsRepository;
    late FakeUserProgressRepository progressRepository;
    late AppDatabase database;
    late GoalsCubit cubit;

    setUp(() {
      goalsRepository = UserGoalsRepository(preferences: FakeAppPreferences());
      progressRepository = FakeUserProgressRepository();
      database = AppDatabase.inMemory();
      cubit = GoalsCubit(
        goalsRepository: goalsRepository,
        progressRepository: progressRepository,
        database: database,
      );
    });

    tearDown(() async {
      await cubit.close();
      await database.close();
    });

    test('load populates goals and progress', () async {
      await goalsRepository.save(
        const UserGoals(dailyTargetAyahs: 9, reviewSessionsGoal: 20),
      );

      await cubit.load();

      expect(cubit.state.status, GoalsStatus.loaded);
      expect(cubit.state.goals.dailyTargetAyahs, 9);
      expect(cubit.state.goals.reviewSessionsGoal, 20);
      expect(cubit.state.progress?.memorizedAyahCount, 12);
      expect(cubit.state.todayMemorizedAyahs, 0);
    });

    test('setDailyTarget clamps and persists', () async {
      await cubit.setDailyTarget(500);

      expect(cubit.state.goals.dailyTargetAyahs, 200);
      expect(cubit.state.status, GoalsStatus.loaded);

      final reloaded = await goalsRepository.load();
      expect(reloaded.dailyTargetAyahs, 200);
    });

    test('addCustomGoal ignores empty titles', () async {
      await cubit.addCustomGoal(title: '   ', target: 5);

      expect(cubit.state.goals.customGoals, isEmpty);
    });

    test('addCustomGoal and removeCustomGoal update list', () async {
      await cubit.addCustomGoal(title: 'ختمة', target: 30);
      final id = cubit.state.goals.customGoals.single.id;

      await cubit.removeCustomGoal(id);

      expect(cubit.state.goals.customGoals, isEmpty);
    });
  });
}
