import 'package:werdi/shared/repositories/user_progress_repository.dart';

enum ProfileStatus { loading, loaded, error }

class ProfileState {
  const ProfileState({
    this.status = ProfileStatus.loading,
    this.progress,
    this.earnedBadgeLabels = const [],
    this.errorMessage = '',
  });

  final ProfileStatus status;
  final UserProgressSnapshot? progress;
  final List<String> earnedBadgeLabels;
  final String errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProgressSnapshot? progress,
    List<String>? earnedBadgeLabels,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      earnedBadgeLabels: earnedBadgeLabels ?? this.earnedBadgeLabels,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
