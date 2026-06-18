import 'package:equatable/equatable.dart';
import 'package:werdi/features/quran/domain/models/quran_progress_status.dart';

class SurahItem extends Equatable {
  const SurahItem({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.verseCount,
    required this.revelationPlace,
    required this.status,
    required this.progress,
  });

  final int number;
  final String nameArabic;
  final String nameEnglish;
  final int verseCount;
  final String revelationPlace;
  final QuranProgressStatus status;
  final double progress;

  @override
  List<Object> get props => [
    number,
    nameArabic,
    nameEnglish,
    verseCount,
    revelationPlace,
    status,
    progress,
  ];
}
