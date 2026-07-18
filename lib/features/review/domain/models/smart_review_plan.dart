import 'package:equatable/equatable.dart';
import 'package:werdi/features/review/domain/models/review_item.dart';

/// Ordered daily review session built from weak and pending items.
class SmartReviewPlan extends Equatable {
  const SmartReviewPlan({
    required this.sessionItems,
    required this.totalNeedingReview,
    required this.difficultCount,
    required this.pendingCount,
    required this.dailyQuota,
  });

  final List<ReviewItem> sessionItems;
  final int totalNeedingReview;
  final int difficultCount;
  final int pendingCount;
  final int dailyQuota;

  bool get hasSession => sessionItems.isNotEmpty;

  @override
  List<Object?> get props => [
        sessionItems,
        totalNeedingReview,
        difficultCount,
        pendingCount,
        dailyQuota,
      ];
}
