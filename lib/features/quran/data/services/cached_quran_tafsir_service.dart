import 'dart:convert';

import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/features/quran/domain/models/tafsir_item.dart';
import 'package:werdi/features/quran/domain/services/quran_tafsir_service.dart';

/// Caches fetched tafsir/sources so offline mode can show real prior content.
class CachedQuranTafsirService implements QuranTafsirService {
  CachedQuranTafsirService({
    required QuranTafsirService remote,
    required QuranTafsirService fallback,
    required AppPreferences preferences,
  }) : _remote = remote,
       _fallback = fallback,
       _preferences = preferences;

  final QuranTafsirService _remote;
  final QuranTafsirService _fallback;
  final AppPreferences _preferences;

  static const _sourcesKey = 'tafsir_sources_cache_v1';
  static const _itemKeyPrefix = 'tafsir_item_cache_v1';
  static const _readyRegistryKey = 'tafsir_surah_ready_registry_v1';
  static const tafsirChunkSize = 10;

  static String registryKey({
    required int surahNumber,
    required String source,
  }) =>
      '$surahNumber|$source';

  @override
  Future<List<String>> getAvailableSources() async {
    try {
      final sources = await _remote.getAvailableSources();
      if (sources.isNotEmpty) {
        await _preferences.setString(_sourcesKey, jsonEncode(sources));
        return sources;
      }
    } catch (_) {}

    final cached = await _readCachedSources();
    if (cached.isNotEmpty) return cached;
    return _fallback.getAvailableSources();
  }

  @override
  Future<TafsirItem> getTafsir({
    required int surahNumber,
    required int ayahStart,
    required int ayahEnd,
    required String source,
  }) async {
    final key = _itemKey(
      surahNumber: surahNumber,
      ayahStart: ayahStart,
      ayahEnd: ayahEnd,
      source: source,
    );
    try {
      final tafsir = await _remote.getTafsir(
        surahNumber: surahNumber,
        ayahStart: ayahStart,
        ayahEnd: ayahEnd,
        source: source,
      );
      if (!tafsir.isOfflineFallback && tafsir.text.trim().isNotEmpty) {
        await _preferences.setString(key, _encodeItem(tafsir));
        return tafsir;
      }
    } catch (_) {}

    final cached = await _readCachedItem(key);
    if (cached != null) {
      return TafsirItem(
        surahNumber: cached.surahNumber,
        ayahStart: cached.ayahStart,
        ayahEnd: cached.ayahEnd,
        source: cached.source,
        text: cached.text,
        isOfflineFallback: true,
      );
    }

    return _fallback.getTafsir(
      surahNumber: surahNumber,
      ayahStart: ayahStart,
      ayahEnd: ayahEnd,
      source: source,
    );
  }

  String _itemKey({
    required int surahNumber,
    required int ayahStart,
    required int ayahEnd,
    required String source,
  }) => '$_itemKeyPrefix|$source|$surahNumber|$ayahStart|$ayahEnd';

  Future<List<String>> _readCachedSources() async {
    final raw = await _preferences.getString(_sourcesKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded.whereType<String>().toList();
    } catch (_) {
      return const [];
    }
  }

  Future<TafsirItem?> _readCachedItem(String key) async {
    final raw = await _preferences.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return TafsirItem(
        surahNumber: (decoded['surah_number'] as num?)?.toInt() ?? 1,
        ayahStart: (decoded['ayah_start'] as num?)?.toInt() ?? 1,
        ayahEnd: (decoded['ayah_end'] as num?)?.toInt() ?? 1,
        source: '${decoded['source'] ?? ''}',
        text: '${decoded['text'] ?? ''}',
      );
    } catch (_) {
      return null;
    }
  }

  String _encodeItem(TafsirItem item) {
    return jsonEncode({
      'surah_number': item.surahNumber,
      'ayah_start': item.ayahStart,
      'ayah_end': item.ayahEnd,
      'source': item.source,
      'text': item.text,
    });
  }

  Future<Set<String>> getOfflineReadyKeys() async {
    final registry = await _readReadyRegistry();
    return registry.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toSet();
  }

  Future<bool> isSurahOfflineReady({
    required int surahNumber,
    required int verseCount,
    required String source,
  }) async {
    final key = registryKey(surahNumber: surahNumber, source: source);
    final registry = await _readReadyRegistry();
    if (registry[key] != true) return false;
    return _hasAllChunks(
      surahNumber: surahNumber,
      verseCount: verseCount,
      source: source,
    );
  }

  Future<void> markSurahOfflineReady({
    required int surahNumber,
    required String source,
  }) async {
    final registry = await _readReadyRegistry();
    registry[registryKey(surahNumber: surahNumber, source: source)] = true;
    await _preferences.setString(_readyRegistryKey, jsonEncode(registry));
  }

  Future<bool> _hasAllChunks({
    required int surahNumber,
    required int verseCount,
    required String source,
  }) async {
    for (var start = 1; start <= verseCount; start += tafsirChunkSize) {
      final end = (start + tafsirChunkSize - 1).clamp(1, verseCount);
      final cacheKey = _itemKey(
        surahNumber: surahNumber,
        ayahStart: start,
        ayahEnd: end,
        source: source,
      );
      final raw = await _preferences.getString(cacheKey);
      if (raw == null || raw.isEmpty) return false;
    }
    return true;
  }

  Future<Map<String, bool>> _readReadyRegistry() async {
    final raw = await _preferences.getString(_readyRegistryKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return decoded.map(
        (key, value) => MapEntry('$key', value == true),
      );
    } catch (_) {
      return {};
    }
  }
}
