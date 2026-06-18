import 'package:werdi/features/quran/domain/models/quran_text_source.dart';
import 'package:werdi/features/quran/domain/models/quran_verse.dart';

class QuranCachedSurahPayload {
  const QuranCachedSurahPayload({
    required this.surahNumber,
    required this.verses,
    required this.source,
    required this.cachedAt,
  });

  final int surahNumber;
  final List<QuranVerse> verses;
  final QuranTextSource source;
  final DateTime cachedAt;
}
