import 'package:hive_flutter/hive_flutter.dart';
import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/features/quran/data/services/quran_cached_surah_payload.dart';
import 'package:werdi/features/quran/domain/models/quran_text_source.dart';
import 'package:werdi/features/quran/domain/models/quran_verse.dart';

class LocalQuranCacheService {
  LocalQuranCacheService({this.database});

  final AppDatabase? database;
  static const String _boxName = 'quran_surah_cache_v1';
  static const Duration _defaultTtl = Duration(days: 30);

  Future<QuranCachedSurahPayload?> getCachedSurah(
    int surahNumber, {
    Duration ttl = _defaultTtl,
  }) async {
    final dbRows = await database?.getSurahAyahs(surahNumber);
    if (dbRows != null && dbRows.isNotEmpty) {
      final verses = dbRows.map((row) {
        return QuranVerse(
          ayahNumber: row.read<int>('ayah_number'),
          text: row.read<String>('text_uthmani'),
        );
      }).toList();
      final source = QuranTextSource.values.firstWhere(
        (v) => v.name == (dbRows.first.read<String>('source')),
        orElse: () => QuranTextSource.localCache,
      );
      final cachedAtRaw = dbRows.first.read<String>('cached_at');
      final cachedAt = DateTime.tryParse(cachedAtRaw) ?? DateTime.now();
      final isExpired = DateTime.now().difference(cachedAt) > ttl;
      if (!isExpired) {
        return QuranCachedSurahPayload(
          surahNumber: surahNumber,
          verses: verses,
          source: source,
          cachedAt: cachedAt,
        );
      }
    }

    final box = await Hive.openBox<dynamic>(_boxName);
    final raw = box.get(_surahKey(surahNumber));
    if (raw is! Map) return null;

    final cachedAtMs = raw['cachedAtMs'];
    if (cachedAtMs is! int) return null;
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMs);
    final isExpired = DateTime.now().difference(cachedAt) > ttl;
    if (isExpired) return null;

    final sourceName = raw['source'] as String?;
    final source = QuranTextSource.values.firstWhere(
      (v) => v.name == sourceName,
      orElse: () => QuranTextSource.localCache,
    );
    final versesRaw = raw['verses'];
    if (versesRaw is! List) return null;

    final verses = <QuranVerse>[];
    for (final item in versesRaw) {
      if (item is! Map) continue;
      final ayahNumber = item['ayahNumber'];
      final text = item['text'];
      if (ayahNumber is int && text is String && text.trim().isNotEmpty) {
        verses.add(QuranVerse(ayahNumber: ayahNumber, text: text.trim()));
      }
    }
    if (verses.isEmpty) return null;
    verses.sort((a, b) => a.ayahNumber.compareTo(b.ayahNumber));
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
    await database?.replaceSurahAyahs(
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
    final box = await Hive.openBox<dynamic>(_boxName);
    await box.put(
      _surahKey(surahNumber),
      <String, dynamic>{
        'source': source.name,
        'cachedAtMs': DateTime.now().millisecondsSinceEpoch,
        'verses': verses
            .map(
              (verse) => <String, dynamic>{
                'ayahNumber': verse.ayahNumber,
                'text': verse.text,
              },
            )
            .toList(),
      },
    );
  }

  Future<void> clearExpired({Duration ttl = _defaultTtl}) async {
    await database?.clearExpiredSurahAyahs(ttl: ttl);
    final box = await Hive.openBox<dynamic>(_boxName);
    final now = DateTime.now();
    final keysToDelete = <dynamic>[];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is! Map) {
        keysToDelete.add(key);
        continue;
      }
      final cachedAtMs = raw['cachedAtMs'];
      if (cachedAtMs is! int) {
        keysToDelete.add(key);
        continue;
      }
      final age = now.difference(DateTime.fromMillisecondsSinceEpoch(cachedAtMs));
      if (age > ttl) keysToDelete.add(key);
    }
    if (keysToDelete.isNotEmpty) {
      await box.deleteAll(keysToDelete);
    }
  }

  String _surahKey(int surahNumber) => 'surah_$surahNumber';
}
