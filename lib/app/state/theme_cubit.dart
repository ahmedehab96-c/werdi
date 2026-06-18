import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/services/app_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({AppPreferences? preferences})
      : _preferences = preferences ?? const SharedPrefsService(),
        super(ThemeMode.system);

  final AppPreferences _preferences;
  static const _key = 'app_theme';

  Future<void> load() async {
    final raw = await _preferences.getString(_key);
    if (raw == null) return;

    switch (raw) {
      case 'light':
        emit(ThemeMode.light);
      case 'dark':
        emit(ThemeMode.dark);
      default:
        emit(ThemeMode.system);
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _preferences.setString(_key, mode.name);
    emit(mode);
  }
}
