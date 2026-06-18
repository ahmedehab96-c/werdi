import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/features/review/domain/models/review_item.dart';
import 'package:werdi/features/review/domain/repositories/review_repository.dart';

class DriftReviewRepository implements ReviewRepository {
  DriftReviewRepository({required AppDatabase database}) : _database = database;

  final AppDatabase _database;
  static const _legacyStorageKey = 'review_items_v2';
  bool _migrationDone = false;

  @override
  Future<List<ReviewItem>> getReviewItems() async {
    await _migrateLegacyIfNeeded();
    final rows = await _database.getReviewItems();
    return rows.map(_mapRowToDomain).toList();
  }

  @override
  Future<void> upsertItem(ReviewItem item) async {
    await _migrateLegacyIfNeeded();
    await _database.upsertReviewItem(
      id: item.id,
      title: item.title,
      subtitle: item.subtitle,
      priority: item.priority.name,
      surahNumber: item.surahNumber,
      ayahStart: item.ayahStart,
      ayahEnd: item.ayahEnd,
      reviewed: item.reviewed,
      difficult: item.difficult,
    );
  }

  Future<void> _migrateLegacyIfNeeded() async {
    if (_migrationDone) return;
    _migrationDone = true;

    final current = await _database.countReviewItems();
    if (current > 0) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_legacyStorageKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      final legacy = decoded
          .whereType<Map<String, dynamic>>()
          .map(ReviewItem.fromJson)
          .toList();
      if (legacy.isEmpty) return;

      for (final item in legacy) {
        await _database.upsertReviewItem(
          id: item.id,
          title: item.title,
          subtitle: item.subtitle,
          priority: item.priority.name,
          surahNumber: item.surahNumber,
          ayahStart: item.ayahStart,
          ayahEnd: item.ayahEnd,
          reviewed: item.reviewed,
          difficult: item.difficult,
        );
      }
    } catch (_) {
      // Ignore malformed legacy payload and continue with clean DB.
    }
  }

  ReviewItem _mapRowToDomain(QueryRow row) {
    return ReviewItem(
      id: row.read<String>('id'),
      title: row.read<String>('title'),
      subtitle: row.read<String>('subtitle'),
      priority: _mapPriority(row.read<String>('priority')),
      surahNumber: row.read<int>('surah_number'),
      ayahStart: row.read<int>('ayah_start'),
      ayahEnd: row.read<int>('ayah_end'),
      reviewed: row.read<int>('reviewed') == 1,
      difficult: row.read<int>('difficult') == 1,
    );
  }

  ReviewPriority _mapPriority(String value) {
    return switch (value) {
      'high' => ReviewPriority.high,
      'low' => ReviewPriority.low,
      _ => ReviewPriority.medium,
    };
  }
}
