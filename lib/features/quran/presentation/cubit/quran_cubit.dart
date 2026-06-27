import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/core/services/reciter_preferences.dart';
import 'package:werdi/features/quran/domain/repositories/bookmark_repository.dart';
import 'package:werdi/features/quran/domain/models/quran_filter.dart';
import 'package:werdi/features/quran/data/services/mp3quran_reciters_api.dart';
import 'package:werdi/features/quran/domain/models/quran_audio_reciter.dart';
import 'package:werdi/features/quran/domain/models/quran_translation_language.dart';
import 'package:werdi/features/quran/domain/repositories/quran_repository.dart';
import 'package:werdi/features/quran/domain/repositories/quran_tafsir_repository.dart';
import 'package:werdi/features/quran/presentation/cubit/quran_state.dart';

class QuranCubit extends Cubit<QuranState> {
  QuranCubit({
    required QuranRepository repository,
    required QuranTafsirRepository tafsirRepository,
    required AppPreferences preferences,
    required Mp3QuranRecitersApi mp3QuranRecitersApi,
    required BookmarkRepository bookmarkRepository,
  }) : _repository = repository,
       _tafsirRepository = tafsirRepository,
       _preferences = preferences,
       _mp3QuranRecitersApi = mp3QuranRecitersApi,
       _bookmarkRepository = bookmarkRepository,
       super(const QuranState());

  final QuranRepository _repository;
  final QuranTafsirRepository _tafsirRepository;
  final AppPreferences _preferences;
  final Mp3QuranRecitersApi _mp3QuranRecitersApi;
  final BookmarkRepository _bookmarkRepository;
  static const _tafsirSourceKey = 'quran_selected_tafsir_source';
  static const _translationLanguageKey = 'quran_selected_translation_language';
  static const _reciterKey = 'quran_selected_reciter';
  static const _lastReadKey = 'quran_last_read_surah';
  static const _searchFocusModeKey = 'settings_search_focus_mode';
  static const _preferredTafsirSourceIds = [
    'ar.waseet',
    'ar.muyassar',
  ];
  static const _preferredEgyptianTafsirHints = [
    'مصر',
    'الأزهر',
    'مصري',
  ];
  Timer? _searchDebounce;

  Future<void> initialize() async {
    final surahs = await _repository.getSurahs();
    final juzList = await _repository.getJuz();
    final savedReciter = await _preferences.getString(_reciterKey);
    final savedLastRead = await _preferences.getString(_lastReadKey);
    final savedSearchFocusMode =
        await _preferences.getString(_searchFocusModeKey);
    final savedLanguage = await _preferences.getString(_translationLanguageKey);

    final defaultReciters = QuranAudioReciter.ayahCapableSorted();
    final selectedAudioReciter = ReciterPreferences.resolve(
      candidates: defaultReciters,
      savedKey: savedReciter,
    );
    final selectedLanguage = QuranTranslationLanguage.values.firstWhere(
      (item) => item.name == savedLanguage,
      orElse: () => QuranTranslationLanguage.enSaheeh,
    );

    emit(
      state.copyWith(
        isLoading: false,
        surahs: surahs,
        juzList: juzList,
        lastReadPlaceholder: savedLastRead ?? '',
        recentSearches: const [],
        audioReciters: defaultReciters,
        selectedAudioReciter: selectedAudioReciter,
        isLoadingAudioReciters: true,
        selectedTranslationLanguage: selectedLanguage,
        openSearchResultsInFocusMode: savedSearchFocusMode != '0',
      ),
    );

    unawaited(_loadSecondaryData(
      savedSource: await _preferences.getString(_tafsirSourceKey),
      savedReciter: savedReciter,
    ));
  }

