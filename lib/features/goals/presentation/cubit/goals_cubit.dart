import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/features/goals/data/repositories/user_goals_repository.dart';
import 'package:werdi/features/goals/domain/models/user_goals.dart';
import 'package:werdi/features/goals/presentation/cubit/goals_state.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

class GoalsCubit extends Cubit<GoalsState> {
  GoalsCubit({
    required UserGoalsRepository goalsRepository,
    required UserProgressRepository progressRepository,
    required AppDatabase database,
  })  : _goalsRepository = goalsRepository,
        _progressRepository = progressRepository,
        _database = database,
        super(const GoalsState());

  final UserGoalsRepository _goalsRepository;
  final UserProgressRepository _progressRepository;
  final AppDatabase _database;

  Future<void> load() async {
    emit(state.copyWith(status: GoalsStatus.loading, errorMessage: ''));
    try {
      final goals = await _goalsRepository.load();
      if (isClosed) return;
      final progress = await _progressRepository.getProgress(
        userId: AppConstants.localUserId,
      );
      if (isClosed) return;
      final todayAyahs = await _database.countMemorizationToday(
        userId: AppConstants.localUserId,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          status: GoalsStatus.loaded,
          goals: goals,
          progress: progress,
          todayMemorizedAyahs: todayAyahs,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: GoalsStatus.error,
          errorMessage: 'تعذّر تحميل الأهداف',
        ),
      );
    }
  }

  Future<void> setDailyTarget(int value) => _save(
        state.goals.copyWith(dailyTargetAyahs: value.clamp(1, 200)),
      );

  Future<void> setMemorizationGoal(int value) => _save(
        state.goals.copyWith(
          memorizationGoalAyahs: value.clamp(10, 6236),
        ),
      );

  Future<void> setReviewGoal(int value) => _save(
        state.goals.copyWith(reviewSessionsGoal: value.clamp(1, 500)),
      );

  Future<void> addCustomGoal({required String title, required int target}) {
    final goal = UserCustomGoal(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      target: target.clamp(1, 9999),
    );
    if (goal.title.isEmpty) return Future.value();
    return _save(
      state.goals.copyWith(
        customGoals: [...state.goals.customGoals, goal],
      ),
    );
  }

  Future<void> removeCustomGoal(String id) {
    return _save(
      state.goals.copyWith(
        customGoals:
            state.goals.customGoals.where((g) => g.id != id).toList(),
      ),
    );
  }

  Future<void> _save(UserGoals next) async {
    emit(state.copyWith(status: GoalsStatus.saving));
    try {
      final saved = await _goalsRepository.save(next);
      emit(
        state.copyWith(
          status: GoalsStatus.loaded,
          goals: saved,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: GoalsStatus.error,
          errorMessage: 'تعذّر حفظ الأهداف',
        ),
      );
    }
  }
}
