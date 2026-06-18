import 'package:werdi/features/review/domain/models/review_item.dart';

abstract interface class ReviewRepository {
  Future<List<ReviewItem>> getReviewItems();
  Future<void> upsertItem(ReviewItem item);
}
