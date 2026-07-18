import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/core/network/supabase_service.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/core/services/offline_sync_service.dart';
import 'package:werdi/core/sync/sync_capabilities.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

class SupabaseUserProgressRepository implements UserProgressRepository {
  SupabaseUserProgressRepository({
    AppPreferences? preferences,
    OfflineSyncService? syncService,
    AppDatabase? database,
  })  : _preferences = preferences ?? const SharedPrefsService(),
        _syncService = syncService,
        _database = database;

  final AppPreferences _preferences;
  final OfflineSyncService? _syncService;
  final AppDatabase? _database;
  static const _memKey = 'progress_memorized_ayah_count';
  static const _reviewKey = 'progress_reviewed_items_count';
  static const _streakKey = 'progress_streak_days';

  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<UserProgressSnapshot> getProgress({required String userId}) async {
    if (!canSyncWithSupabase) {
      return _cachedSnapshot(userId: userId);
    }

    final remoteUserId = supabaseUserId;
    if (remoteUserId == null) {
      return _cachedSnapshot(userId: userId);
    }

    try {
      final row = await _client
          .from('user_progress')
          .select(
            'memorized_ayah_count, reviewed_items_count, streak_days',
          )
          .eq('user_id', remoteUserId)
          .maybeSingle();
      final remoteMem =
          (row?['memorized_ayah_count'] as num? ?? 0).toInt();
      final remoteReview =
          (row?['reviewed_items_count'] as num? ?? 0).toInt();
      final remoteStreak = (row?['streak_days'] as num? ?? 0).toInt();

      final lastRaw = await _getValue(_keyForUser(_lastActivityKey, userId));
      final last = lastRaw != null ? DateTime.tryParse(lastRaw) : null;
      final localFresh = last != null &&
          _dateOnly(DateTime.now()).difference(_dateOnly(last)).inDays <= 1;

      final int streakDays;
      if (localFresh) {
        // Prefer local streak when the user was active today/yesterday.
        streakDays = await _effectiveStreak(userId);
      } else {
        await _setValue(
          _keyForUser(_streakKey, userId),
          remoteStreak.toString(),
        );
        streakDays =
            await _effectiveStreak(userId, fallback: remoteStreak);
      }

      final snapshot = UserProgressSnapshot(
        memorizedAyahCount: remoteMem,
        reviewedItemsCount: remoteReview,
        streakDays: streakDays,
      );
      await _cacheSnapshot(snapshot, userId: userId);
      return snapshot;
    } catch (_) {
      return _cachedSnapshot(userId: userId);
    }
  }

  Future<void> cacheRemoteSnapshot({
    required String localUserId,
    required UserProgressSnapshot snapshot,
  }) async {
    await _cacheSnapshot(snapshot, userId: localUserId);
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
    final streak = await _recordActivity(userId);
    final updated = UserProgressSnapshot(
      memorizedAyahCount: memorizedCount,
      reviewedItemsCount: local.reviewedItemsCount,
      streakDays: streak,
    );
    await _cacheSnapshot(updated, userId: userId);

    if (!canSyncWithSupabase) return;

    final remoteUserId = supabaseUserId;
    if (remoteUserId == null) return;

    try {
      await _client.from('user_progress').upsert({
        'user_id': remoteUserId,
        'memorized_ayah_count': memorizedCount,
        'reviewed_items_count': local.reviewedItemsCount,
        'streak_days': streak,
        'last_surah_number': surahNumber,
        'last_ayah_number': ayahNumber,
        'last_progress': progress,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      await _syncService?.enqueue(
        type: 'progress.memorization',
        payload: {
          'memorized_ayah_count': memorizedCount,
          'reviewed_items_count': local.reviewedItemsCount,
          'streak_days': streak,
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
    if (!reviewed) return;
    final local = await _cachedSnapshot(userId: userId);
    final streak = await _recordActivity(userId);
    final updated = UserProgressSnapshot(
      memorizedAyahCount: local.memorizedAyahCount,
      reviewedItemsCount: local.reviewedItemsCount + 1,
      streakDays: streak,
    );
    await _cacheSnapshot(updated, userId: userId);

    if (!canSyncWithSupabase) return;

    final remoteUserId = supabaseUserId;
    if (remoteUserId == null) return;

    try {
      await _client.from('user_progress').upsert({
        'user_id': remoteUserId,
        'memorized_ayah_count': updated.memorizedAyahCount,
        'reviewed_items_count': updated.reviewedItemsCount,
        'streak_days': updated.streakDays,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      await _syncService?.enqueue(
        type: 'progress.review',
        payload: {
          'memorized_ayah_count': updated.memorizedAyahCount,
          'reviewed_items_count': updated.reviewedItemsCount,
          'streak_days': updated.streakDays,
          'review_id': reviewId,
          'reviewed': reviewed,
          'difficult': difficult,
        },
      );
    }
  }

  @override
  Future<void> recordActivity({required String userId}) async {
    final streak = await _recordActivity(userId);
    final local = await _cachedSnapshot(userId: userId);
    await _cacheSnapshot(
      UserProgressSnapshot(
        memorizedAyahCount: local.memorizedAyahCount,
        reviewedItemsCount: local.reviewedItemsCount,
        streakDays: streak,
      ),
      userId: userId,
    );
    if (!canSyncWithSupabase) return;

    final remoteUserId = supabaseUserId;
    if (remoteUserId == null) return;

    try {
      await _client.from('user_progress').upsert({
        'user_id': remoteUserId,
        'memorized_ayah_count': local.memorizedAyahCount,
        'reviewed_items_count': local.reviewedItemsCount,
        'streak_days': streak,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      await _syncService?.enqueue(
        type: 'progress.activity',
        payload: {
          'memorized_ayah_count': local.memorizedAyahCount,
          'reviewed_items_count': local.reviewedItemsCount,
          'streak_days': streak,
        },
      );
    }
  }

  Future<int> _effectiveStreak(
    String userId, {
    int? fallback,
  }) async {
    final stored = int.tryParse(
          await _getValue(_keyForUser(_streakKey, userId)) ?? '',
        ) ??
        fallback ??
        0;
    if (stored == 0) return 0;
    final lastRaw = await _getValue(_keyForUser(_lastActivityKey, userId));
    final last = lastRaw != null ? DateTime.tryParse(lastRaw) : null;
    if (last == null) {
      // Remote seed without local activity day — keep stored value until
      // the user is active, then expiry rules apply.
      return stored;
    }
    final gap = _dateOnly(DateTime.now()).difference(_dateOnly(last)).inDays;
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
      final gap = today.difference(_dateOnly(last)).inDays;
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

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static const _lastActivityKey = 'progress_last_activity_date';

  Future<void> _cacheSnapshot(
    UserProgressSnapshot snapshot, {
    required String userId,
  }) async {
    await _setValue(
      _keyForUser(_memKey, userId),
      snapshot.memorizedAyahCount.toString(),
    );
    await _setValue(
      _keyForUser(_reviewKey, userId),
      snapshot.reviewedItemsCount.toString(),
    );
    await _setValue(
      _keyForUser(_streakKey, userId),
      snapshot.streakDays.toString(),
    );
  }

  Future<UserProgressSnapshot> _cachedSnapshot({required String userId}) async {
    final mem = int.tryParse(
          await _getValue(_keyForUser(_memKey, userId)) ?? '',
        ) ??
        0;
    final review =
        int.tryParse(await _getValue(_keyForUser(_reviewKey, userId)) ?? '') ??
            0;
    final streak = await _effectiveStreak(userId);
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
