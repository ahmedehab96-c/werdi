import 'package:equatable/equatable.dart';

class QuranAyahSearchHit extends Equatable {
  const QuranAyahSearchHit({
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
  });

  final int surahNumber;
  final int ayahNumber;
  final String text;

  @override
  List<Object> get props => [surahNumber, ayahNumber, text];
}
