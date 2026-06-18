import 'package:werdi/features/quran/domain/models/tafsir_item.dart';

abstract interface class QuranTafsirService {
  Future<List<String>> getAvailableSources();

  Future<TafsirItem> getTafsir({
    required int surahNumber,
    required int ayahStart,
    required int ayahEnd,
    required String source,
  });
}
