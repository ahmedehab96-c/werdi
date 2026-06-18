import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/app/state/locale_cubit.dart';

import '../support/fakes.dart';

void main() {
  group('LocaleCubit', () {
    test('defaults to Arabic', () {
      final cubit = LocaleCubit(preferences: FakeAppPreferences());
      expect(cubit.state, const Locale('ar'));
    });

    test('load() restores the persisted locale', () async {
      final cubit = LocaleCubit(
        preferences: FakeAppPreferences({'app_locale': 'en'}),
      );

      await cubit.load();

      expect(cubit.state, const Locale('en'));
    });

    test('setLocale() persists and emits the new locale', () async {
      final prefs = FakeAppPreferences();
      final cubit = LocaleCubit(preferences: prefs);

      await cubit.setLocale('en');

      expect(cubit.state, const Locale('en'));
      expect(await prefs.getString('app_locale'), 'en');
    });
  });
}
