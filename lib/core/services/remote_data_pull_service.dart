import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/core/network/supabase_service.dart';
import 'package:werdi/core/sync/sync_capabilities.dart';
import 'package:werdi/features/quran/domain/repositories/bookmark_repository.dart';
import 'package:werdi/features/review/data/repositories/supabase_review_repository.dart';
import 'package:werdi/shared/data/repositories/supabase_user_progress_repository.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

/// Pulls remote user data into local caches after sign-in or reconnect.
class RemoteDataPullService {
  RemoteDataPullService({
    required BookmarkRepository bookmarkRepository,
    required SupabaseUserProgressRepository? progressRepository,
    required SupabaseReviewRepository? reviewRepository,
  })  : _bookmarkRepository = bookmarkRepository,
        _progressRepository = progressRepository,
        _reviewRepository = reviewRepository;

  final BookmarkRepository _bookmarkRepository;
  final SupabaseUserProgressRepository? _progressRepository;
  final SupabaseReviewRepository? _reviewRepository;

  SupabaseClient get _client => SupabaseService.client;

  Future<void> pullIfSignedIn() async {
    if (!canSyncWithSupabase) return;

    await Future.wait([
      _pullUserProgress(),
      _bookmarkRepository.getBookmarks(),
      _pullReviewItems(),
    ]);
  }

  Future<void> _pullUserProgress() async {
    final progressRepo = _progressRepository;
    final remoteUserId = supabaseUserId;
    if (progressRepo == null || remoteUserId == null) return;

    try {
      final row = await _client
          .from('user_progress')
          .select(
            'memorized_ayah_count, reviewed_items_count, streak_days',
          )
          .eq('user_id', remoteUserId)
          .maybeSingle();
      if (row == null) return;

      await progressRepo.cacheRemoteSnapshot(
        localUserId: AppConstants.localUserId,
        snapshot: UserProgressSnapshot(
          memorizedAyahCount:
              (row['memorized_ayah_count'] as num? ?? 0).toInt(),
          reviewedItemsCount:
              (row['reviewed_items_count'] as num? ?? 0).toInt(),
          streakDays: (row['streak_days'] as num? ?? 0).toInt(),
        ),
      );
    } catch (_) {}
  }

  Future<void> _pullReviewItems() async {
    final reviewRepo = _reviewRepository;
    final remoteUserId = supabaseUserId;
    if (reviewRepo == null || remoteUserId == null) return;

    try {
      final rows = await _client
          .from('review_items')
          .select()
          .eq('user_id', remoteUserId);
      for (final row in rows) {
        final map = Map<String, dynamic>.from(row as Map);
        await reviewRepo.mergeRemoteItem(
          SupabaseReviewRepository.mapRemoteRow(map),
        );
      }
    } catch (_) {}
  }
}
