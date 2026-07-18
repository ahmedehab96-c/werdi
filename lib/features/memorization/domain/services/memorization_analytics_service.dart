import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/core/database/app_database.dart';

class MemorizationAnalyticsSnapshot {
  const MemorizationAnalyticsSnapshot({
    required this.todayAyahs,
    required this.weekAyahs,
    required this.difficultItems,
    required this.reviewedThisWeek,
    required this.last7Days,
  });

  final int todayAyahs;
  final int weekAyahs;
  final int difficultItems;
  final int reviewedThisWeek;
  final List<int> last7Days;

  int get weekTotal => last7Days.fold(0, (sum, value) => sum + value);

  double get weekAverage =>
      last7Days.isEmpty ? 0 : weekTotal / last7Days.length;
}

class MemorizationAnalyticsService {
  const MemorizationAnalyticsService({required AppDatabase database})
      : _database = database;

  final AppDatabase _database;

  Future<MemorizationAnalyticsSnapshot> load({
    String userId = AppConstants.localUserId,
  }) async {
    final today = await _database.countMemorizationToday(userId: userId);
    final week = await _database.countMemorizationThisWeek(userId: userId);
    final difficult = await _database.countDifficultReviewItems();
    final reviewedWeek = await _database.countReviewsThisWeek();
    final trend = await _database.memorizationCountsByDay(userId: userId);

    return MemorizationAnalyticsSnapshot(
      todayAyahs: today,
      weekAyahs: week,
      difficultItems: difficult,
      reviewedThisWeek: reviewedWeek,
      last7Days: trend,
    );
  }
}
