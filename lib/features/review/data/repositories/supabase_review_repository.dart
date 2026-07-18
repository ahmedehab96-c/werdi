import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:werdi/core/network/supabase_service.dart';
import 'package:werdi/core/services/offline_sync_service.dart';
import 'package:werdi/core/sync/sync_capabilities.dart';
import 'package:werdi/features/review/domain/models/review_item.dart';
import 'package:werdi/features/review/domain/repositories/review_repository.dart';

/// Local-first review storage with optional Supabase sync.
class SupabaseReviewRepository implements ReviewRepository {
  SupabaseReviewRepository({
    required ReviewRepository local,
    required OfflineSyncService syncService,
  })  : _local = local,
        _syncService = syncService;

  final ReviewRepository _local;
  final OfflineSyncService _syncService;

  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<List<ReviewItem>> getReviewItems() => _local.getReviewItems();

  @override
  Future<void> upsertItem(ReviewItem item) async {
    await _local.upsertItem(item);
    if (!canSyncWithSupabase) return;

    try {
      await _remoteUpsert(item);
    } catch (_) {
      await _syncService.enqueue(
        type: 'review.upsert',
        payload: remotePayload(item),
      );
    }
  }

  Future<void> mergeRemoteItem(ReviewItem remote) async {
    final locals = await _local.getReviewItems();
    final existing = locals.where((item) => item.id == remote.id).firstOrNull;
    if (existing == null) {
      await _local.upsertItem(remote);
      return;
    }

    final remoteAt = remote.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final localAt = existing.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    if (!remoteAt.isBefore(localAt)) {
      await _local.upsertItem(remote);
    }
  }

  Future<void> _remoteUpsert(ReviewItem item) async {
    final userId = supabaseUserId;
    if (userId == null) return;

    await _client.from('review_items').upsert(
      remotePayload(item, userId: userId),
      onConflict: 'user_id,id',
    );
  }

  static Map<String, dynamic> remotePayload(
    ReviewItem item, {
    String? userId,
  }) {
    return {
      'user_id': ?userId,
      'id': item.id,
      'title': item.title,
      'subtitle': item.subtitle,
      'priority': item.priority.name,
      'surah_number': item.surahNumber,
      'ayah_start': item.ayahStart,
      'ayah_end': item.ayahEnd,
      'reviewed': item.reviewed,
      'difficult': item.difficult,
      'updated_at': (item.updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  static ReviewItem mapRemoteRow(Map<String, dynamic> row) {
    final priority = switch ('${row['priority'] ?? 'medium'}') {
      'high' => ReviewPriority.high,
      'low' => ReviewPriority.low,
      _ => ReviewPriority.medium,
    };
    return ReviewItem(
      id: '${row['id'] ?? ''}',
      title: '${row['title'] ?? ''}',
      subtitle: '${row['subtitle'] ?? ''}',
      priority: priority,
      surahNumber: (row['surah_number'] as num?)?.toInt(),
      ayahStart: (row['ayah_start'] as num?)?.toInt(),
      ayahEnd: (row['ayah_end'] as num?)?.toInt(),
      reviewed: row['reviewed'] as bool? ?? false,
      difficult: row['difficult'] as bool? ?? false,
      updatedAt: DateTime.tryParse('${row['updated_at'] ?? ''}'),
    );
  }
}

