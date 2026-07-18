import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/features/memorization/domain/services/memorization_analytics_service.dart';

void main() {
  test('MemorizationAnalyticsService aggregates counts', () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await db.ensureInitialized();
    await db.addMemorizationProgress(
      userId: 'local',
      surahNumber: 1,
      ayahNumber: 1,
      progress: 1,
    );
    await db.upsertReviewItem(
      id: 'r1',
      title: 'test',
      subtitle: 'test',
      priority: 'high',
      surahNumber: 1,
      ayahStart: 1,
      ayahEnd: 1,
      reviewed: false,
      difficult: true,
    );

    final service = MemorizationAnalyticsService(database: db);
    final snapshot = await service.load();

    expect(snapshot.todayAyahs, greaterThanOrEqualTo(1));
    expect(snapshot.difficultItems, 1);
    expect(snapshot.last7Days, hasLength(7));
  });
}
