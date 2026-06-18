import 'package:werdi/features/achievements/domain/models/achievement_item.dart';

enum AchievementsStatus { loading, loaded, error }

class AchievementsState {
  const AchievementsState({
    this.status = AchievementsStatus.loading,
    this.earned = const [],
    this.upcoming = const [],
    this.errorMessage = '',
  });

  final AchievementsStatus status;
  final List<AchievementItem> earned;
  final List<AchievementItem> upcoming;
  final String errorMessage;

  AchievementsState copyWith({
    AchievementsStatus? status,
    List<AchievementItem>? earned,
    List<AchievementItem>? upcoming,
    String? errorMessage,
  }) {
    return AchievementsState(
      status: status ?? this.status,
      earned: earned ?? this.earned,
      upcoming: upcoming ?? this.upcoming,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
