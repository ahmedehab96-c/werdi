import 'package:werdi/features/quran/data/services/cached_quran_tafsir_service.dart';
import 'package:werdi/features/quran/domain/models/tafsir_item.dart';
import 'package:werdi/features/quran/domain/repositories/quran_tafsir_repository.dart';
import 'package:werdi/features/quran/domain/services/quran_tafsir_service.dart';

class QuranTafsirRepositoryImpl implements QuranTafsirRepository {
  QuranTafsirRepositoryImpl({required QuranTafsirService service})
    : _service = service;

  final QuranTafsirService _service;

  CachedQuranTafsirService? get _cachedService {
    final service = _service;
    if (service is CachedQuranTafsirService) return service;
    return null;
  }

  @override
  Future<List<String>> getSources() => _service.getAvailableSources();

  @override
  Future<TafsirItem> getTafsir({
    required int surahNumber,
    required int ayahStart,
    required int ayahEnd,
    required String source,
  }) {
    return _service.getTafsir(
      surahNumber: surahNumber,
      ayahStart: ayahStart,
      ayahEnd: ayahEnd,
      source: source,
    );
  }

  @override
  Future<Set<String>> getOfflineReadyTafsirKeys() async {
    return _cachedService?.getOfflineReadyKeys() ?? const {};
  }

  @override
  Future<bool> isSurahTafsirOfflineReady({
    required int surahNumber,
    required int verseCount,
    required String source,
  }) async {
    final cached = _cachedService;
    if (cached == null) return false;
    return cached.isSurahOfflineReady(
      surahNumber: surahNumber,
      verseCount: verseCount,
      source: source,
    );
  }

  @override
  Future<void> markSurahTafsirOfflineReady({
    required int surahNumber,
    required String source,
  }) async {
    await _cachedService?.markSurahOfflineReady(
      surahNumber: surahNumber,
      source: source,
    );
  }
}
