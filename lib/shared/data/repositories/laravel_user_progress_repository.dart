import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/core/network/laravel_api_client.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/core/services/offline_sync_service.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

class LaravelUserProgressRepository implements UserProgressRepository {
  LaravelUserProgressRepository({
    required LaravelApiClient client,
    AppPreferences? preferences,
    OfflineSyncService? syncService,
    AppDatabase? database,
  })  : _client = client,
        _preferences = preferences ?? const SharedPrefsService(),
        _syncService = syncService,
        _database = database;

  final LaravelApiClient _client;
  final AppPreferences _preferences;
  final OfflineSyncService? _syncService;
  final AppDatabase? _database;
  static const _memKey = 'progress_memorized_ayah_count';
  static const _reviewKey = 'progress_reviewed_items_count';
  static const _streakKey = 'progress_streak_days';

  @override
  Future<UserProgressSnapshot> getProgress({required String userId}) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/progress/summary',
        queryParameters: {'user_id': userId},
      );
      final data = response.data ?? <String, dynamic>{};
      final snapshot = UserProgressSnapshot(
        memorizedAyahCount: (data['memorized_ayah_count'] as num? ?? 0).toInt(),
        reviewedItemsCount: (data['reviewed_items_count'] as num? ?? 0).toInt(),
        streakDays: (data['streak_days'] as num? ?? 0).toInt(),
      );
      await _cacheSnapshot(snapshot, userId: userId);
      return snapshot;
    } catch (_) {
      return _cachedSnapshot(userId: userId);
    }
  }

  @override
  Future<void> saveMemorizationProgress({
    required String userId,
    required int surahNumber,
    required int ayahNumber,
    required double progress,
  }) async {
    await _database?.addMemorizationProgress(
      userId: userId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      progress: progress,
    );
    final local = await _cachedSnapshot(userId: userId);
    final memorizedCount =
        await _database?.getMemorizedAyahCount(userId: userId) ??
            (local.memorizedAyahCount + 1);
    final updated = UserProgressSnapshot(
      memorizedAyahCount: memorizedCount,
      reviewedItemsCount: local.reviewedItemsCount,
      streakDays: local.streakDays,
    );
    await _cacheSnapshot(updated, userId: userId);
    try {
      await _client.dio.post<Map<String, dynamic>>(
        '/progress/memorization',
        data: {
          'user_id': userId,
          'surah_number': surahNumber,
          'ayah_number': ayahNumber,
          'progress': progress,
        },
      );
    } catch (_) {
      await _syncService?.enqueue(
        type: 'progress.memorization',
        payload: {
          'user_id': userId,
          'surah_number': surahNumber,
          'ayah_number': ayahNumber,
          'progress': progress,
        },
      );
    }
  }

  @override
  Future<void> saveReviewProgress({
    required String userId,
    required String reviewId,
    required bool reviewed,
    required bool difficult,
  }) async {
    final local = await _cachedSnapshot(userId: userId);
    final updated = UserProgressSnapshot(
      memorizedAyahCount: local.memorizedAyahCount,
      reviewedItemsCount:
          reviewed ? local.reviewedItemsCount + 1 : local.reviewedItemsCount,
      streakDays: local.streakDays,
    );
    await _cacheSnapshot(updated, userId: userId);
    try {
      await _client.dio.post<Map<String, dynamic>>(
        '/progress/review',
        data: {
          'user_id': userId,
          'review_id': reviewId,
          'reviewed': reviewed,
          'difficult': difficult,
        },
      );
    } catch (_) {
      await _syncService?.enqueue(
        type: 'progress.review',
        payload: {
          'user_id': userId,
          'review_id': reviewId,
          'reviewed': reviewed,
          'difficult': difficult,
        },
      );
    }
  }

  Future<void> _cacheSnapshot(
    UserProgressSnapshot snapshot, {
    required String userId,
  }) async {
    await _setValue(_keyForUser(_memKey, userId), snapshot.memorizedAyahCount.toString());
    await _setValue(
      _keyForUser(_reviewKey, userId),
      snapshot.reviewedItemsCount.toString(),
    );
    await _setValue(_keyForUser(_streakKey, userId), snapshot.streakDays.toString());
  }

  Future<UserProgressSnapshot> _cachedSnapshot({required String userId}) async {
    final mem = int.tryParse(
          await _getValue(_keyForUser(_memKey, userId)) ?? '',
        ) ??
        0;
    final review =
        int.tryParse(await _getValue(_keyForUser(_reviewKey, userId)) ?? '') ?? 0;
    final streak =
        int.tryParse(await _getValue(_keyForUser(_streakKey, userId)) ?? '') ?? 0;
    return UserProgressSnapshot(
      memorizedAyahCount: mem,
      reviewedItemsCount: review,
      streakDays: streak,
    );
  }

  String _keyForUser(String key, String userId) => '${key}_$userId';

  Future<String?> _getValue(String key) async {
    final dbValue = await _database?.getAppSetting(key);
    if (dbValue != null) return dbValue;
    return _preferences.getString(key);
  }

  Future<void> _setValue(String key, String value) async {
    await _database?.setAppSetting(key: key, value: value);
    await _preferences.setString(key, value);
  }
}
