abstract interface class UserProgressRepository {
  Future<UserProgressSnapshot> getProgress({required String userId});

  Future<void> saveMemorizationProgress({
    required String userId,
    required int surahNumber,
    required int ayahNumber,
    required double progress,
  });

  Future<void> saveReviewProgress({
    required String userId,
    required String reviewId,
    required bool reviewed,
    required bool difficult,
  });

  /// Records user activity for streak tracking without changing counts.
  Future<void> recordActivity({required String userId});
}

class UserProgressSnapshot {
  const UserProgressSnapshot({
    required this.memorizedAyahCount,
    required this.reviewedItemsCount,
    required this.streakDays,
  });

  final int memorizedAyahCount;
  final int reviewedItemsCount;
  final int streakDays;
}
