import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran/quran.dart' as quran_pkg;
import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/features/goals/data/repositories/user_goals_repository.dart';
import 'package:werdi/features/review/domain/models/review_item.dart';
import 'package:werdi/features/review/domain/models/smart_review_plan.dart';
import 'package:werdi/features/review/domain/repositories/review_repository.dart';
import 'package:werdi/features/review/domain/services/smart_review_planner.dart';
import 'package:werdi/features/review/presentation/cubit/review_state.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

class ReviewCubit extends Cubit<ReviewState> {
  ReviewCubit({
    required ReviewRepository repository,
    required UserProgressRepository progressRepository,
    required UserGoalsRepository goalsRepository,
    SmartReviewPlanner? planner,
  })  : _repository = repository,
        _progressRepository = progressRepository,
        _goalsRepository = goalsRepository,
        _planner = planner ?? const SmartReviewPlanner(),
        super(const ReviewState()) {
    initialize();
  }

  final ReviewRepository _repository;
  final UserProgressRepository _progressRepository;
  final UserGoalsRepository _goalsRepository;
  final SmartReviewPlanner _planner;

  Future<void> initialize() async {
    try {
      final items = await _repository.getReviewItems();
      if (isClosed) return;
      await _emitWithPlan(items.map(_withAyahText).toList());
    } catch (_) {
      if (isClosed) return;
      emit(const ReviewState());
    }
  }

  Future<void> startSmartSession() async {
    final plan = state.plan;
    if (plan == null || !plan.hasSession) return;
    emit(state.copyWith(sessionActive: true, sessionIndex: 0));
  }

  void endSmartSession() {
    emit(state.copyWith(sessionActive: false, sessionIndex: 0));
  }

  Future<void> markCurrentReviewedAndAdvance() async {
    final current = state.currentSessionItem;
    if (current == null) return;
    await markReviewed(current.id);
    _advanceSession();
  }

  void skipCurrentSessionItem() => _advanceSession();

  void _advanceSession() {
    final plan = state.plan;
    if (plan == null) return;
    final next = state.sessionIndex + 1;
    if (next >= plan.sessionItems.length) {
      emit(state.copyWith(sessionIndex: next));
      return;
    }
    emit(state.copyWith(sessionIndex: next));
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
    await _emitWithPlan(updated);
    final current = updated.firstWhere((item) => item.id == id);
    try {
      await _repository.upsertItem(current.copyWith(ayahText: ''));
    } catch (_) {}
    try {
      await _progressRepository.saveReviewProgress(
        userId: AppConstants.localUserId,
        reviewId: id,
        reviewed: current.reviewed,
        difficult: current.difficult,
      );
    } catch (_) {}
  }

  Future<void> _emitWithPlan(List<ReviewItem> items) async {
    final goals = await _goalsRepository.load();
    if (isClosed) return;
    final plan = _planner.build(
      items: items,
      reviewSessionsGoal: goals.reviewSessionsGoal,
    );
    final ordered = _planner.sortForDisplay(items: items, plan: plan);
    final withText = ordered.map(_withAyahText).toList();
    final sessionIndex = _clampSessionIndex(
      state.sessionIndex,
      plan,
      state.sessionActive,
    );
    emit(
      ReviewState(
        items: withText,
        plan: plan,
        sessionActive: state.sessionActive,
        sessionIndex: sessionIndex,
      ),
    );
  }

  int _clampSessionIndex(
    int current,
    SmartReviewPlan plan,
    bool sessionActive,
  ) {
    if (!sessionActive || !plan.hasSession) return 0;
    if (current >= plan.sessionItems.length) return plan.sessionItems.length;
    return current;
  }
}
