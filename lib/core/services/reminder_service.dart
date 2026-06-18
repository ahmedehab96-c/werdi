abstract interface class ReminderService {
  Future<void> scheduleDailyReminder({
    required String id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  });

  Future<void> cancelReminder({required String id});

  Future<void> cancelAllReminders();
}
