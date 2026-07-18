import 'package:equatable/equatable.dart';
import 'package:werdi/features/review/domain/models/review_item.dart';
import 'package:werdi/features/review/domain/models/smart_review_plan.dart';

class ReviewState extends Equatable {
  const ReviewState({
    this.items = const [],
    this.plan,
    this.sessionActive = false,
    this.sessionIndex = 0,
  });

  final List<ReviewItem> items;
  final SmartReviewPlan? plan;
  final bool sessionActive;
  final int sessionIndex;

  ReviewItem? get currentSessionItem {
    final plan = this.plan;
    if (!sessionActive || plan == null || !plan.hasSession) return null;
    if (sessionIndex >= plan.sessionItems.length) return null;
    return plan.sessionItems[sessionIndex];
  }

  bool get sessionComplete {
    final plan = this.plan;
    if (!sessionActive || plan == null) return false;
    return sessionIndex >= plan.sessionItems.length;
  }

  ReviewState copyWith({
    List<ReviewItem>? items,
    SmartReviewPlan? plan,
    bool? sessionActive,
    int? sessionIndex,
  }) {
    return ReviewState(
      items: items ?? this.items,
      plan: plan ?? this.plan,
      sessionActive: sessionActive ?? this.sessionActive,
      sessionIndex: sessionIndex ?? this.sessionIndex,
    );
  }

  @override
  List<Object?> get props => [items, plan, sessionActive, sessionIndex];
}
