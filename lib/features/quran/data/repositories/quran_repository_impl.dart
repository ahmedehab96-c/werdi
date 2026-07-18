import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/features/quran/data/services/recitation_offline_storage.dart';
import 'package:werdi/features/quran/data/services/quran_service.dart';
import 'package:werdi/features/quran/data/services/local_quran_cache_service.dart';
import 'package:werdi/features/quran/data/services/trusted_quran_remote_service.dart';
import 'package:werdi/features/quran/domain/models/juz_item.dart';
import 'package:werdi/features/quran/domain/models/quran_ayah_search_hit.dart';
import 'package:werdi/features/quran/domain/models/quran_progress_status.dart';
import 'package:werdi/features/quran/domain/models/quran_audio_reciter.dart';
import 'package:werdi/features/quran/domain/models/quran_text_source.dart';
import 'package:werdi/features/quran/domain/models/quran_translation_language.dart';
import 'package:werdi/features/quran/domain/models/quran_verse.dart';
import 'package:werdi/features/quran/domain/models/surah_item.dart';
import 'package:werdi/features/quran/domain/repositories/quran_repository.dart';

class QuranRepositoryImpl implements QuranRepository {
  QuranRepositoryImpl({
    required QuranService service,
    LocalQuranCacheService? localCache,
    TrustedQuranRemoteService? remoteService,
    AppDatabase? database,
    RecitationOfflineStorage? offlineStorage,
  })  : _service = service,
        _localCache = localCache,
        _remoteService = remoteService,
        _database = database,
        _offlineStorage = offlineStorage;

  final QuranService _service;
  final LocalQuranCacheService? _localCache;
  final TrustedQuranRemoteService? _remoteService;
  final AppDatabase? _database;
  final RecitationOfflineStorage? _offlineStorage;

  @override
  Future<List<SurahItem>> getSurahs() async {
    return List<SurahItem>.generate(_service.totalSurahs, (index) {
      final surahNumber = index + 1;
      return SurahItem(
        number: surahNumber,
        nameArabic: _service.getSurahNameArabic(surahNumber),
        nameEnglish: _service.getSurahNameEnglish(surahNumber),
        verseCount: _service.getVerseCount(surahNumber),
        revelationPlace: _service.getPlaceOfRevelation(surahNumber),
        status: QuranProgressStatus.inProgress,
        progress: 0,
      );
    });
  }

  @override
  Future<List<JuzItem>> getJuz() async {
    return List<JuzItem>.generate(_service.totalJuz, (index) {
      final juzNumber = index + 1;
      final surahVerses = _service.getSurahAndVersesFromJuz(juzNumber);
      final surahKeys = surahVerses.keys.toList()..sort();
      final start = surahKeys.first;
      final end = surahKeys.last;
      return JuzItem(
        number: juzNumber,
        surahRangeText: 'من سورة $start إلى سورة $end',
        status: QuranProgressStatus.inProgress,
        progress: 0,
      );
    });
  }

  @override
  Future<List<String>> getVerseTranslations({
    required int surahNumber,
    required int ayahStart,
    required int ayahEnd,
    required QuranTranslationLanguage language,
  }) async {
    return List<String>.generate(
      ayahEnd - ayahStart + 1,
      (index) => _service.getVerseTranslation(
        surahNumber,
        ayahStart + index,
        language,
      ),
    );
  }

  @override
  Future<List<QuranVerse>> getSurahVerses({required int surahNumber}) async {
    final cached = await _localCache?.getCachedSurah(surahNumber);
    if (cached != null && cached.verses.isNotEmpty) {
      return cached.verses;
    }

    final remote = await _remoteService?.fetchSurah(surahNumber);
    if (remote != null && remote.verses.isNotEmpty) {
      await _localCache?.saveSurah(
        surahNumber: surahNumber,
        verses: remote.verses,
        source: remote.source,
      );
      return remote.verses;
    }

    final verseCount = _service.getVerseCount(surahNumber);
    final verses = <QuranVerse>[];
    for (var index = 0; index < verseCount; index++) {
      final ayahNumber = index + 1;
      try {
        verses.add(
          QuranVerse(
            ayahNumber: ayahNumber,
            text: _service.getVerseText(surahNumber, ayahNumber),
          ),
        );
      } catch (_) {
        // Skip malformed verse entries but keep rendering the rest.
      }
    }
    await _localCache?.saveSurah(
      surahNumber: surahNumber,
      verses: verses,
      source: QuranTextSource.packageFallback,
    );
    return verses;
  }

  @override
  Future<List<QuranAyahSearchHit>> searchAyahs({
    required String query,
    int limit = 30,
  }) async {
    final db = _database;
    if (db == null) return const [];
    final rows = await db.searchAyahs(query: query, limit: limit);
    return rows
        .map(
          (row) => QuranAyahSearchHit(
            surahNumber: row.read<int>('surah_number'),
            ayahNumber: row.read<int>('ayah_number'),
            text: row.read<String>('text_uthmani'),
          ),
        )
        .toList();
  }

  @override
  String getAudioVerseUrl({
    required int surahNumber,
    required int ayahNumber,
    required QuranAudioReciter reciter,
  }) {
    return getAudioVerseUrls(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      reciter: reciter,
    ).first;
  }

  @override
  List<String> getAudioVerseUrls({
    required int surahNumber,
    required int ayahNumber,
    required QuranAudioReciter reciter,
  }) {
    return _service.getAudioURLsForCatalogReciter(
      surahNumber,
      ayahNumber,
      reciter,
    );
  }

  @override
  List<String> getAudioAyahUrls({
    required int surahNumber,
    required int ayahNumber,
    required QuranAudioReciter reciter,
  }) {
    final remote = _service.getAudioURLsForCatalogReciter(
      surahNumber,
      ayahNumber,
      reciter,
      ayahOnly: true,
    );
    final storage = _offlineStorage;
    if (storage == null) return remote;

    final local = storage.existingAyahFilePathSync(
      reciterKey: reciter.persistenceKey,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
    if (local == null) return remote;
    return [local, ...remote];
  }

  @override
  String getVerseWebUrl({required int surahNumber, required int ayahNumber}) {
    return _service.getVerseURL(surahNumber, ayahNumber);
  }
}
