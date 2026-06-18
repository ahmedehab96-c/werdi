import 'package:equatable/equatable.dart';
import 'package:werdi/features/tasmee3/domain/models/ayah_range.dart';
import 'package:werdi/features/tasmee3/domain/models/tasmee3_result.dart';

class Tasmee3Session extends Equatable {
  const Tasmee3Session({
    required this.id,
    required this.surahName,
    required this.ayahRange,
    required this.date,
    required this.result,
  });

  final String id;
  final String surahName;
  final AyahRange ayahRange;
  final DateTime date;
  final Tasmee3Result result;

  @override
  List<Object> get props => [id, surahName, ayahRange, date, result];
}
