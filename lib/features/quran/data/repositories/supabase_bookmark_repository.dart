import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/core/network/supabase_service.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/core/services/offline_sync_service.dart';
import 'package:werdi/features/quran/domain/repositories/bookmark_repository.dart';
import 'package:werdi/features/quran/presentation/cubit/quran_state.dart';

class SupabaseBookmarkRepository implements BookmarkRepository {
  const SupabaseBookmarkRepository({
    AppPreferences? preferences,
    OfflineSyncService? syncService,
    AppDatabase? database,
  })  : _preferences = preferences ?? const SharedPrefsService(),
        _syncService = syncService,
        _database = database;

  final AppPreferences _preferences;
  final OfflineSyncService? _syncService;
  final AppDatabase? _database;
  static const _cacheKey = 'bookmarks_cache_v1';
  static const _legacyMigratedKey = 'bookmarks_cache_v1_migrated_to_drift';

  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<({Set<int> surahIds, List<AyahBookmark> ayahs})> getBookmarks() async {
    if (!_canSyncRemote) {
      final cached = await _fromCache();
      return cached ?? (surahIds: <int>{}, ayahs: const <AyahBookmark>[]);
    }

    try {
      final rows = await _client
          .from('bookmarks')
          .select('type, surah_number, ayah_number, preview_text')
          .eq('user_id', SupabaseService.currentUserId!);
      final parsed = _parseRows(rows);
      await _cache(parsed.surahIds, parsed.ayahs);
      return parsed;
    } catch (_) {
      final cached = await _fromCache();
      return cached ?? (surahIds: <int>{}, ayahs: const <AyahBookmark>[]);
    }
  }

  @override
  Future<bool> toggleSurah(int surahNumber) async {
    final current = await getBookmarks();
    final surahs = Set<int>.from(current.surahIds);
    final nowBookmarked = !surahs.contains(surahNumber);
    if (nowBookmarked) {
      surahs.add(surahNumber);
    } else {
      surahs.remove(surahNumber);
    }
    await _cache(surahs, current.ayahs);

    if (!_canSyncRemote) return nowBookmarked;

    try {
      if (nowBookmarked) {
        await _client.from('bookmarks').insert({
          'user_id': SupabaseService.currentUserId,
          'type': 'surah',
          'surah_number': surahNumber,
        });
      } else {
        await _client
            .from('bookmarks')
            .delete()
            .eq('user_id', SupabaseService.currentUserId!)
            .eq('type', 'surah')
            .eq('surah_number', surahNumber);
      }
      return nowBookmarked;
    } catch (_) {
      await _syncService?.enqueue(
        type: 'bookmark.toggle_surah',
        payload: {'surah_number': surahNumber},
      );
      return nowBookmarked;
    }
  }

  @override
  Future<bool> toggleAyah({
    required int surahNumber,
    required int ayahNumber,
    required String previewText,
  }) async {
    final current = await getBookmarks();
    final ayahs = List<AyahBookmark>.from(current.ayahs);
    final existingIndex = ayahs.indexWhere(
      (a) => a.surahNumber == surahNumber && a.ayahNumber == ayahNumber,
    );
    final nowBookmarked = existingIndex == -1;
    if (nowBookmarked) {
      ayahs.add(
        AyahBookmark(
          surahNumber: surahNumber,
          surahNameArabic: '',
          ayahNumber: ayahNumber,
          previewText: previewText,
        ),
      );
    } else {
      ayahs.removeAt(existingIndex);
    }
    await _cache(current.surahIds, ayahs);

    if (!_canSyncRemote) return nowBookmarked;

    try {
      if (nowBookmarked) {
        await _client.from('bookmarks').insert({
          'user_id': SupabaseService.currentUserId,
          'type': 'ayah',
          'surah_number': surahNumber,
          'ayah_number': ayahNumber,
          'preview_text': previewText,
        });
      } else {
        await _client
            .from('bookmarks')
            .delete()
            .eq('user_id', SupabaseService.currentUserId!)
            .eq('type', 'ayah')
            .eq('surah_number', surahNumber)
            .eq('ayah_number', ayahNumber);
      }
      return nowBookmarked;
    } catch (_) {
      await _syncService?.enqueue(
        type: 'bookmark.toggle_ayah',
        payload: {
          'surah_number': surahNumber,
          'ayah_number': ayahNumber,
          'preview_text': previewText,
        },
      );
      return nowBookmarked;
    }
  }

