import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/app/state/theme_cubit.dart';

import '../support/fakes.dart';

void main() {
  group('ThemeCubit', () {
    test('starts in system mode', () {
      final cubit = ThemeCubit(preferences: FakeAppPreferences());
      expect(cubit.state, ThemeMode.system);
    });

    test('load() restores the persisted dark mode', () async {
      final cubit = ThemeCubit(
        preferences: FakeAppPreferences({'app_theme': 'dark'}),
      );

      await cubit.load();

      expect(cubit.state, ThemeMode.dark);
    });

    test('load() keeps system mode when nothing is stored', () async {
      final cubit = ThemeCubit(preferences: FakeAppPreferences());

      await cubit.load();

      expect(cubit.state, ThemeMode.system);
    });

    test('setTheme() persists and emits the new mode', () async {
      final prefs = FakeAppPreferences();
      final cubit = ThemeCubit(preferences: prefs);

      await cubit.setTheme(ThemeMode.light);

      expect(cubit.state, ThemeMode.light);
      expect(await prefs.getString('app_theme'), 'light');
    });
  });
}
