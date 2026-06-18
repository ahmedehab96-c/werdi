import 'dart:convert';

import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/core/network/laravel_api_client.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/core/services/offline_sync_service.dart';
import 'package:werdi/features/quran/presentation/cubit/quran_state.dart';

class LaravelBookmarkRepository {
  const LaravelBookmarkRepository({
    required LaravelApiClient client,
    AppPreferences? preferences,
    OfflineSyncService? syncService,
    AppDatabase? database,
  })  : _client = client,
        _preferences = preferences ?? const SharedPrefsService(),
        _syncService = syncService,
        _database = database;

  final LaravelApiClient _client;
  final AppPreferences _preferences;
  final OfflineSyncService? _syncService;
  final AppDatabase? _database;
  static const _cacheKey = 'bookmarks_cache_v1';
  static const _legacyMigratedKey = 'bookmarks_cache_v1_migrated_to_drift';

  Future<({Set<int> surahIds, List<AyahBookmark> ayahs})>
      getBookmarks() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>('/bookmarks');
      final data = response.data ?? <String, dynamic>{};
      final parsed = _parse(data);
      await _cache(parsed.surahIds, parsed.ayahs);
      return parsed;
    } catch (_) {
      final cached = await _fromCache();
      return cached ?? (surahIds: <int>{}, ayahs: const <AyahBookmark>[]);
    }
  }

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
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/bookmarks/surah',
        data: {'surah_number': surahNumber},
      );
      return (response.data?['bookmarked'] as bool?) ?? nowBookmarked;
    } catch (_) {
      await _syncService?.enqueue(
        type: 'bookmark.toggle_surah',
        payload: {'surah_number': surahNumber},
      );
      return nowBookmarked;
    }
  }

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
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/bookmarks/ayah',
        data: {
          'surah_number': surahNumber,
          'ayah_number': ayahNumber,
          'preview_text': previewText,
        },
      );
      return (response.data?['bookmarked'] as bool?) ?? nowBookmarked;
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

  ({Set<int> surahIds, List<AyahBookmark> ayahs}) _parse(
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
      return _parse(decoded);
    } catch (_) {
      return null;
    }
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
        final parsed = _parse(decoded);
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
