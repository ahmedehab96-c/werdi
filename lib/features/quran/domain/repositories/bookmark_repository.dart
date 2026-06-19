import 'package:werdi/features/quran/presentation/cubit/quran_state.dart';

abstract interface class BookmarkRepository {
  Future<({Set<int> surahIds, List<AyahBookmark> ayahs})> getBookmarks();

  Future<bool> toggleSurah(int surahNumber);

  Future<bool> toggleAyah({
    required int surahNumber,
    required int ayahNumber,
    required String previewText,
  });
}
