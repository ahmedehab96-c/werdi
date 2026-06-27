import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

class LocalUserProgressRepository implements UserProgressRepository {
  LocalUserProgressRepository({
    required AppDatabase database,
    AppPreferences? preferences,
  })  : _database = database,
        _preferences = preferences ?? const SharedPrefsService();

  final AppDatabase _database;
  final AppPreferences _preferences;

  static const _streakKey = 'progress_streak_days';
  static const _lastActivityKey = 'progress_last_activity_date';
  static const _reviewCountKey = 'progress_reviewed_items_count';

  @override
  Future<UserProgressSnapshot> getProgress({required String userId}) async {
    final memorized = await _database.getMemorizedAyahCount(userId: userId);
    final reviewedFromDb = await _database.countReviewedItems();
    final reviewedCached = int.tryParse(
          await _getValue(_keyForUser(_reviewCountKey, userId)) ?? '',
        ) ??
        0;
    final reviewed = reviewedFromDb > reviewedCached
        ? reviewedFromDb
        : reviewedCached;
    final streak = await _effectiveStreak(userId);
    return UserProgressSnapshot(
      memorizedAyahCount: memorized,
      reviewedItemsCount: reviewed,
      streakDays: streak,
    );
  }

  @override
  Future<void> saveMemorizationProgress({
    required String userId,
    required int surahNumber,
    required int ayahNumber,
    required double progress,
  }) async {
    await _database.addMemorizationProgress(
      userId: userId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      progress: progress,
    );
    final streak = await _recordActivity(userId);
    final memorized = await _database.getMemorizedAyahCount(userId: userId);
    final reviewed = int.tryParse(
          await _getValue(_keyForUser(_reviewCountKey, userId)) ?? '',
        ) ??
        0;
    await _cacheSnapshot(
      UserProgressSnapshot(
        memorizedAyahCount: memorized,
        reviewedItemsCount: reviewed,
        streakDays: streak,
      ),
      userId: userId,
    );
  }

  @override
  Future<void> saveReviewProgress({
    required String userId,
    required String reviewId,
    required bool reviewed,
    required bool difficult,
  }) async {
    if (!reviewed) return;
    final local = await _cachedSnapshot(userId: userId);
    final reviewedFromDb = await _database.countReviewedItems();
    final nextReviewed = reviewedFromDb > local.reviewedItemsCount
        ? reviewedFromDb
        : local.reviewedItemsCount + 1;
    final streak = await _recordActivity(userId);
    await _cacheSnapshot(
      UserProgressSnapshot(
        memorizedAyahCount: local.memorizedAyahCount,
        reviewedItemsCount: nextReviewed,
        streakDays: streak,
      ),
      userId: userId,
    );
  }

  Future<int> _effectiveStreak(String userId) async {
    final stored =
        int.tryParse(await _getValue(_keyForUser(_streakKey, userId)) ?? '') ??
            0;
    if (stored == 0) return 0;
    final lastRaw = await _getValue(_keyForUser(_lastActivityKey, userId));
    final last = lastRaw != null ? DateTime.tryParse(lastRaw) : null;
    if (last == null) return 0;
    final today = _dateOnly(DateTime.now());
    final lastDay = _dateOnly(last);
    final gap = today.difference(lastDay).inDays;
    if (gap > 1) return 0;
    return stored;
  }

  Future<int> _recordActivity(String userId) async {
    final today = _dateOnly(DateTime.now());
    final lastRaw = await _getValue(_keyForUser(_lastActivityKey, userId));
    final last = lastRaw != null ? DateTime.tryParse(lastRaw) : null;
    var streak =
        int.tryParse(await _getValue(_keyForUser(_streakKey, userId)) ?? '') ??
            0;

    if (last == null) {
      streak = 1;
    } else {
      final lastDay = _dateOnly(last);
      final gap = today.difference(lastDay).inDays;
      if (gap == 0) {
        streak = streak == 0 ? 1 : streak;
      } else if (gap == 1) {
        streak += 1;
      } else {
        streak = 1;
      }
    }

    await _setValue(_keyForUser(_lastActivityKey, userId), today.toIso8601String());
    await _setValue(_keyForUser(_streakKey, userId), streak.toString());
    return streak;
  }

  Future<void> _cacheSnapshot(
    UserProgressSnapshot snapshot, {
    required String userId,
  }) async {
    await _setValue(
      _keyForUser(_streakKey, userId),
      snapshot.streakDays.toString(),
    );
    await _setValue(
      _keyForUser(_reviewCountKey, userId),
      snapshot.reviewedItemsCount.toString(),
    );
  }

  Future<UserProgressSnapshot> _cachedSnapshot({required String userId}) async {
    final progress = await getProgress(userId: userId);
    return progress;
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  String _keyForUser(String key, String userId) => '${key}_$userId';

  Future<String?> _getValue(String key) async {
    final dbValue = await _database.getAppSetting(key);
    if (dbValue != null) return dbValue;
    return _preferences.getString(key);
  }

  Future<void> _setValue(String key, String value) async {
    await _database.setAppSetting(key: key, value: value);
    await _preferences.setString(key, value);
  }
}
