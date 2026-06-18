import 'package:equatable/equatable.dart';
import 'package:werdi/features/quran/domain/models/quran_reciter.dart';

/// قرّاء من [MP3Quran](https://www.mp3quran.net/api/) مع دعم اختياري لروابط الآية عبر حزمة `quran`.
class QuranAudioReciter extends Equatable {
  const QuranAudioReciter({
    required this.mp3QuranId,
    required this.name,
    required this.letter,
    required this.serverBaseUrl,
    required this.supportedSurahNumbers,
    this.packageReciter,
  });

  final int mp3QuranId;
  final String name;
  final String letter;
  /// يجب أن ينتهي بـ `/`
  final String serverBaseUrl;
  final Set<int> supportedSurahNumbers;

  /// عند التقارب مع أحد قرّاء الحزمة نُرجع روابط «آية بآية».
  final QuranReciter? packageReciter;

  bool get hasVerseLevelUrls => packageReciter != null;

  /// مفتاح حفظ الاختيار في التفضيلات.
  String get persistenceKey => 'mp3quran_$mp3QuranId';

  static int? tryParsePersistenceKey(String? value) {
    if (value == null || !value.startsWith('mp3quran_')) return null;
    return int.tryParse(value.substring('mp3quran_'.length));
  }

  /// تفضيل مصحف حفص مرتل (نوع 11، راوية 1) إن وُجد.
  static QuranAudioReciter? fromApiJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final letter = json['letter'];
    final rawMoshaf = json['moshaf'];
    if (id is! int || name is! String || letter is! String) return null;
    if (rawMoshaf is! List || rawMoshaf.isEmpty) return null;

