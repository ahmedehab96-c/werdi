import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:werdi/features/review/domain/models/review_item.dart';
import 'package:werdi/features/review/domain/repositories/review_repository.dart';

class LocalReviewRepository implements ReviewRepository {
  static const _storageKey = 'review_items_v2';

  @override
  Future<List<ReviewItem>> getReviewItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final items = list
          .whereType<Map<String, dynamic>>()
          .map(ReviewItem.fromJson)
          .toList();
      return items;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> upsertItem(ReviewItem item) async {
    final items = await getReviewItems();
    final idx = items.indexWhere((i) => i.id == item.id);
    final updated = List<ReviewItem>.from(items);
    if (idx >= 0) {
      updated[idx] = item;
    } else {
      updated.insert(0, item);
    }
    await _persist(updated);
  }

  Future<void> _persist(List<ReviewItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }
}

typedef ReviewRepositoryImpl = LocalReviewRepository;
