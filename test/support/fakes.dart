import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/core/services/reminder_service.dart';

/// In-memory [AppPreferences] for tests, with no platform dependency.
class FakeAppPreferences implements AppPreferences {
  FakeAppPreferences([Map<String, String>? seed])
      : _store = {...?seed};

  final Map<String, String> _store;

  @override
  Future<String?> getString(String key) async => _store[key];

  @override
  Future<bool> setString(String key, String value) async {
    _store[key] = value;
    return true;
  }
}

/// Records reminder interactions so tests can assert on them.
class FakeReminderService implements ReminderService {
  final List<String> scheduledIds = [];
  final List<String> cancelledIds = [];
  bool cancelledAll = false;

  @override
  Future<void> scheduleDailyReminder({
    required String id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    scheduledIds.add(id);
  }

  @override
  Future<void> cancelReminder({required String id}) async {
    cancelledIds.add(id);
  }

  @override
  Future<void> cancelAllReminders() async {
    cancelledAll = true;
  }
}
