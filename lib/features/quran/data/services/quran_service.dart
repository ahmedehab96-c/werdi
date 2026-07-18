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
    QuranAudioReciter reciter, {
    bool ayahOnly = false,
  });
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
    final urls = getAudioURLsByVerse(surahNumber, verseNumber, reciter);
    if (urls.isEmpty) {
      throw StateError('No audio URLs for $reciter');
    }
    return urls.first;
  }

  @override
  List<String> getAudioURLsByVerse(
    int surahNumber,
    int verseNumber,
    QuranReciter reciter,
  ) {
    final urls = <String>[];

    // Prefer islamic.network (quran package CDN) — more reliable than everyayah
    // streaming on Android emulators.
    final packageReciter = _mapReciter(reciter);
    if (packageReciter != null) {
      final packageUrl = quran.getAudioURLByVerse(
        surahNumber,
        verseNumber,
        reciter: packageReciter,
      );
      if (packageUrl.isNotEmpty) urls.add(packageUrl);
    }

    for (final folder in _everyAyahFoldersFor(reciter)) {
      final everyAyah = _everyAyahUrl(
        surahNumber: surahNumber,
        verseNumber: verseNumber,
        readerFolder: folder,
      );
      if (!urls.contains(everyAyah)) urls.add(everyAyah);
    }

    return urls;
  }

  /// Verified everyayah.com folders (tested HTTP 200).
  List<String> _everyAyahFoldersFor(QuranReciter reciter) {
    switch (reciter) {
      case QuranReciter.alafasy:
        return const ['Alafasy_128kbps', 'Alafasy_64kbps'];
      case QuranReciter.abdulBasit:
        return const [
          'Abdul_Basit_Murattal_192kbps',
          'Abdul_Basit_Murattal_64kbps',
        ];
      case QuranReciter.shuraim:
        return const [
          'Saood bin Ibraaheem Ash-Shuraym_128kbps',
          'Saood_ash-Shuraym_64kbps',
        ];
      case QuranReciter.sudais:
        return const [
          'Abdurrahmaan_As-Sudais_192kbps',
          'Abdurrahmaan_As-Sudais_64kbps',
        ];
      case QuranReciter.husary:
        return const ['Husary_128kbps', 'Husary_64kbps'];
      case QuranReciter.ahmedAjamy:
        return const [
          'Ahmed_ibn_Ali_al-Ajamy_128kbps_ketaballah.net',
          'Ahmed_ibn_Ali_al-Ajamy_64kbps_QuranExplorer.Com',
        ];
      case QuranReciter.hudhaify:
        return const ['Hudhaify_128kbps', 'Hudhaify_64kbps'];
      case QuranReciter.maherMuaiqly:
        return const ['MaherAlMuaiqly128kbps', 'Maher_AlMuaiqly_64kbps'];
      case QuranReciter.muhammadAyyoub:
        return const ['Muhammad_Ayyoub_128kbps', 'Muhammad_Ayyoub_64kbps'];
      case QuranReciter.muhammadJibreel:
        return const ['Muhammad_Jibreel_128kbps', 'Muhammad_Jibreel_64kbps'];
      case QuranReciter.minshawi:
        return const [
          'Minshawy_Murattal_128kbps',
          'Minshawy_Mujawwad_64kbps',
        ];
      case QuranReciter.shaatree:
        return const ['Abu_Bakr_Ash-Shaatree_128kbps'];
      case QuranReciter.nureenMohamedSiddiq:
        return const [];
    }
  }

  @override
  List<String> getAudioURLsForCatalogReciter(
    int surahNumber,
    int verseNumber,
    QuranAudioReciter reciter, {
    bool ayahOnly = false,
  }) {
    if (reciter.packageReciter != null) {
      final urls = List<String>.from(
        getAudioURLsByVerse(
          surahNumber,
          verseNumber,
          reciter.packageReciter!,
        ),
      );
      if (ayahOnly) {
        return urls;
      }
      final surahPadded = surahNumber.toString().padLeft(3, '0');
      final wholeSurah = '${reciter.serverBaseUrl}$surahPadded.mp3';
      if (!urls.contains(wholeSurah)) {
        urls.add(wholeSurah);
      }
      return urls;
    }

    if (reciter.everyAyahFolder != null) {
      final urls = [
        _everyAyahUrl(
          surahNumber: surahNumber,
          verseNumber: verseNumber,
          readerFolder: reciter.everyAyahFolder!,
        ),
      ];
      if (ayahOnly) {
        return urls;
      }
      final surahPadded = surahNumber.toString().padLeft(3, '0');
      final wholeSurah = '${reciter.serverBaseUrl}$surahPadded.mp3';
      if (!urls.contains(wholeSurah)) {
        urls.add(wholeSurah);
      }
      return urls;
    }

    return const [];
  }

  @override
  String getVerseURL(int surahNumber, int verseNumber) =>
      quran.getVerseURL(surahNumber, verseNumber);

  quran.Reciter? _mapReciter(QuranReciter reciter) {
    switch (reciter) {
      case QuranReciter.alafasy:
        return quran.Reciter.arAlafasy;
      case QuranReciter.abdulBasit:
      case QuranReciter.shuraim:
      case QuranReciter.sudais:
      case QuranReciter.nureenMohamedSiddiq:
        return null;
      case QuranReciter.husary:
        return quran.Reciter.arHusary;
      case QuranReciter.ahmedAjamy:
        return quran.Reciter.arAhmedAjamy;
      case QuranReciter.hudhaify:
        return quran.Reciter.arHudhaify;
      case QuranReciter.maherMuaiqly:
        return quran.Reciter.arMaherMuaiqly;
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
    final encodedFolder = readerFolder.replaceAll(' ', '%20');
    return 'https://everyayah.com/data/$encodedFolder/$surah$ayah.mp3';
  }
}
