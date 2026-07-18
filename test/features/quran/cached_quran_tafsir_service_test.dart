import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/features/quran/data/services/cached_quran_tafsir_service.dart';
import 'package:werdi/features/quran/domain/models/tafsir_item.dart';
import 'package:werdi/features/quran/domain/services/quran_tafsir_service.dart';
import '../../support/fakes.dart';

class _FakeTafsirService implements QuranTafsirService {
  _FakeTafsirService({
    this.sources = const ['ar.muyassar'],
    this.item = const TafsirItem(
      surahNumber: 1,
      ayahStart: 1,
      ayahEnd: 1,
      source: 'التفسير الميسر',
      text: 'نص',
    ),
    this.throwOnGet = false,
    this.throwOnSources = false,
  });

  final List<String> sources;
  final TafsirItem item;
  final bool throwOnGet;
  final bool throwOnSources;

  @override
  Future<List<String>> getAvailableSources() async {
    if (throwOnSources) throw Exception('sources');
    return sources;
  }

  @override
  Future<TafsirItem> getTafsir({
    required int surahNumber,
    required int ayahStart,
    required int ayahEnd,
    required String source,
  }) async {
    if (throwOnGet) throw Exception('tafsir');
    return item;
  }
}

void main() {
  test('returns cached tafsir when remote fails', () async {
    final prefs = FakeAppPreferences();
    final first = CachedQuranTafsirService(
      remote: _FakeTafsirService(),
      fallback: _FakeTafsirService(
        sources: const ['offline'],
        item: const TafsirItem(
          surahNumber: 1,
          ayahStart: 1,
          ayahEnd: 1,
          source: 'fallback',
          text: 'fallback',
          isOfflineFallback: true,
        ),
      ),
      preferences: prefs,
    );

    await first.getTafsir(
      surahNumber: 1,
      ayahStart: 1,
      ayahEnd: 1,
      source: 'ar.muyassar',
    );

    final second = CachedQuranTafsirService(
      remote: _FakeTafsirService(throwOnGet: true),
      fallback: _FakeTafsirService(
        sources: const ['offline'],
        item: const TafsirItem(
          surahNumber: 1,
          ayahStart: 1,
          ayahEnd: 1,
          source: 'fallback',
          text: 'fallback',
          isOfflineFallback: true,
        ),
      ),
      preferences: prefs,
    );

    final cached = await second.getTafsir(
      surahNumber: 1,
      ayahStart: 1,
      ayahEnd: 1,
      source: 'ar.muyassar',
    );

    expect(cached.text, 'نص');
    expect(cached.isOfflineFallback, isTrue);
  });

  test('returns cached sources when remote fails', () async {
    final prefs = FakeAppPreferences();
    final first = CachedQuranTafsirService(
      remote: _FakeTafsirService(sources: const ['ar.muyassar', 'ar.jalalayn']),
      fallback: _FakeTafsirService(sources: const ['offline']),
      preferences: prefs,
    );
    await first.getAvailableSources();

    final second = CachedQuranTafsirService(
      remote: _FakeTafsirService(throwOnSources: true),
      fallback: _FakeTafsirService(sources: const ['offline']),
      preferences: prefs,
    );
    final sources = await second.getAvailableSources();

    expect(sources, contains('ar.muyassar'));
    expect(sources, contains('ar.jalalayn'));
  });

  test('tracks full surah offline readiness after mark', () async {
    final prefs = FakeAppPreferences();
    final service = CachedQuranTafsirService(
      remote: _FakeTafsirService(
        item: const TafsirItem(
          surahNumber: 1,
          ayahStart: 1,
          ayahEnd: 5,
          source: 'التفسير الميسر',
          text: 'نص',
        ),
      ),
      fallback: _FakeTafsirService(),
      preferences: prefs,
    );

    await service.getTafsir(
      surahNumber: 1,
      ayahStart: 1,
      ayahEnd: 5,
      source: 'ar.muyassar',
    );
    await service.markSurahOfflineReady(
      surahNumber: 1,
      source: 'ar.muyassar',
    );

    expect(
      await service.isSurahOfflineReady(
        surahNumber: 1,
        verseCount: 5,
        source: 'ar.muyassar',
      ),
      isTrue,
    );
    expect(
      (await service.getOfflineReadyKeys()).contains('1|ar.muyassar'),
      isTrue,
    );
  });
}
