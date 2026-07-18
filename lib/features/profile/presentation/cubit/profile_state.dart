import 'package:werdi/features/goals/domain/models/user_goals.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

enum ProfileStatus { loading, loaded, error }

class ProfileState {
  const ProfileState({
    this.status = ProfileStatus.loading,
    this.progress,
    this.earnedBadgeLabels = const [],
    this.goals = const UserGoals(),
    this.displayName = '',
    this.errorMessage = '',
  });

  final ProfileStatus status;
  final UserProgressSnapshot? progress;
  final List<String> earnedBadgeLabels;
  final UserGoals goals;
  final String displayName;
  final String errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProgressSnapshot? progress,
    List<String>? earnedBadgeLabels,
    UserGoals? goals,
    String? displayName,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      earnedBadgeLabels: earnedBadgeLabels ?? this.earnedBadgeLabels,
      goals: goals ?? this.goals,
      displayName: displayName ?? this.displayName,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
