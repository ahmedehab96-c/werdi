import 'package:equatable/equatable.dart';

class TafsirItem extends Equatable {
  const TafsirItem({
    required this.surahNumber,
    required this.ayahStart,
    required this.ayahEnd,
    required this.source,
    required this.text,
    this.isOfflineFallback = false,
  });

  final int surahNumber;
  final int ayahStart;
  final int ayahEnd;
  final String source;
  final String text;
  final bool isOfflineFallback;

  @override
  List<Object> get props =>
      [surahNumber, ayahStart, ayahEnd, source, text, isOfflineFallback];
}
