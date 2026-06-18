import 'package:werdi/features/quran/domain/models/tafsir_item.dart';

abstract interface class QuranTafsirRepository {
  Future<List<String>> getSources();

  Future<TafsirItem> getTafsir({
    required int surahNumber,
    required int ayahStart,
    required int ayahEnd,
    required String source,
  });
}
