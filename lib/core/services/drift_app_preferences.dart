import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/core/services/app_preferences.dart';

class DriftAppPreferences implements AppPreferences {
  DriftAppPreferences({
    required AppDatabase database,
    AppPreferences? fallback,
  })  : _database = database,
        _fallback = fallback ?? const SharedPrefsService();

  final AppDatabase _database;
  final AppPreferences _fallback;

  @override
  Future<String?> getString(String key) async {
    final value = await _database.getAppSetting(key);
    if (value != null) return value;

    final fallbackValue = await _fallback.getString(key);
    if (fallbackValue != null) {
      await _database.setAppSetting(key: key, value: fallbackValue);
    }
    return fallbackValue;
  }

  @override
  Future<bool> setString(String key, String value) async {
    await _database.setAppSetting(key: key, value: value);
    await _fallback.setString(key, value);
    return true;
  }
}
