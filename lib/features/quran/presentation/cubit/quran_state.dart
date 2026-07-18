import 'package:equatable/equatable.dart';
import 'package:werdi/features/quran/domain/models/juz_item.dart';
import 'package:werdi/features/quran/domain/models/quran_filter.dart';
import 'package:werdi/features/quran/domain/models/quran_audio_reciter.dart';
import 'package:werdi/features/quran/domain/models/quran_translation_language.dart';
import 'package:werdi/features/quran/domain/models/quran_verse.dart';
import 'package:werdi/features/quran/domain/models/surah_item.dart';
import 'package:werdi/features/quran/domain/models/tafsir_item.dart';

class AyahBookmark extends Equatable {
  const AyahBookmark({
    required this.surahNumber,
    required this.surahNameArabic,
    required this.ayahNumber,
    required this.previewText,
  });

  final int surahNumber;
  final String surahNameArabic;
  final int ayahNumber;
  final String previewText;

  @override
  List<Object?> get props => [
    surahNumber,
    surahNameArabic,
    ayahNumber,
    previewText,
  ];
}

class MemorizationPosition extends Equatable {
  const MemorizationPosition({
    required this.surahNumber,
    required this.surahNameArabic,
    required this.fromAyah,
    required this.toAyah,
  });

  final int surahNumber;
  final String surahNameArabic;
  final int fromAyah;
  final int toAyah;

  @override
  List<Object> get props => [surahNumber, surahNameArabic, fromAyah, toAyah];
}

class AyahRange extends Equatable {
  const AyahRange({
    required this.label,
    required this.fromAyah,
    required this.toAyah,
    required this.progress,
  });

  final String label;
  final int fromAyah;
  final int toAyah;
  final double progress;

  @override
  List<Object> get props => [label, fromAyah, toAyah, progress];
}

class AyahSearchResult extends Equatable {
  const AyahSearchResult({
    required this.surahNumber,
    required this.surahNameArabic,
    required this.ayahNumber,
    required this.text,
  });

  final int surahNumber;
  final String surahNameArabic;
  final int ayahNumber;
  final String text;

  @override
  List<Object> get props => [surahNumber, surahNameArabic, ayahNumber, text];
}

class QuranState extends Equatable {
  const QuranState({
    this.isLoading = false,
    this.query = '',
    this.filter = QuranFilter.all,
    this.selectedTab = 0,
    this.surahs = const [],
    this.juzList = const [],
    this.bookmarkedSurahIds = const {},
    this.bookmarkedAyahs = const [],
    this.lastMemorizedPositions = const [],
    this.recentSearches = const [],
    this.searchQuery = '',
    this.ayahSearchHits = const [],
    this.openSearchResultsInFocusMode = true,
    this.tafsirSources = const [],
    this.selectedTafsirSource = '',
    this.currentTafsir,
    this.isLoadingTafsir = false,
    this.translationLines = const [],
    this.isLoadingTranslations = false,
    this.translationLanguages = const [
      QuranTranslationLanguage.enSaheeh,
      QuranTranslationLanguage.enClearQuran,
      QuranTranslationLanguage.urdu,
      QuranTranslationLanguage.french,
      QuranTranslationLanguage.turkish,
      QuranTranslationLanguage.indonesian,
    ],
    this.selectedTranslationLanguage = QuranTranslationLanguage.enSaheeh,
    this.audioReciters = const [],
    this.selectedAudioReciter,
    this.isLoadingAudioReciters = false,
    this.lastReadPlaceholder = '',
    this.currentSurahVerses = const [],
    this.isLoadingSurahVerses = false,
    this.isDownloadingTafsirOffline = false,
    this.tafsirDownloadCurrentAyah = 0,
    this.tafsirDownloadTotalAyahs = 0,
    this.offlineReadyTafsirKeys = const {},
  });

