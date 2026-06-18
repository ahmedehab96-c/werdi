import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/core/services/reminder_service.dart';
import 'package:werdi/features/settings/presentation/cubit/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required ReminderService reminderService,
    AppPreferences? preferences,
  })
      : _reminderService = reminderService,
        _preferences = preferences ?? const SharedPrefsService(),
        super(const SettingsState());

  final ReminderService _reminderService;
  final AppPreferences _preferences;
  static const _enabledKey = 'settings_reminders_enabled';
  static const _hourKey = 'settings_reminder_hour';
  static const _minuteKey = 'settings_reminder_minute';
  static const _searchFocusModeKey = 'settings_search_focus_mode';
  static const _unifiedReadingPrefsKey = 'settings_unified_reading_preferences';

  void setFontScale(double scale) => emit(state.copyWith(fontScale: scale));

  Future<void> load() async {
    final enabled = await _preferences.getString(_enabledKey) == '1';
    final hour = int.tryParse(await _preferences.getString(_hourKey) ?? '') ?? 8;
    final minute =
        int.tryParse(await _preferences.getString(_minuteKey) ?? '') ?? 0;
    final focusMode = (await _preferences.getString(_searchFocusModeKey) ?? '1') == '1';
    final unifiedReading =
        (await _preferences.getString(_unifiedReadingPrefsKey) ?? '0') == '1';
    emit(
      state.copyWith(
        remindersEnabled: enabled,
        reminderHour: hour.clamp(0, 23),
        reminderMinute: minute.clamp(0, 59),
        openSearchResultsInFocusMode: focusMode,
        useUnifiedReadingPreferences: unifiedReading,
      ),
    );
  }

  Future<void> setRemindersEnabled(bool enabled) async {
    emit(state.copyWith(remindersEnabled: enabled));
    await _preferences.setString(_enabledKey, enabled ? '1' : '0');
    if (enabled) {
      await _scheduleCurrentReminder();
    } else {
      await _reminderService.cancelReminder(id: 'daily_werdi');
    }
  }

  Future<void> setReminderTime({required int hour, required int minute}) async {
    emit(
      state.copyWith(
        reminderHour: hour.clamp(0, 23),
        reminderMinute: minute.clamp(0, 59),
      ),
    );
    await _preferences.setString(_hourKey, state.reminderHour.toString());
    await _preferences.setString(_minuteKey, state.reminderMinute.toString());
    if (state.remindersEnabled) {
      await _scheduleCurrentReminder();
    }
  }

  Future<void> setSearchFocusMode(bool enabled) async {
    emit(state.copyWith(openSearchResultsInFocusMode: enabled));
    await _preferences.setString(_searchFocusModeKey, enabled ? '1' : '0');
  }

  Future<void> setUnifiedReadingPreferences(bool enabled) async {
    emit(state.copyWith(useUnifiedReadingPreferences: enabled));
    await _preferences.setString(_unifiedReadingPrefsKey, enabled ? '1' : '0');
  }

  Future<void> _scheduleCurrentReminder() async {
    await _reminderService.scheduleDailyReminder(
      id: 'daily_werdi',
      hour: state.reminderHour,
      minute: state.reminderMinute,
      title: 'وردك اليومي',
      body: 'حان وقت مراجعة وردك من القرآن الكريم',
    );
  }
}