  Future<void> _loadSecondaryData({
    required String? savedSource,
    required String? savedReciter,
  }) async {
    final tafsirSources = await _tafsirRepository.getSources();
    final selectedSource = _resolvePreferredTafsirSource(
      sources: tafsirSources,
      savedSource: savedSource,
    );

    List<QuranAudioReciter> audioReciters;
    try {
      final fetched = await _mp3QuranRecitersApi.fetchRecitersSorted();
      audioReciters = ReciterPreferences.filterAyahCapable(fetched);
    } catch (_) {
      audioReciters = QuranAudioReciter.ayahCapableSorted();
    }
    if (audioReciters.isEmpty) {
      audioReciters = QuranAudioReciter.ayahCapableSorted();
    }
    final selectedAudioReciter = ReciterPreferences.resolve(
      candidates: audioReciters,
      savedKey: savedReciter,
    );
    await _preferences.setString(
      ReciterPreferences.selectedReciterKey,
      selectedAudioReciter.persistenceKey,
    );

    List<AyahBookmark> bookmarkedAyahs = const [];
    Set<int> bookmarkedSurahIds = const {};
    try {
      final saved = await _bookmarkRepository.getBookmarks();
      bookmarkedSurahIds = saved.surahIds;
      bookmarkedAyahs = saved.ayahs;
    } catch (_) {}

    if (isClosed) return;
    emit(
      state.copyWith(
        bookmarkedSurahIds: bookmarkedSurahIds,
        bookmarkedAyahs: bookmarkedAyahs,
        lastMemorizedPositions: const [],
        tafsirSources: tafsirSources,
        selectedTafsirSource: selectedSource,
        audioReciters: audioReciters,
        selectedAudioReciter: selectedAudioReciter,
        isLoadingAudioReciters: false,
      ),
    );
  }

  String _resolvePreferredTafsirSource({
    required List<String> sources,
    required String? savedSource,
  }) {
    if (sources.isEmpty) return '';
    if (savedSource != null && sources.contains(savedSource)) {
      return savedSource;
    }
    for (final preferredId in _preferredTafsirSourceIds) {
      if (sources.contains(preferredId)) return preferredId;
    }
    for (final source in sources) {
      final lower = source.toLowerCase();
      if (_preferredEgyptianTafsirHints.any(lower.contains)) {
        return source;
      }
    }
    return sources.first;
  }