  bool get _canSyncRemote =>
      SupabaseService.isReady && SupabaseService.hasSession;

  ({Set<int> surahIds, List<AyahBookmark> ayahs}) _parseRows(List<dynamic> rows) {
    final surahIds = <int>{};
    final ayahs = <AyahBookmark>[];
    for (final row in rows) {
      if (row is! Map) continue;
      final map = row.map((key, value) => MapEntry('$key', value));
      final type = '${map['type'] ?? ''}';
      final surahNumber = (map['surah_number'] as num? ?? 0).toInt();
      if (type == 'surah') {
        surahIds.add(surahNumber);
        continue;
      }
      ayahs.add(
        AyahBookmark(
          surahNumber: surahNumber,
          surahNameArabic: '',
          ayahNumber: (map['ayah_number'] as num? ?? 0).toInt(),
          previewText: map['preview_text'] as String? ?? '',
        ),
      );
    }
    return (surahIds: surahIds, ayahs: ayahs);
  }

  Future<void> _cache(Set<int> surahIds, List<AyahBookmark> ayahs) async {
    if (_database != null) {
      await _database.replaceBookmarksCache(
        surahIds: surahIds,
        ayahs: ayahs
            .map(
              (a) => (
                surahNumber: a.surahNumber,
                surahNameArabic: a.surahNameArabic,
                ayahNumber: a.ayahNumber,
                previewText: a.previewText,
              ),
            )
            .toList(),
      );
    }
    final json = jsonEncode({
      'surah_ids': surahIds.toList(),
      'ayahs': ayahs
          .map(
            (a) => {
              'surah_number': a.surahNumber,
              'surah_name_arabic': a.surahNameArabic,
              'ayah_number': a.ayahNumber,
              'preview_text': a.previewText,
            },
          )
          .toList(),
    });
    await _preferences.setString(_cacheKey, json);
  }

  Future<({Set<int> surahIds, List<AyahBookmark> ayahs})?> _fromCache() async {
    if (_database != null) {
      await _migrateLegacyCacheIfNeeded();
      final cached = await _database.getBookmarksCache();
      if (cached.surahIds.isNotEmpty || cached.ayahRows.isNotEmpty) {
        final ayahs = cached.ayahRows.map((row) {
          return AyahBookmark(
            surahNumber: row.read<int>('surah_number'),
            surahNameArabic: row.read<String>('surah_name_arabic'),
            ayahNumber: row.read<int>('ayah_number'),
            previewText: row.read<String>('preview_text'),
          );
        }).toList();
        return (surahIds: cached.surahIds, ayahs: ayahs);
      }
    }
    final raw = await _preferences.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return _parseLegacyJson(decoded);
    } catch (_) {
      return null;
    }
  }

  ({Set<int> surahIds, List<AyahBookmark> ayahs}) _parseLegacyJson(
    Map<String, dynamic> data,
  ) {
    final surahIds = (data['surah_ids'] as List? ?? [])
        .map((e) => (e as num).toInt())
        .toSet();
    final ayahs = (data['ayahs'] as List? ?? [])
        .whereType<Map>()
        .map(
          (e) => AyahBookmark(
            surahNumber: (e['surah_number'] as num? ?? 0).toInt(),
            surahNameArabic: e['surah_name_arabic'] as String? ?? '',
            ayahNumber: (e['ayah_number'] as num? ?? 0).toInt(),
            previewText: e['preview_text'] as String? ?? '',
          ),
        )
        .toList();
    return (surahIds: surahIds, ayahs: ayahs);
  }

  Future<void> _migrateLegacyCacheIfNeeded() async {
    if (_database == null) return;
    final migrated = await _preferences.getString(_legacyMigratedKey);
    if (migrated == '1') return;

    final raw = await _preferences.getString(_cacheKey);
    if (raw == null || raw.isEmpty) {
      await _preferences.setString(_legacyMigratedKey, '1');
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final parsed = _parseLegacyJson(decoded);
        await _database.replaceBookmarksCache(
          surahIds: parsed.surahIds,
          ayahs: parsed.ayahs
              .map(
                (a) => (
                  surahNumber: a.surahNumber,
                  surahNameArabic: a.surahNameArabic,
                  ayahNumber: a.ayahNumber,
                  previewText: a.previewText,
                ),
              )
              .toList(),
        );
      }
    } catch (_) {
      // ignore malformed legacy cache
    } finally {
      await _preferences.setString(_legacyMigratedKey, '1');
    }
  }
}
