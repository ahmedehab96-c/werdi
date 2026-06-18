import 'package:equatable/equatable.dart';

class TafsirItem extends Equatable {
  const TafsirItem({
    required this.surahNumber,
    required this.ayahStart,
    required this.ayahEnd,
    required this.source,
    required this.text,
  });

  final int surahNumber;
  final int ayahStart;
  final int ayahEnd;
  final String source;
  final String text;

  @override
  List<Object> get props => [surahNumber, ayahStart, ayahEnd, source, text];
}
