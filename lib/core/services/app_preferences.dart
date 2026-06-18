import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AppPreferences {
  Future<String?> getString(String key);
  Future<bool> setString(String key, String value);
}

class SharedPrefsService implements AppPreferences {
  const SharedPrefsService();

  @override
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<bool> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }
}