  final bool isLoading;
  final String query;
  final QuranFilter filter;
  final int selectedTab;
  final List<SurahItem> surahs;
  final List<JuzItem> juzList;
  final Set<int> bookmarkedSurahIds;
  final List<AyahBookmark> bookmarkedAyahs;
  final List<MemorizationPosition> lastMemorizedPositions;
  final List<String> recentSearches;
  final String searchQuery;
  final List<AyahSearchResult> ayahSearchHits;
  final bool openSearchResultsInFocusMode;
  final List<String> tafsirSources;
  final String selectedTafsirSource;
  final TafsirItem? currentTafsir;
  final bool isLoadingTafsir;
  final List<String> translationLines;
  final bool isLoadingTranslations;
  final List<QuranTranslationLanguage> translationLanguages;
  final QuranTranslationLanguage selectedTranslationLanguage;
  /// من [mp3quran.net](https://www.mp3quran.net/api/) مرتّبون أبجديًا (حرف ثم الاسم).
  final List<QuranAudioReciter> audioReciters;
  final QuranAudioReciter? selectedAudioReciter;
  final bool isLoadingAudioReciters;
  final String lastReadPlaceholder;
  final List<QuranVerse> currentSurahVerses;
  final bool isLoadingSurahVerses;
  final bool isDownloadingTafsirOffline;
  final int tafsirDownloadCurrentAyah;
  final int tafsirDownloadTotalAyahs;
  final Set<String> offlineReadyTafsirKeys;

  bool isSurahTafsirOfflineReady({
    required int surahNumber,
    required String source,
  }) {
    if (source.isEmpty) return false;
    return offlineReadyTafsirKeys.contains('$surahNumber|$source');
  }

  List<SurahItem> get filteredSurahs {
    final trimmedQuery = query.trim();
    final lower = trimmedQuery.toLowerCase();
    return surahs.where((item) {
      final matchesQuery =
          lower.isEmpty ||
          item.nameArabic.contains(trimmedQuery) ||
          item.nameEnglish.toLowerCase().contains(lower) ||
          item.number.toString().contains(lower);
      return matchesQuery && _matchesFilter(item.status.name);
    }).toList();
  }

  List<JuzItem> get filteredJuz {
    final trimmedQuery = query.trim();
    final lower = trimmedQuery.toLowerCase();
    return juzList.where((item) {
      final matchesQuery =
          lower.isEmpty ||
          item.number.toString().contains(lower) ||
          item.surahRangeText.contains(trimmedQuery);
      return matchesQuery && _matchesFilter(item.status.name);
    }).toList();
  }

  List<SurahItem> get searchSurahResults {
    final trimmedQuery = searchQuery.trim();
    final lower = trimmedQuery.toLowerCase();
    if (lower.isEmpty) return const [];
    return surahs.where((item) {
      return item.nameArabic.contains(trimmedQuery) ||
          item.nameEnglish.toLowerCase().contains(lower) ||
          item.number.toString().contains(lower);
    }).toList();
  }

  List<JuzItem> get searchJuzResults {
    final lower = searchQuery.trim().toLowerCase();
    if (lower.isEmpty) return const [];
    return juzList.where((item) {
      return item.number.toString().contains(lower) ||
          item.surahRangeText.toLowerCase().contains(lower);
    }).toList();
  }

  SurahItem? surahByNumber(int surahNumber) {
    for (final surah in surahs) {
      if (surah.number == surahNumber) return surah;
    }
    return null;
  }

  bool _matchesFilter(String statusName) {
    switch (filter) {
      case QuranFilter.all:
        return true;
      case QuranFilter.memorized:
        return statusName == 'memorized';
      case QuranFilter.inProgress:
        return statusName == 'inProgress';
      case QuranFilter.review:
        return statusName == 'review';
    }
  }

