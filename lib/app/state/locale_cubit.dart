import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/core/services/app_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit({AppPreferences? preferences})
      : _preferences = preferences ?? const SharedPrefsService(),
        super(AppConstants.defaultLocale);

  final AppPreferences _preferences;
  static const _key = 'app_locale';

  Future<void> load() async {
    final code = await _preferences.getString(_key);
    if (code == null || code.isEmpty) return;
    emit(Locale(code));
  }

  Future<void> setLocale(String code) async {
    await _preferences.setString(_key, code);
    emit(Locale(code));
  }
}
