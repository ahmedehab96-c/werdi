import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/core/services/reminder_service.dart';
import 'package:werdi/features/achievements/domain/models/achievement_item.dart';
import 'package:werdi/features/achievements/domain/repositories/achievements_repository.dart';
import 'package:werdi/features/home/domain/services/home_dashboard_service.dart';
import 'package:werdi/features/review/domain/models/review_item.dart';
import 'package:werdi/features/review/domain/repositories/review_repository.dart';
import 'package:werdi/features/tasmee3/domain/models/tasmee3_session.dart';
import 'package:werdi/features/tasmee3/domain/repositories/tasmee3_repository.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

/// In-memory [AppPreferences] for tests, with no platform dependency.
class FakeAppPreferences implements AppPreferences {
  FakeAppPreferences([Map<String, String>? seed]) : _store = {...?seed};

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

class FakeUserProgressRepository implements UserProgressRepository {
  FakeUserProgressRepository({
    this.snapshot = const UserProgressSnapshot(
      memorizedAyahCount: 12,
      reviewedItemsCount: 4,
      streakDays: 3,
    ),
  });

  UserProgressSnapshot snapshot;

  @override
  Future<UserProgressSnapshot> getProgress({required String userId}) async {
    return snapshot;
  }

  @override
  Future<void> recordActivity({required String userId}) async {}

  @override
  Future<void> saveMemorizationProgress({
    required String userId,
    required int surahNumber,
    required int ayahNumber,
    required double progress,
  }) async {}

  @override
  Future<void> saveReviewProgress({
    required String userId,
    required String reviewId,
    required bool reviewed,
    required bool difficult,
  }) async {}
}

class FakeReviewRepository implements ReviewRepository {
  @override
  Future<List<ReviewItem>> getReviewItems() async => const [];

  @override
  Future<void> upsertItem(ReviewItem item) async {}
}

class FakeAchievementsRepository implements AchievementsRepository {
  @override
  Future<({List<AchievementItem> earned, List<AchievementItem> upcoming})>
      evaluateFromMetrics({
    required int memorizedAyahCount,
    required int reviewedItemsCount,
    required int streakDays,
    required int tasmee3Sessions,
  }) async {
    return (earned: const <AchievementItem>[], upcoming: const <AchievementItem>[]);
  }

  @override
  Future<({List<AchievementItem> earned, List<AchievementItem> upcoming})>
      getAchievements() async {
    return (earned: const <AchievementItem>[], upcoming: const <AchievementItem>[]);
  }
}

class FakeTasmee3Repository implements Tasmee3Repository {
  @override
  Future<List<Tasmee3Session>> getHistory() async => const [];

  @override
  Future<void> saveSession(Tasmee3Session session) async {}
}

class FakeHomeDashboardService extends HomeDashboardService {
  FakeHomeDashboardService({
    required super.goalsRepository,
    AppDatabase? database,
    HomeDashboardSnapshot? snapshot,
    this.shouldThrow = false,
  })  : _snapshot = snapshot ?? HomeDashboardSnapshot.fallback(),
        super(
          progressRepository: FakeUserProgressRepository(),
          reviewRepository: FakeReviewRepository(),
          achievementsRepository: FakeAchievementsRepository(),
          tasmee3Repository: FakeTasmee3Repository(),
          database: database ?? AppDatabase.inMemory(),
          preferences: FakeAppPreferences(),
        );

  final HomeDashboardSnapshot _snapshot;
  bool shouldThrow;
  int loadCalls = 0;

  @override
  Future<HomeDashboardSnapshot> load() async {
    loadCalls++;
    if (shouldThrow) {
      throw StateError('dashboard_failed');
    }
    return _snapshot;
  }
}
