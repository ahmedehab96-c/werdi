import 'package:quran/quran.dart' as quran_pkg;
import 'package:werdi/features/quran/domain/constants/tafsir_sources.dart';
import 'package:werdi/features/quran/domain/models/tafsir_item.dart';
import 'package:werdi/features/quran/domain/services/quran_tafsir_service.dart';

class OfflineQuranTafsirService implements QuranTafsirService {
  const OfflineQuranTafsirService();

  @override
  Future<List<String>> getAvailableSources() async {
    return const [TafsirSources.offlineSourceId];
  }

  @override
  Future<TafsirItem> getTafsir({
    required int surahNumber,
    required int ayahStart,
    required int ayahEnd,
    required String source,
  }) async {
    final buffer = StringBuffer();
    for (int i = ayahStart; i <= ayahEnd; i++) {
      try {
        final text = quran_pkg.getVerse(surahNumber, i);
        buffer.writeln('($i)  $text');
        if (i < ayahEnd) buffer.writeln();
      } catch (_) {}
    }
    return TafsirItem(
      surahNumber: surahNumber,
      ayahStart: ayahStart,
      ayahEnd: ayahEnd,
      source: TafsirSources.labelFor(TafsirSources.offlineSourceId),
      text: buffer.toString(),
      isOfflineFallback: true,
    );
  }
}
