import 'package:equatable/equatable.dart';
import 'package:werdi/features/goals/domain/models/user_goals.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

enum GoalsStatus { loading, loaded, saving, error }

class GoalsState extends Equatable {
  const GoalsState({
    this.status = GoalsStatus.loading,
    this.goals = const UserGoals(),
    this.progress,
    this.todayMemorizedAyahs = 0,
    this.errorMessage = '',
  });

  final GoalsStatus status;
  final UserGoals goals;
  final UserProgressSnapshot? progress;
  final int todayMemorizedAyahs;
  final String errorMessage;

  bool get isBusy =>
      status == GoalsStatus.loading || status == GoalsStatus.saving;

  GoalsState copyWith({
    GoalsStatus? status,
    UserGoals? goals,
    UserProgressSnapshot? progress,
    int? todayMemorizedAyahs,
    String? errorMessage,
  }) {
    return GoalsState(
      status: status ?? this.status,
      goals: goals ?? this.goals,
      progress: progress ?? this.progress,
      todayMemorizedAyahs: todayMemorizedAyahs ?? this.todayMemorizedAyahs,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, goals, progress, todayMemorizedAyahs, errorMessage];
}
