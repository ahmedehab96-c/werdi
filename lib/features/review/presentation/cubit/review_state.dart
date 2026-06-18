import 'package:equatable/equatable.dart';
import 'package:werdi/features/review/domain/models/review_item.dart';

class ReviewState extends Equatable {
  const ReviewState({this.items = const []});

  final List<ReviewItem> items;

  ReviewState copyWith({List<ReviewItem>? items}) {
    return ReviewState(items: items ?? this.items);
  }

  @override
  List<Object> get props => [items];
}
