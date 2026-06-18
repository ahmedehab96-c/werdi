import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/features/settings/presentation/cubit/settings_cubit.dart';

import '../support/fakes.dart';

void main() {
  group('SettingsCubit', () {
    test('setFontScale() updates the font scale', () {
      final cubit = SettingsCubit(
        reminderService: FakeReminderService(),
        preferences: FakeAppPreferences(),
      );

      cubit.setFontScale(1.2);

      expect(cubit.state.fontScale, 1.2);
    });

    test('enabling reminders schedules the daily reminder', () async {
      final reminders = FakeReminderService();
      final cubit = SettingsCubit(
        reminderService: reminders,
        preferences: FakeAppPreferences(),
      );

      await cubit.setRemindersEnabled(true);

      expect(cubit.state.remindersEnabled, isTrue);
      expect(reminders.scheduledIds, contains('daily_werdi'));
    });

    test('disabling reminders cancels the daily reminder', () async {
      final reminders = FakeReminderService();
      final cubit = SettingsCubit(
        reminderService: reminders,
        preferences: FakeAppPreferences(),
      );

      await cubit.setRemindersEnabled(false);

      expect(cubit.state.remindersEnabled, isFalse);
      expect(reminders.cancelledIds, contains('daily_werdi'));
    });
  });
}
