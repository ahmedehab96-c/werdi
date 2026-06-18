import 'package:werdi/features/quran/domain/models/tafsir_item.dart';
import 'package:werdi/features/quran/domain/repositories/quran_tafsir_repository.dart';
import 'package:werdi/features/quran/domain/services/quran_tafsir_service.dart';

class QuranTafsirRepositoryImpl implements QuranTafsirRepository {
  QuranTafsirRepositoryImpl({required QuranTafsirService service})
    : _service = service;

  final QuranTafsirService _service;

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
}
