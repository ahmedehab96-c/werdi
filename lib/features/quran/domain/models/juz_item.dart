import 'package:equatable/equatable.dart';
import 'package:werdi/features/quran/domain/models/quran_progress_status.dart';

class JuzItem extends Equatable {
  const JuzItem({
    required this.number,
    required this.surahRangeText,
    required this.status,
    required this.progress,
  });

  final int number;
  final String surahRangeText;
  final QuranProgressStatus status;
  final double progress;

  @override
  List<Object> get props => [number, surahRangeText, status, progress];
}