    Map<String, dynamic>? pickMoshaf() {
      for (final item in rawMoshaf) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        if (map['moshaf_type'] == 11 && map['rewaya_id'] == 1) {
          return map;
        }
      }
      final first = rawMoshaf.first;
      if (first is Map) return Map<String, dynamic>.from(first);
      return null;
    }

    final moshaf = pickMoshaf();
    if (moshaf == null) return null;
    final server = moshaf['server'];
    final surahList = moshaf['surah_list'];
    if (server is! String || server.isEmpty) return null;

    final normalizedServer =
        server.endsWith('/') ? server : '$server/';
    final surahIds = <int>{};
    if (surahList is String) {
      for (final part in surahList.split(',')) {
        final n = int.tryParse(part.trim());
        if (n != null && n >= 1 && n <= 114) surahIds.add(n);
      }
    }

    final packageReciter = _packageReciterForMp3QuranId(id);

    return QuranAudioReciter(
      mp3QuranId: id,
      name: name,
      letter: letter,
      serverBaseUrl: normalizedServer,
      supportedSurahNumbers: surahIds,
      packageReciter: packageReciter,
    );
  }

  static QuranReciter? _packageReciterForMp3QuranId(int mp3Id) {
    switch (mp3Id) {
      case 123:
        return QuranReciter.alafasy;
      case 118:
        return QuranReciter.husary;
      case 5:
        return QuranReciter.ahmedAjamy;
      case 205:
        return QuranReciter.hudhaify;
      case 102:
        return QuranReciter.maherMuaiqly;
      case 54:
        return QuranReciter.sudais;
      case 13:
        return QuranReciter.alzainMohammedAhmed;
      case 138:
        return QuranReciter.nureenMohamedSiddiq;
      case 109:
        return QuranReciter.muhammadAyyoub;
      case 111:
        return QuranReciter.muhammadJibreel;
      case 112:
        return QuranReciter.minshawi;
      case 4:
        return QuranReciter.shaatree;
      default:
        return null;
    }
  }

  @override
  List<Object?> get props => [
    mp3QuranId,
    name,
    letter,
    serverBaseUrl,
    supportedSurahNumbers,
    packageReciter,
  ];

  static Set<int> _allSurahs() => {for (var i = 1; i <= 114; i++) i};

  /// نسخة مصغّرة عند تعذّر الاتصال بـ API (نفس بيانات [mp3quran.net](https://www.mp3quran.net)).
  static List<QuranAudioReciter> offlineFallback() => [
    QuranAudioReciter(
      mp3QuranId: 123,
      name: 'مشاري العفاسي',
      letter: 'م',
      serverBaseUrl: 'https://server8.mp3quran.net/afs/',
      supportedSurahNumbers: _allSurahs(),
      packageReciter: QuranReciter.alafasy,
    ),
    QuranAudioReciter(
      mp3QuranId: 118,
      name: 'محمود خليل الحصري',
      letter: 'م',
      serverBaseUrl: 'https://server13.mp3quran.net/husr/',
      supportedSurahNumbers: _allSurahs(),
      packageReciter: QuranReciter.husary,
    ),
    QuranAudioReciter(
      mp3QuranId: 5,
      name: 'أحمد بن علي العجمي',
      letter: 'أ',
      serverBaseUrl: 'https://server10.mp3quran.net/ajm/',
      supportedSurahNumbers: _allSurahs(),
      packageReciter: QuranReciter.ahmedAjamy,
    ),
    QuranAudioReciter(
      mp3QuranId: 205,
      name: 'أحمد الحذيفي',
      letter: 'أ',
      serverBaseUrl: 'https://server8.mp3quran.net/ahmad_huth/',
      supportedSurahNumbers: _allSurahs(),
      packageReciter: QuranReciter.hudhaify,
    ),
    QuranAudioReciter(
      mp3QuranId: 102,
      name: 'ماهر المعيقلي',
      letter: 'م',
      serverBaseUrl: 'https://server12.mp3quran.net/maher/',
      supportedSurahNumbers: _allSurahs(),
      packageReciter: QuranReciter.maherMuaiqly,
    ),
    QuranAudioReciter(
      mp3QuranId: 54,
      name: 'عبدالرحمن السديس',
      letter: 'ع',
      serverBaseUrl: 'https://server11.mp3quran.net/sds/',
      supportedSurahNumbers: _allSurahs(),
      packageReciter: QuranReciter.sudais,
    ),
    QuranAudioReciter(
      mp3QuranId: 13,
      name: 'الزين محمد أحمد',
      letter: 'ا',
      serverBaseUrl: 'https://server9.mp3quran.net/alzain/',
      supportedSurahNumbers: _allSurahs(),
      packageReciter: QuranReciter.alzainMohammedAhmed,
    ),
    QuranAudioReciter(
      mp3QuranId: 138,
      name: 'نورين محمد صديق',
      letter: 'ن',
      serverBaseUrl: 'https://server16.mp3quran.net/nourin_siddig/Rewayat-Aldori-A-n-Abi-Amr/',
      supportedSurahNumbers: _allSurahs(),
      packageReciter: QuranReciter.nureenMohamedSiddiq,
    ),
    QuranAudioReciter(
      mp3QuranId: 109,
      name: 'محمد أيوب',
      letter: 'م',
      serverBaseUrl: 'https://server16.mp3quran.net/ayyoub2/Rewayat-Hafs-A-n-Assem/',
      supportedSurahNumbers: _allSurahs(),
      packageReciter: QuranReciter.muhammadAyyoub,
    ),
    QuranAudioReciter(
      mp3QuranId: 111,
      name: 'محمد جبريل',
      letter: 'م',
      serverBaseUrl: 'https://server8.mp3quran.net/jbrl/',
      supportedSurahNumbers: _allSurahs(),
      packageReciter: QuranReciter.muhammadJibreel,
    ),
    QuranAudioReciter(
      mp3QuranId: 112,
      name: 'محمد صديق المنشاوي',
      letter: 'م',
      serverBaseUrl: 'https://server10.mp3quran.net/minsh/',
      supportedSurahNumbers: _allSurahs(),
      packageReciter: QuranReciter.minshawi,
    ),
    QuranAudioReciter(
      mp3QuranId: 4,
      name: 'شيخ أبو بكر الشاطري',
      letter: 'ش',
      serverBaseUrl: 'https://server11.mp3quran.net/shatri/',
      supportedSurahNumbers: _allSurahs(),
      packageReciter: QuranReciter.shaatree,
    ),
  ];

  static List<QuranAudioReciter> offlineFallbackSorted() {
    final list = List<QuranAudioReciter>.from(offlineFallback());
    list.sort(compareArabicReciterNames);
    return list;
  }
}

int compareArabicReciterNames(QuranAudioReciter a, QuranAudioReciter b) {
  final byLetter = a.letter.compareTo(b.letter);
  if (byLetter != 0) return byLetter;
  return a.name.compareTo(b.name);
}
