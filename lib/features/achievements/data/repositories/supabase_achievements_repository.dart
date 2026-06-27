import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:werdi/core/network/supabase_service.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/features/achievements/domain/models/achievement_item.dart';
import 'package:werdi/features/achievements/domain/repositories/achievements_repository.dart';

class SupabaseAchievementsRepository implements AchievementsRepository {
  const SupabaseAchievementsRepository({AppPreferences? preferences})
      : _preferences = preferences ?? const SharedPrefsService();

  final AppPreferences _preferences;
  static const _cacheKey = 'achievements_cache_v1';

  static const _badges = <Map<String, dynamic>>[
    {
      'key': 'first_100_ayahs',
      'title': 'أول 100 آية',
      'threshold': 100,
      'metric': 'memorized_ayah_count',
    },
    {
      'key': 'first_300_ayahs',
      'title': 'أول 300 آية',
      'threshold': 300,
      'metric': 'memorized_ayah_count',
    },
    {
      'key': 'streak_7',
      'title': '7 أيام التزام',
      'threshold': 7,
      'metric': 'streak_days',
    },
    {
      'key': 'streak_30',
      'title': '30 يوماً التزام',
      'threshold': 30,
      'metric': 'streak_days',
    },
    {
      'key': 'tasmee3_5',
      'title': '5 جلسات تسميع',
      'threshold': 5,
      'metric': 'tasmee3_sessions',
    },
    {
      'key': 'review_15',
      'title': '15 مراجعة',
      'threshold': 15,
      'metric': 'reviewed_items_count',
    },
  ];

  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<({List<AchievementItem> earned, List<AchievementItem> upcoming})>
      getAchievements() async {
    if (!SupabaseService.isReady || !SupabaseService.hasSession) {
      final cached = await _fromCache();
      if (cached != null) return cached;
      return (
        earned: const <AchievementItem>[],
        upcoming: _upcomingFromKeys(const <String>{}),
      );
    }

    try {
      final userId = SupabaseService.currentUserId!;
      await _awardEligible(userId);
      final rows = await _client
          .from('achievements')
          .select('key, title, earned_at')
          .eq('user_id', userId)
          .order('earned_at');
      final earned = rows
          .map(
            (row) => AchievementItem(
              key: '${row['key'] ?? ''}',
              title: '${row['title'] ?? ''}',
              earnedAt: row['earned_at']?.toString(),
            ),
          )
          .toList();
      final earnedKeys = earned.map((e) => e.key).toSet();
      final upcoming = _upcomingFromKeys(earnedKeys);
      await _cache(earned, upcoming);
      return (earned: earned, upcoming: upcoming);
    } catch (_) {
      final cached = await _fromCache();
      if (cached != null) return cached;
      return (
        earned: const <AchievementItem>[],
        upcoming: _upcomingFromKeys(const <String>{}),
      );
    }
  }

  Future<void> _awardEligible(String userId) async {
    final progress = await _client
        .from('user_progress')
        .select(
          'memorized_ayah_count, reviewed_items_count, streak_days',
        )
        .eq('user_id', userId)
        .maybeSingle();

    final metrics = <String, int>{
      'memorized_ayah_count':
          (progress?['memorized_ayah_count'] as num? ?? 0).toInt(),
      'reviewed_items_count':
          (progress?['reviewed_items_count'] as num? ?? 0).toInt(),
      'streak_days': (progress?['streak_days'] as num? ?? 0).toInt(),
      'tasmee3_sessions': 0,
    };

    for (final badge in _badges) {
      final metric = badge['metric'] as String;
      final threshold = (badge['threshold'] as num).toInt();
      final value = metrics[metric] ?? 0;
      if (value < threshold) continue;
      await _client.from('achievements').upsert({
        'user_id': userId,
        'key': badge['key'],
        'title': badge['title'],
      });
    }
  }

  List<AchievementItem> _upcomingFromKeys(Set<String> earnedKeys) {
    return _badges
        .where((badge) => !earnedKeys.contains(badge['key']))
        .map(
          (badge) => AchievementItem(
            key: '${badge['key']}',
            title: '${badge['title']}',
          ),
        )
        .toList();
  }

  Future<void> _cache(
    List<AchievementItem> earned,
    List<AchievementItem> upcoming,
  ) async {
    final payload = jsonEncode({
      'earned': earned
          .map((e) => {'key': e.key, 'title': e.title, 'earned_at': e.earnedAt})
          .toList(),
      'upcoming':
          upcoming.map((e) => {'key': e.key, 'title': e.title}).toList(),
    });
    await _preferences.setString(_cacheKey, payload);
  }

  Future<({List<AchievementItem> earned, List<AchievementItem> upcoming})?>
      _fromCache() async {
    final raw = await _preferences.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      return _parseAchievements(json);
    } catch (_) {
      return null;
    }
  }

  ({List<AchievementItem> earned, List<AchievementItem> upcoming})
      _parseAchievements(Map<String, dynamic> data) {
    final earned = (data['earned'] as List? ?? [])
        .whereType<Map>()
        .map(
          (e) => AchievementItem(
            key: '${e['key'] ?? ''}',
            title: '${e['title'] ?? ''}',
            earnedAt: e['earned_at'] as String?,
          ),
        )
        .toList();

    final upcoming = (data['upcoming'] as List? ?? [])
        .whereType<Map>()
        .map(
          (e) => AchievementItem(
            key: '${e['key'] ?? ''}',
            title: '${e['title'] ?? ''}',
          ),
        )
        .toList();
    return (earned: earned, upcoming: upcoming);
  }
}
