import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/core/services/offline_sync_service.dart';
import '../support/fakes.dart';

void main() {
  test('OfflineSyncService enqueue persists operations in drift queue', () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    final service = OfflineSyncService(
      database: db,
      preferences: FakeAppPreferences(),
    );

    await service.enqueue(
      type: 'review.upsert',
      payload: {
        'id': '1_ayah_1',
        'title': 'test',
        'subtitle': 'test',
        'priority': 'high',
        'reviewed': false,
        'difficult': true,
      },
    );

    final rows = await db.getSyncQueueItems();
    expect(rows, hasLength(1));
    expect(rows.first.type, 'review.upsert');
    expect(rows.first.payload['id'], '1_ayah_1');
  });

  test('OfflineSyncService replaceSyncQueue trims failed replay backlog', () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await db.enqueueSyncOperation(
      type: 'progress.activity',
      payload: {'streak_days': 2},
    );
    await db.enqueueSyncOperation(
      type: 'progress.review',
      payload: {'reviewed_items_count': 3},
    );

    await db.replaceSyncQueueItems([
      (type: 'progress.review', payload: {'reviewed_items_count': 4}),
    ]);

    final rows = await db.getSyncQueueItems();
    expect(rows, hasLength(1));
    expect(rows.first.payload['reviewed_items_count'], 4);
  });
}
