import 'package:werdi/features/review/domain/models/review_item.dart';
import 'package:werdi/features/review/domain/models/smart_review_plan.dart';

/// Builds a prioritized review session from difficult and pending ayahs.
class SmartReviewPlanner {
  const SmartReviewPlanner();

  SmartReviewPlan build({
    required List<ReviewItem> items,
    int reviewSessionsGoal = 15,
  }) {
    final needing = items.where(_needsReview).toList();
    final difficultCount = needing.where((item) => item.difficult).length;
    final pendingCount = needing.where((item) => !item.reviewed).length;

    final sorted = List<ReviewItem>.from(needing)..sort(_compare);

    final quota = _dailyQuota(
      difficultCount: difficultCount,
      needingCount: needing.length,
      reviewSessionsGoal: reviewSessionsGoal,
    );

    return SmartReviewPlan(
      sessionItems: sorted.take(quota).toList(),
      totalNeedingReview: needing.length,
      difficultCount: difficultCount,
      pendingCount: pendingCount,
      dailyQuota: quota,
    );
  }

  List<ReviewItem> sortForDisplay({
    required List<ReviewItem> items,
    required SmartReviewPlan plan,
  }) {
    if (!plan.hasSession) return items;

    final sessionIds = plan.sessionItems.map((item) => item.id).toSet();
    final session = plan.sessionItems;
    final rest = items.where((item) => !sessionIds.contains(item.id)).toList()
      ..sort(_compare);
    return [...session, ...rest];
  }

  bool _needsReview(ReviewItem item) => !item.reviewed || item.difficult;

  int _dailyQuota({
    required int difficultCount,
    required int needingCount,
    required int reviewSessionsGoal,
  }) {
    if (needingCount == 0) return 0;

    final base = difficultCount > 0 ? difficultCount * 2 : reviewSessionsGoal;
    final capped = base.clamp(3, reviewSessionsGoal);
    return capped.clamp(1, needingCount);
  }

  int _compare(ReviewItem a, ReviewItem b) {
    final scoreDiff = _score(b) - _score(a);
    if (scoreDiff != 0) return scoreDiff;

    final aTime = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bTime = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return aTime.compareTo(bTime);
  }

  int _score(ReviewItem item) {
    var score = 0;
    if (item.difficult) score += 100;
    if (!item.reviewed) score += 50;
    score += switch (item.priority) {
      ReviewPriority.high => 30,
      ReviewPriority.medium => 15,
      ReviewPriority.low => 0,
    };
    return score;
  }
}
