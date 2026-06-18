import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran/quran.dart' as quran_pkg;
import 'package:werdi/features/review/domain/models/review_item.dart';
import 'package:werdi/features/review/domain/repositories/review_repository.dart';
import 'package:werdi/features/review/presentation/cubit/review_state.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

class ReviewCubit extends Cubit<ReviewState> {
  ReviewCubit({
    required ReviewRepository repository,
    required UserProgressRepository progressRepository,
  }) : _repository = repository,
       _progressRepository = progressRepository,
       super(const ReviewState()) {
    initialize();
  }

  final ReviewRepository _repository;
  final UserProgressRepository _progressRepository;

  Future<void> initialize() async {
    final items = await _repository.getReviewItems();
    emit(state.copyWith(items: items.map(_withAyahText).toList()));
  }

  ReviewItem _withAyahText(ReviewItem item) {
    final surah = item.surahNumber;
    if (surah == null) return item;
    final start = item.ayahStart ?? 1;
    final end = item.ayahEnd ?? start;
    final buffer = StringBuffer();
    for (var i = start; i <= end; i++) {
      try {
        buffer.write(quran_pkg.getVerse(surah, i));
        if (i < end) buffer.write('\n\n');
      } catch (_) {}
    }
    return item.copyWith(ayahText: buffer.toString());
  }

  Future<void> markReviewed(String id) => _update(
        id,
        (item) => item.copyWith(reviewed: true, subtitle: 'تمت المراجعة'),
      );

  Future<void> markDifficult(String id) => _update(
        id,
        (item) => item.copyWith(
          difficult: !item.difficult,
          priority: !item.difficult ? ReviewPriority.high : ReviewPriority.medium,
        ),
      );

  Future<void> repeat(String id) =>
      _update(id, (item) => item.copyWith(reviewed: false, subtitle: 'تحتاج مراجعة'));

  Future<void> _update(
    String id,
    ReviewItem Function(ReviewItem) transform,
  ) async {
    final updated = state.items.map((item) {
      if (item.id != id) return item;
      return transform(item);
    }).toList();
    emit(state.copyWith(items: updated));
    final current = updated.firstWhere((item) => item.id == id);
    // Persist without ayah text (reloaded at runtime from quran package)
    try {
      await _repository.upsertItem(current.copyWith(ayahText: ''));
    } catch (_) {}
    try {
      await _progressRepository.saveReviewProgress(
        userId: 'current',
        reviewId: id,
        reviewed: current.reviewed,
        difficult: current.difficult,
      );
    } catch (_) {}
  }
}
