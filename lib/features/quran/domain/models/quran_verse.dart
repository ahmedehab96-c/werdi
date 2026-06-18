import 'package:equatable/equatable.dart';

class QuranVerse extends Equatable {
  const QuranVerse({required this.ayahNumber, required this.text});

  final int ayahNumber;
  final String text;

  @override
  List<Object> get props => [ayahNumber, text];
}