  QuranState copyWith({
    bool? isLoading,
    String? query,
    QuranFilter? filter,
    int? selectedTab,
    List<SurahItem>? surahs,
    List<JuzItem>? juzList,
    Set<int>? bookmarkedSurahIds,
    List<AyahBookmark>? bookmarkedAyahs,
    List<MemorizationPosition>? lastMemorizedPositions,
    List<String>? recentSearches,
    String? searchQuery,
    List<AyahSearchResult>? ayahSearchHits,
    bool? openSearchResultsInFocusMode,
    List<String>? tafsirSources,
    String? selectedTafsirSource,
    TafsirItem? currentTafsir,
    bool? isLoadingTafsir,
    List<String>? translationLines,
    bool? isLoadingTranslations,
    List<QuranTranslationLanguage>? translationLanguages,
    QuranTranslationLanguage? selectedTranslationLanguage,
    List<QuranAudioReciter>? audioReciters,
    QuranAudioReciter? selectedAudioReciter,
    bool? isLoadingAudioReciters,
    String? lastReadPlaceholder,
    List<QuranVerse>? currentSurahVerses,
    bool? isLoadingSurahVerses,
    bool? isDownloadingTafsirOffline,
    int? tafsirDownloadCurrentAyah,
    int? tafsirDownloadTotalAyahs,
    Set<String>? offlineReadyTafsirKeys,
    bool clearTafsir = false,
    bool clearTranslations = false,
  }) {
    return QuranState(
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      selectedTab: selectedTab ?? this.selectedTab,
      surahs: surahs ?? this.surahs,
      juzList: juzList ?? this.juzList,
      bookmarkedSurahIds: bookmarkedSurahIds ?? this.bookmarkedSurahIds,
      bookmarkedAyahs: bookmarkedAyahs ?? this.bookmarkedAyahs,
      lastMemorizedPositions:
          lastMemorizedPositions ?? this.lastMemorizedPositions,
      recentSearches: recentSearches ?? this.recentSearches,
      searchQuery: searchQuery ?? this.searchQuery,
      ayahSearchHits: ayahSearchHits ?? this.ayahSearchHits,
      openSearchResultsInFocusMode:
          openSearchResultsInFocusMode ?? this.openSearchResultsInFocusMode,
      tafsirSources: tafsirSources ?? this.tafsirSources,
      selectedTafsirSource: selectedTafsirSource ?? this.selectedTafsirSource,
      currentTafsir: clearTafsir ? null : (currentTafsir ?? this.currentTafsir),
      isLoadingTafsir: isLoadingTafsir ?? this.isLoadingTafsir,
      translationLines: clearTranslations
          ? const []
          : (translationLines ?? this.translationLines),
      isLoadingTranslations:
          isLoadingTranslations ?? this.isLoadingTranslations,
      translationLanguages: translationLanguages ?? this.translationLanguages,
      selectedTranslationLanguage:
          selectedTranslationLanguage ?? this.selectedTranslationLanguage,
      audioReciters: audioReciters ?? this.audioReciters,
      selectedAudioReciter: selectedAudioReciter ?? this.selectedAudioReciter,
      isLoadingAudioReciters:
          isLoadingAudioReciters ?? this.isLoadingAudioReciters,
      lastReadPlaceholder: lastReadPlaceholder ?? this.lastReadPlaceholder,
      currentSurahVerses: currentSurahVerses ?? this.currentSurahVerses,
      isLoadingSurahVerses: isLoadingSurahVerses ?? this.isLoadingSurahVerses,
      isDownloadingTafsirOffline:
          isDownloadingTafsirOffline ?? this.isDownloadingTafsirOffline,
      tafsirDownloadCurrentAyah:
          tafsirDownloadCurrentAyah ?? this.tafsirDownloadCurrentAyah,
      tafsirDownloadTotalAyahs:
          tafsirDownloadTotalAyahs ?? this.tafsirDownloadTotalAyahs,
      offlineReadyTafsirKeys:
          offlineReadyTafsirKeys ?? this.offlineReadyTafsirKeys,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    query,
    filter,
    selectedTab,
    surahs,
    juzList,
    bookmarkedSurahIds,
    bookmarkedAyahs,
    lastMemorizedPositions,
    recentSearches,
    searchQuery,
    ayahSearchHits,
    openSearchResultsInFocusMode,
    tafsirSources,
    selectedTafsirSource,
    currentTafsir,
    isLoadingTafsir,
    translationLines,
    isLoadingTranslations,
    translationLanguages,
    selectedTranslationLanguage,
    audioReciters,
    selectedAudioReciter,
    isLoadingAudioReciters,
    lastReadPlaceholder,
    currentSurahVerses,
    isLoadingSurahVerses,
    isDownloadingTafsirOffline,
    tafsirDownloadCurrentAyah,
    tafsirDownloadTotalAyahs,
    offlineReadyTafsirKeys,
  ];
}
