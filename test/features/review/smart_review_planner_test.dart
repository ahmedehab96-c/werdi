import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/features/review/domain/models/review_item.dart';
import 'package:werdi/features/review/domain/services/smart_review_planner.dart';

void main() {
  const planner = SmartReviewPlanner();

  ReviewItem item({
    required String id,
    bool difficult = false,
    bool reviewed = false,
    ReviewPriority priority = ReviewPriority.medium,
    DateTime? updatedAt,
  }) {
    return ReviewItem(
      id: id,
      title: id,
      subtitle: id,
      priority: priority,
      difficult: difficult,
      reviewed: reviewed,
      updatedAt: updatedAt,
    );
  }

  test('prioritizes difficult and unreviewed items', () {
    final plan = planner.build(
      items: [
        item(id: 'easy-reviewed', reviewed: true),
        item(id: 'pending', reviewed: false),
        item(id: 'difficult', difficult: true, reviewed: true),
      ],
      reviewSessionsGoal: 10,
    );

    expect(plan.sessionItems.first.id, 'difficult');
    expect(plan.sessionItems[1].id, 'pending');
    expect(plan.difficultCount, 1);
    expect(plan.pendingCount, 1);
  });

  test('caps daily quota by reviewSessionsGoal', () {
    final items = List.generate(
      20,
      (index) => item(id: 'item-$index', reviewed: false),
    );

    final plan = planner.build(items: items, reviewSessionsGoal: 7);

    expect(plan.dailyQuota, 7);
    expect(plan.sessionItems, hasLength(7));
  });

  test('sortForDisplay puts session items first', () {
    final items = [
      item(id: 'a'),
      item(id: 'b', difficult: true),
      item(id: 'c'),
    ];
    final plan = planner.build(items: items, reviewSessionsGoal: 10);

    final sorted = planner.sortForDisplay(items: items, plan: plan);

    expect(sorted.first.id, plan.sessionItems.first.id);
  });
}