  void setQuery(String query) => emit(state.copyWith(query: query));

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
    _searchDebounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(ayahSearchHits: const []));
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 250), () async {
      final hits = await _repository.searchAyahs(query: trimmed, limit: 40);
      final mapped = hits.map((hit) {
        final surah = state.surahByNumber(hit.surahNumber);
        return AyahSearchResult(
          surahNumber: hit.surahNumber,
          surahNameArabic: surah?.nameArabic ?? '',
          ayahNumber: hit.ayahNumber,
          text: hit.text,
        );
      }).toList();
      emit(state.copyWith(ayahSearchHits: mapped));
    });
  }

  void setFilter(QuranFilter filter) => emit(state.copyWith(filter: filter));

  void setSelectedTab(int index) => emit(state.copyWith(selectedTab: index));

  void toggleBookmark(int surahNumber) {
    final updated = Set<int>.from(state.bookmarkedSurahIds);
    if (updated.contains(surahNumber)) {
      updated.remove(surahNumber);
    } else {
      updated.add(surahNumber);
    }
    emit(state.copyWith(bookmarkedSurahIds: updated));
    _bookmarkRepository.toggleSurah(surahNumber).catchError((_) => false);
  }

  void toggleAyahBookmark({
    required int surahNumber,
    required int ayahNumber,
    required String previewText,
  }) {
    final existing = state.bookmarkedAyahs;
    final alreadyBookmarked = existing.any(
      (b) => b.surahNumber == surahNumber && b.ayahNumber == ayahNumber,
    );
    final List<AyahBookmark> updated;
    if (alreadyBookmarked) {
      updated = existing
          .where((b) => !(b.surahNumber == surahNumber && b.ayahNumber == ayahNumber))
          .toList();
    } else {
      final surah = state.surahByNumber(surahNumber);
      updated = [
        ...existing,
        AyahBookmark(
          surahNumber: surahNumber,
          surahNameArabic: surah?.nameArabic ?? '',
          ayahNumber: ayahNumber,
          previewText: previewText,
        ),
      ];
    }
    emit(state.copyWith(bookmarkedAyahs: updated));
    _bookmarkRepository
        .toggleAyah(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          previewText: previewText,
        )
        .catchError((_) => false);
  }

  void addRecentSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final updated = [
      trimmed,
      ...state.recentSearches.where(
        (item) => item.toLowerCase() != trimmed.toLowerCase(),
      ),
    ];
    emit(state.copyWith(recentSearches: updated.take(6).toList()));
  }

  List<AyahRange> buildSurahRanges(int surahNumber) {
    final surah = state.surahByNumber(surahNumber);
    if (surah == null) return const [];
    final verseCount = surah.verseCount;
    const chunkSize = 10;
    final ranges = <AyahRange>[];
    var start = 1;
    var index = 0;
    while (start <= verseCount) {
      final end = (start + chunkSize - 1 > verseCount)
          ? verseCount
          : start + chunkSize - 1;
      ranges.add(
        AyahRange(
          label: 'مقطع ${index + 1}',
          fromAyah: start,
          toAyah: end,
          progress: (0.22 + (index * 0.18)).clamp(0.0, 1.0),
        ),
      );
      start = end + 1;
      index++;
    }
    return ranges;
  }

  Future<void> loadTafsir({
    required int surahNumber,
    required int ayahStart,
    required int ayahEnd,
    String? source,
  }) async {
    final selected = source ?? state.selectedTafsirSource;
    if (selected.isEmpty) return;
    emit(state.copyWith(isLoadingTafsir: true, selectedTafsirSource: selected));
    await _preferences.setString(_tafsirSourceKey, selected);
    final tafsir = await _tafsirRepository.getTafsir(
      surahNumber: surahNumber,
      ayahStart: ayahStart,
      ayahEnd: ayahEnd,
      source: selected,
    );
    emit(
      state.copyWith(
        isLoadingTafsir: false,
        selectedTafsirSource: selected,
        currentTafsir: tafsir,
      ),
    );
  }

  Future<void> loadTranslations({
    required int surahNumber,
    required int ayahStart,
    required int ayahEnd,
    QuranTranslationLanguage? language,
  }) async {
    final selectedLanguage = language ?? state.selectedTranslationLanguage;
    await _preferences.setString(
      _translationLanguageKey,
      selectedLanguage.name,
    );
    emit(state.copyWith(isLoadingTranslations: true));
    final lines = await _repository.getVerseTranslations(
      surahNumber: surahNumber,
      ayahStart: ayahStart,
      ayahEnd: ayahEnd,
      language: selectedLanguage,
    );
    emit(
      state.copyWith(
        isLoadingTranslations: false,
        translationLines: lines,
        selectedTranslationLanguage: selectedLanguage,
      ),
    );
  }

  Future<void> setSelectedAudioReciter(QuranAudioReciter reciter) async {
    if (!reciter.supportsAyahPlayback) return;
    await _preferences.setString(
      ReciterPreferences.selectedReciterKey,
      reciter.persistenceKey,
    );
    emit(state.copyWith(selectedAudioReciter: reciter));
  }

  String getAudioVerseUrl({required int surahNumber, required int ayahNumber}) {
    final reciter = state.selectedAudioReciter;
    if (reciter == null) return '';
    return _repository.getAudioVerseUrl(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      reciter: reciter,
    );
  }

  List<String> getAudioVerseUrls({
    required int surahNumber,
    required int ayahNumber,
  }) {
    final reciter = state.selectedAudioReciter;
    if (reciter == null) return const [];
    return _repository.getAudioVerseUrls(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      reciter: reciter,
    );
  }

  List<String> getAudioAyahUrls({
    required int surahNumber,
    required int ayahNumber,
  }) {
    final reciter = state.selectedAudioReciter;
    if (reciter == null) return const [];
    return _repository.getAudioAyahUrls(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      reciter: reciter,
    );
  }

  String getVerseWebUrl({required int surahNumber, required int ayahNumber}) {
    return _repository.getVerseWebUrl(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
  }

  Future<void> loadSurahVerses(int surahNumber) async {
    emit(state.copyWith(isLoadingSurahVerses: true));
    try {
      final verses = await _repository.getSurahVerses(surahNumber: surahNumber);
      final surah = state.surahByNumber(surahNumber);
      final lastRead = surah != null ? 'سورة ${surah.nameArabic}' : null;
      if (lastRead != null) {
        _preferences.setString(_lastReadKey, lastRead).ignore();
      }
      emit(
        state.copyWith(
          isLoadingSurahVerses: false,
          currentSurahVerses: verses,
          lastReadPlaceholder: lastRead ?? state.lastReadPlaceholder,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingSurahVerses: false,
          currentSurahVerses: const [],
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
