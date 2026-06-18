import 'package:equatable/equatable.dart';

class MemorizationAyah extends Equatable {
  const MemorizationAyah({required this.number, required this.text});

  final int number;
  final String text;

  @override
  List<Object> get props => [number, text];
}
