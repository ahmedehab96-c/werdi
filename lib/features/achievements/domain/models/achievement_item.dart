class AchievementItem {
  const AchievementItem({
    required this.key,
    required this.title,
    this.earnedAt,
  });

  final String key;
  final String title;
  final String? earnedAt;

  bool get isEarned => earnedAt != null;
}
