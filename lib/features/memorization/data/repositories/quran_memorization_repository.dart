import 'package:werdi/features/memorization/domain/models/memorization_ayah.dart';
import 'package:werdi/features/memorization/domain/repositories/memorization_repository.dart';
import 'package:werdi/features/quran/domain/repositories/quran_repository.dart';

class QuranMemorizationRepository implements MemorizationRepository {
  const QuranMemorizationRepository({required QuranRepository quranRepository})
      : _quran = quranRepository;

  final QuranRepository _quran;

  @override
  Future<List<MemorizationAyah>> getSessionAyahs({
    required int surahNumber,
    required int ayahStart,
    required int ayahEnd,
  }) async {
    final verses = await _quran.getSurahVerses(surahNumber: surahNumber);
    return verses
        .where((v) => v.ayahNumber >= ayahStart && v.ayahNumber <= ayahEnd)
        .map((v) => MemorizationAyah(number: v.ayahNumber, text: v.text))
        .toList();
  }
}
