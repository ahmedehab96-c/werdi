import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/features/goals/data/repositories/user_goals_repository.dart';
import 'package:werdi/features/goals/domain/models/user_goals.dart';

import '../../support/fakes.dart';

void main() {
  group('UserGoalsRepository', () {
    test('persists and loads goals', () async {
      final repo = UserGoalsRepository(preferences: FakeAppPreferences());

      await repo.save(
        const UserGoals(dailyTargetAyahs: 10, memorizationGoalAyahs: 200),
      );

      final loaded = await repo.load();
      expect(loaded.dailyTargetAyahs, 10);
      expect(loaded.memorizationGoalAyahs, 200);
    });

    test('updateDailyTarget clamps values', () async {
      final repo = UserGoalsRepository(preferences: FakeAppPreferences());

      await repo.updateDailyTarget(500);
      expect(repo.cached.dailyTargetAyahs, 200);

      await repo.updateDailyTarget(0);
      expect(repo.cached.dailyTargetAyahs, 1);
    });

    test('addCustomGoal ignores empty titles', () async {
      final repo = UserGoalsRepository(preferences: FakeAppPreferences());

      await repo.addCustomGoal(
        const UserCustomGoal(id: 'x', title: '   ', target: 5),
      );

      expect(repo.cached.customGoals, isEmpty);
    });
  });
}
