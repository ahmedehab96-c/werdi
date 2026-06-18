import 'package:equatable/equatable.dart';

class AyahRange extends Equatable {
  const AyahRange({required this.start, required this.end});

  final int start;
  final int end;

  String get label => 'من $start إلى $end';

  @override
  List<Object> get props => [start, end];
}
