import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/features/goals/domain/models/user_goals.dart';

void main() {
  group('UserGoals', () {
    test('encode and decode round-trip', () {
      const goals = UserGoals(
        dailyTargetAyahs: 12,
        memorizationGoalAyahs: 500,
        reviewSessionsGoal: 20,
        customGoals: [
          UserCustomGoal(id: '1', title: 'ختمة', target: 6236),
        ],
      );

      final restored = UserGoals.decode(goals.encode());

      expect(restored.dailyTargetAyahs, 12);
      expect(restored.memorizationGoalAyahs, 500);
      expect(restored.reviewSessionsGoal, 20);
      expect(restored.customGoals, hasLength(1));
      expect(restored.customGoals.first.title, 'ختمة');
    });

    test('decode returns defaults for invalid json', () {
      final goals = UserGoals.decode('not-json');
      expect(goals.dailyTargetAyahs, 8);
      expect(goals.customGoals, isEmpty);
    });

    test('copyWith clamps custom goal targets on parse', () {
      final goals = UserGoals.fromJson({
        'dailyTargetAyahs': 999,
        'memorizationGoalAyahs': 50,
        'reviewSessionsGoal': 3,
        'customGoals': [
          {'id': 'a', 'title': '  هدف  ', 'target': 0},
        ],
      });

      expect(goals.dailyTargetAyahs, 200);
      expect(goals.memorizationGoalAyahs, 50);
      expect(goals.customGoals.first.title, 'هدف');
      expect(goals.customGoals.first.target, 1);
    });
  });
}
