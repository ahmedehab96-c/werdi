import 'package:werdi/features/auth/domain/repositories/auth_repository.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

enum ProfileStatus { loading, loaded, error }

class ProfileState {
  const ProfileState({
    this.status = ProfileStatus.loading,
    this.user,
    this.progress,
    this.earnedBadgeLabels = const [],
    this.errorMessage = '',
  });

  final ProfileStatus status;
  final AuthUser? user;
  final UserProgressSnapshot? progress;
  final List<String> earnedBadgeLabels;
  final String errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    AuthUser? user,
    UserProgressSnapshot? progress,
    List<String>? earnedBadgeLabels,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      progress: progress ?? this.progress,
      earnedBadgeLabels: earnedBadgeLabels ?? this.earnedBadgeLabels,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
