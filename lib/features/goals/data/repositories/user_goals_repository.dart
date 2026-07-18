import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/features/goals/domain/models/user_goals.dart';

class UserGoalsRepository {
  UserGoalsRepository({required AppPreferences preferences})
      : _preferences = preferences;

  final AppPreferences _preferences;
  UserGoals _cache = const UserGoals();

  UserGoals get cached => _cache;

  Future<UserGoals> load() async {
    final raw = await _preferences.getString(UserGoals.storageKey);
    _cache = UserGoals.decode(raw);
    return _cache;
  }

  Future<UserGoals> save(UserGoals goals) async {
    _cache = goals;
    await _preferences.setString(UserGoals.storageKey, goals.encode());
    return _cache;
  }

  Future<UserGoals> updateDailyTarget(int ayahs) {
    return save(
      _cache.copyWith(dailyTargetAyahs: ayahs.clamp(1, 200)),
    );
  }

  Future<UserGoals> updateMemorizationGoal(int ayahs) {
    return save(
      _cache.copyWith(memorizationGoalAyahs: ayahs.clamp(10, 6236)),
    );
  }

  Future<UserGoals> updateReviewGoal(int sessions) {
    return save(
      _cache.copyWith(reviewSessionsGoal: sessions.clamp(1, 500)),
    );
  }

  Future<UserGoals> addCustomGoal(UserCustomGoal goal) {
    final trimmed = goal.title.trim();
    if (trimmed.isEmpty) return Future.value(_cache);
    final next = List<UserCustomGoal>.from(_cache.customGoals)
      ..add(goal.copyWith(title: trimmed));
    return save(_cache.copyWith(customGoals: next));
  }

  Future<UserGoals> removeCustomGoal(String id) {
    final next =
        _cache.customGoals.where((g) => g.id != id).toList(growable: false);
    return save(_cache.copyWith(customGoals: next));
  }
}
