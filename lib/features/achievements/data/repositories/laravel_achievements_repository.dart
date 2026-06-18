import 'dart:convert';

import 'package:werdi/core/network/laravel_api_client.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/features/achievements/domain/models/achievement_item.dart';

class LaravelAchievementsRepository {
  const LaravelAchievementsRepository({
    required LaravelApiClient client,
    AppPreferences? preferences,
  })  : _client = client,
        _preferences = preferences ?? const SharedPrefsService();

  final LaravelApiClient _client;
  final AppPreferences _preferences;
  static const _cacheKey = 'achievements_cache_v1';

  Future<({List<AchievementItem> earned, List<AchievementItem> upcoming})>
      getAchievements() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>('/achievements');
      final data = response.data ?? <String, dynamic>{};
      final result = _parseAchievements(data);
      await _cache(result.earned, result.upcoming);
      return result;
    } catch (_) {
      final cached = await _fromCache();
      if (cached != null) return cached;
      return (earned: const <AchievementItem>[], upcoming: const <AchievementItem>[]);
    }
  }

  ({List<AchievementItem> earned, List<AchievementItem> upcoming})
      _parseAchievements(Map<String, dynamic> data) {
    final earned = (data['earned'] as List? ?? [])
        .whereType<Map>()
        .map((e) => AchievementItem(
              key: '${e['key'] ?? ''}',
              title: '${e['title'] ?? ''}',
              earnedAt: e['earned_at'] as String?,
            ))
        .toList();

    final upcoming = (data['upcoming'] as List? ?? [])
        .whereType<Map>()
        .map((e) => AchievementItem(
              key: '${e['key'] ?? ''}',
              title: '${e['title'] ?? ''}',
            ))
        .toList();
    return (earned: earned, upcoming: upcoming);
  }

  Future<void> _cache(
    List<AchievementItem> earned,
    List<AchievementItem> upcoming,
  ) async {
    final payload = jsonEncode({
      'earned': earned
          .map((e) => {'key': e.key, 'title': e.title, 'earned_at': e.earnedAt})
          .toList(),
      'upcoming': upcoming.map((e) => {'key': e.key, 'title': e.title}).toList(),
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
}
