import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/core/services/offline_sync_service.dart';
import 'package:werdi/features/review/data/repositories/supabase_review_repository.dart';
import 'package:werdi/features/review/domain/models/review_item.dart';
import 'package:werdi/features/review/domain/repositories/review_repository.dart';

class InMemoryReviewRepository implements ReviewRepository {
  final List<ReviewItem> items = [];

  @override
  Future<List<ReviewItem>> getReviewItems() async => List.unmodifiable(items);

  @override
  Future<void> upsertItem(ReviewItem item) async {
    final index = items.indexWhere((entry) => entry.id == item.id);
    if (index == -1) {
      items.add(item);
      return;
    }
    items[index] = item;
  }
}

void main() {
  test('mergeRemoteItem keeps newer local copy', () async {
    final local = InMemoryReviewRepository();
    final repo = SupabaseReviewRepository(
      local: local,
      syncService: OfflineSyncService(),
    );

    await local.upsertItem(
      ReviewItem(
        id: 'a',
        title: 'local',
        subtitle: 'local',
        priority: ReviewPriority.high,
        updatedAt: DateTime(2026, 7, 9, 12),
      ),
    );

    await repo.mergeRemoteItem(
      ReviewItem(
        id: 'a',
        title: 'remote',
        subtitle: 'remote',
        priority: ReviewPriority.low,
        updatedAt: DateTime(2026, 7, 8),
      ),
    );

    final items = await local.getReviewItems();
    expect(items.single.title, 'local');
  });

  test('mergeRemoteItem applies newer remote copy', () async {
    final local = InMemoryReviewRepository();
    final repo = SupabaseReviewRepository(
      local: local,
      syncService: OfflineSyncService(),
    );

    await local.upsertItem(
      ReviewItem(
        id: 'a',
        title: 'local',
        subtitle: 'local',
        priority: ReviewPriority.medium,
        updatedAt: DateTime(2026, 7, 8),
      ),
    );

    await repo.mergeRemoteItem(
      ReviewItem(
        id: 'a',
        title: 'remote',
        subtitle: 'remote',
        priority: ReviewPriority.high,
        updatedAt: DateTime(2026, 7, 9),
      ),
    );

    final items = await local.getReviewItems();
    expect(items.single.title, 'remote');
    expect(items.single.priority, ReviewPriority.high);
  });

  test('remotePayload maps review item fields', () {
    final payload = SupabaseReviewRepository.remotePayload(
      const ReviewItem(
        id: '2_ayah_3',
        title: 'سورة البقرة',
        subtitle: 'آية صعبة',
        priority: ReviewPriority.high,
        surahNumber: 2,
        ayahStart: 3,
        ayahEnd: 3,
        difficult: true,
      ),
      userId: 'user-1',
    );

    expect(payload['user_id'], 'user-1');
    expect(payload['id'], '2_ayah_3');
    expect(payload['difficult'], isTrue);
    expect(payload['priority'], 'high');
  });
}
