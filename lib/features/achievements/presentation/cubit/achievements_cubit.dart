import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/features/achievements/domain/repositories/achievements_repository.dart';
import 'package:werdi/features/achievements/presentation/cubit/achievements_state.dart';
import 'package:werdi/features/tasmee3/domain/repositories/tasmee3_repository.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

class AchievementsCubit extends Cubit<AchievementsState> {
  AchievementsCubit({
    required AchievementsRepository repository,
    required UserProgressRepository progressRepository,
    required Tasmee3Repository tasmee3Repository,
  })  : _repository = repository,
        _progressRepository = progressRepository,
        _tasmee3Repository = tasmee3Repository,
        super(const AchievementsState());

  final AchievementsRepository _repository;
  final UserProgressRepository _progressRepository;
  final Tasmee3Repository _tasmee3Repository;

  Future<void> load() async {
    emit(state.copyWith(status: AchievementsStatus.loading));
    try {
      final progress = await _progressRepository.getProgress(
        userId: AppConstants.localUserId,
      );
      if (isClosed) return;
      final sessions = await _tasmee3Repository.getHistory();
      if (isClosed) return;
      final result = await _repository.evaluateFromMetrics(
        memorizedAyahCount: progress.memorizedAyahCount,
        reviewedItemsCount: progress.reviewedItemsCount,
        streakDays: progress.streakDays,
        tasmee3Sessions: sessions.length,
      );
      // Best-effort remote sync/award using live metrics.
      try {
        await _repository.getAchievements();
      } catch (_) {}
      if (isClosed) return;
      emit(state.copyWith(
        status: AchievementsStatus.loaded,
        earned: result.earned,
        upcoming: result.upcoming,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        status: AchievementsStatus.error,
        errorMessage: 'تعذّر تحميل الإنجازات',
      ));
    }
  }
}
