import 'package:quran/quran.dart' as quran;
import 'package:werdi/features/quran/domain/models/quran_audio_reciter.dart';
import 'package:werdi/features/quran/domain/models/quran_reciter.dart';
import 'package:werdi/features/quran/domain/models/quran_translation_language.dart';

abstract interface class QuranService {
  int get totalSurahs;
  int get totalJuz;
  String getSurahNameArabic(int surahNumber);
  String getSurahNameEnglish(int surahNumber);
  int getVerseCount(int surahNumber);
  String getPlaceOfRevelation(int surahNumber);
  Map<int, List<int>> getSurahAndVersesFromJuz(int juzNumber);
  String getVerseTranslation(
    int surahNumber,
    int verseNumber,
    QuranTranslationLanguage language,
  );
  String getVerseText(int surahNumber, int verseNumber);
  String getAudioURLByVerse(
    int surahNumber,
    int verseNumber,
    QuranReciter reciter,
  );
  List<String> getAudioURLsByVerse(
    int surahNumber,
    int verseNumber,
    QuranReciter reciter,
  );
  List<String> getAudioURLsForCatalogReciter(
    int surahNumber,
    int verseNumber,
    QuranAudioReciter reciter,
  );
  String getVerseURL(int surahNumber, int verseNumber);
}

class QuranPackageService implements QuranService {
  const QuranPackageService();

  @override
  int get totalSurahs => quran.totalSurahCount;

  @override
  int get totalJuz => quran.totalJuzCount;

  @override
  String getSurahNameArabic(int surahNumber) =>
      quran.getSurahNameArabic(surahNumber);

  @override
  String getSurahNameEnglish(int surahNumber) =>
      quran.getSurahNameEnglish(surahNumber);

  @override
  int getVerseCount(int surahNumber) => quran.getVerseCount(surahNumber);

  @override
  String getPlaceOfRevelation(int surahNumber) =>
      quran.getPlaceOfRevelation(surahNumber);

  @override
  Map<int, List<int>> getSurahAndVersesFromJuz(int juzNumber) =>
      quran.getSurahAndVersesFromJuz(juzNumber);

  @override
  String getVerseTranslation(
    int surahNumber,
    int verseNumber,
    QuranTranslationLanguage language,
  ) => quran.getVerseTranslation(
    surahNumber,
    verseNumber,
    translation: _mapLanguage(language),
  );

  @override
  String getVerseText(int surahNumber, int verseNumber) {
    try {
      return quran.getVerse(surahNumber, verseNumber, verseEndSymbol: true);
    } catch (_) {
      return quran.getVerse(surahNumber, verseNumber);
    }
  }

  quran.Translation _mapLanguage(QuranTranslationLanguage language) {
    switch (language) {
      case QuranTranslationLanguage.enSaheeh:
        return quran.Translation.enSaheeh;
      case QuranTranslationLanguage.enClearQuran:
        return quran.Translation.enClearQuran;
      case QuranTranslationLanguage.urdu:
        return quran.Translation.urdu;
      case QuranTranslationLanguage.french:
        return quran.Translation.frHamidullah;
      case QuranTranslationLanguage.turkish:
        return quran.Translation.trSaheeh;
      case QuranTranslationLanguage.indonesian:
        return quran.Translation.indonesian;
    }
  }

  @override
  String getAudioURLByVerse(
    int surahNumber,
    int verseNumber,
    QuranReciter reciter,
  ) {
    return getAudioURLsByVerse(surahNumber, verseNumber, reciter).first;
  }

  @override
  List<String> getAudioURLsByVerse(
    int surahNumber,
    int verseNumber,
    QuranReciter reciter,
  ) {
    final defaultUrl = quran.getAudioURLByVerse(
      surahNumber,
      verseNumber,
      reciter: _mapReciter(reciter),
    );
    switch (reciter) {
      case QuranReciter.sudais:
        return [
          _everyAyahUrl(
            surahNumber: surahNumber,
            verseNumber: verseNumber,
            readerFolder: 'Abdurrahmaan_As-Sudais_192kbps',
          ),
          _everyAyahUrl(
            surahNumber: surahNumber,
            verseNumber: verseNumber,
            readerFolder: 'Abdurrahmaan_As-Sudais_64kbps',
          ),
          defaultUrl,
        ];
      case QuranReciter.alzainMohammedAhmed:
        final surahPad = surahNumber.toString().padLeft(3, '0');
        return [
          'https://server9.mp3quran.net/alzain/$surahPad.mp3',
          defaultUrl,
        ];
      case QuranReciter.nureenMohamedSiddiq:
        return [
          _everyAyahUrl(
            surahNumber: surahNumber,
            verseNumber: verseNumber,
            readerFolder: 'Noreen_Mohamed_Siddiq_128kbps',
          ),
          _everyAyahUrl(
            surahNumber: surahNumber,
            verseNumber: verseNumber,
            readerFolder: 'Noreen_Mohamed_Siddiq_64kbps',
          ),
          defaultUrl,
        ];
      default:
        return [defaultUrl];
    }
  }

  @override
  List<String> getAudioURLsForCatalogReciter(
    int surahNumber,
    int verseNumber,
    QuranAudioReciter reciter,
  ) {
    final urls = <String>[];
    if (reciter.packageReciter != null) {
      urls.addAll(
        getAudioURLsByVerse(
          surahNumber,
          verseNumber,
          reciter.packageReciter!,
        ),
      );
    }
    final surahPadded = surahNumber.toString().padLeft(3, '0');
    final wholeSurah = '${reciter.serverBaseUrl}$surahPadded.mp3';
    if (!urls.contains(wholeSurah)) {
      urls.add(wholeSurah);
    }
    return urls.isEmpty ? [wholeSurah] : urls;
  }

  @override
  String getVerseURL(int surahNumber, int verseNumber) =>
      quran.getVerseURL(surahNumber, verseNumber);

  quran.Reciter _mapReciter(QuranReciter reciter) {
    switch (reciter) {
      case QuranReciter.alafasy:
        return quran.Reciter.arAlafasy;
      case QuranReciter.husary:
        return quran.Reciter.arHusary;
      case QuranReciter.ahmedAjamy:
        return quran.Reciter.arAhmedAjamy;
      case QuranReciter.hudhaify:
        return quran.Reciter.arHudhaify;
      case QuranReciter.maherMuaiqly:
        return quran.Reciter.arMaherMuaiqly;
      case QuranReciter.sudais:
      case QuranReciter.alzainMohammedAhmed:
      case QuranReciter.nureenMohamedSiddiq:
        return quran.Reciter.arAlafasy;
      case QuranReciter.muhammadAyyoub:
        return quran.Reciter.arMuhammadAyyoub;
      case QuranReciter.muhammadJibreel:
        return quran.Reciter.arMuhammadJibreel;
      case QuranReciter.minshawi:
        return quran.Reciter.arMinshawi;
      case QuranReciter.shaatree:
        return quran.Reciter.arShaatree;
    }
  }

  String _everyAyahUrl({
    required int surahNumber,
    required int verseNumber,
    required String readerFolder,
  }) {
    final surah = surahNumber.toString().padLeft(3, '0');
    final ayah = verseNumber.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/$readerFolder/$surah$ayah.mp3';
  }
}
