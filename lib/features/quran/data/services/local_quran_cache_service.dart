import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/features/quran/data/services/quran_cached_surah_payload.dart';
import 'package:werdi/features/quran/domain/models/quran_text_source.dart';
import 'package:werdi/features/quran/domain/models/quran_verse.dart';

/// SQLite-backed cache for surah ayah text (offline reading).
class LocalQuranCacheService {
  LocalQuranCacheService({required AppDatabase database}) : _database = database;

  final AppDatabase _database;
  static const Duration _defaultTtl = Duration(days: 30);

  Future<QuranCachedSurahPayload?> getCachedSurah(
    int surahNumber, {
    Duration ttl = _defaultTtl,
  }) async {
    final dbRows = await _database.getSurahAyahs(surahNumber);
    if (dbRows.isEmpty) return null;

    final verses = dbRows
        .map(
          (row) => QuranVerse(
            ayahNumber: row.read<int>('ayah_number'),
            text: row.read<String>('text_uthmani'),
          ),
        )
        .toList();
    final source = QuranTextSource.values.firstWhere(
      (v) => v.name == dbRows.first.read<String>('source'),
      orElse: () => QuranTextSource.localCache,
    );
    final cachedAt =
        DateTime.tryParse(dbRows.first.read<String>('cached_at')) ??
            DateTime.now();
    if (DateTime.now().difference(cachedAt) > ttl) return null;

    return QuranCachedSurahPayload(
      surahNumber: surahNumber,
      verses: verses,
      source: source,
      cachedAt: cachedAt,
    );
  }

  Future<void> saveSurah({
    required int surahNumber,
    required List<QuranVerse> verses,
    required QuranTextSource source,
  }) async {
    if (verses.isEmpty) return;
    await _database.replaceSurahAyahs(
      surahNumber: surahNumber,
      ayahs: verses
          .map(
            (verse) => (
              ayahNumber: verse.ayahNumber,
              textUthmani: verse.text,
              textSimple: null,
              source: source.name,
            ),
          )
          .toList(),
    );
  }

  Future<void> clearExpired({Duration ttl = _defaultTtl}) async {
    await _database.clearExpiredSurahAyahs(ttl: ttl);
  }
}
