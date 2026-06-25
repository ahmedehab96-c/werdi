import 'package:werdi/features/quran/domain/models/juz_item.dart';
import 'package:werdi/features/quran/domain/models/quran_ayah_search_hit.dart';
import 'package:werdi/features/quran/domain/models/quran_audio_reciter.dart';
import 'package:werdi/features/quran/domain/models/quran_translation_language.dart';
import 'package:werdi/features/quran/domain/models/quran_verse.dart';
import 'package:werdi/features/quran/domain/models/surah_item.dart';

abstract interface class QuranRepository {
  Future<List<SurahItem>> getSurahs();
  Future<List<JuzItem>> getJuz();
  Future<List<String>> getVerseTranslations({
    required int surahNumber,
    required int ayahStart,
    required int ayahEnd,
    required QuranTranslationLanguage language,
  });
  Future<List<QuranVerse>> getSurahVerses({required int surahNumber});
  Future<List<QuranAyahSearchHit>> searchAyahs({
    required String query,
    int limit = 30,
  });
  String getAudioVerseUrl({
    required int surahNumber,
    required int ayahNumber,
    required QuranAudioReciter reciter,
  });
  List<String> getAudioVerseUrls({
    required int surahNumber,
    required int ayahNumber,
    required QuranAudioReciter reciter,
  });
  List<String> getAudioAyahUrls({
    required int surahNumber,
    required int ayahNumber,
    required QuranAudioReciter reciter,
  });
  String getVerseWebUrl({required int surahNumber, required int ayahNumber});
}
