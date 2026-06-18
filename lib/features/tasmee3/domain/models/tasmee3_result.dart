import 'package:equatable/equatable.dart';

enum Tasmee3StatusLabel { excellent, veryGood, good, needsImprovement }

extension Tasmee3StatusLabelText on Tasmee3StatusLabel {
  String get text {
    switch (this) {
      case Tasmee3StatusLabel.excellent:
        return 'ممتاز';
      case Tasmee3StatusLabel.veryGood:
        return 'جيد جدًا';
      case Tasmee3StatusLabel.good:
        return 'جيد';
      case Tasmee3StatusLabel.needsImprovement:
        return 'يحتاج مراجعة';
    }
  }
}

enum AyahGrade { known, hesitant, unknown }

extension AyahGradeExt on AyahGrade {
  String get label {
    switch (this) {
      case AyahGrade.known:
        return 'أحفظها';
      case AyahGrade.hesitant:
        return 'تعثرت';
      case AyahGrade.unknown:
        return 'نسيتها';
    }
  }

  String get emoji {
    switch (this) {
      case AyahGrade.known:
        return '✅';
      case AyahGrade.hesitant:
        return '⚠️';
      case AyahGrade.unknown:
        return '❌';
    }
  }
}

class Tasmee3Result extends Equatable {
  const Tasmee3Result({required this.grades});

  final Map<int, AyahGrade> grades;

  int get knownCount =>
      grades.values.where((g) => g == AyahGrade.known).length;
  int get hesitantCount =>
      grades.values.where((g) => g == AyahGrade.hesitant).length;
  int get unknownCount =>
      grades.values.where((g) => g == AyahGrade.unknown).length;
  int get total => grades.length;
  int get score =>
      total == 0 ? 0 : ((knownCount / total) * 100).round();

  Tasmee3StatusLabel get status {
    if (score >= 90) return Tasmee3StatusLabel.excellent;
    if (score >= 75) return Tasmee3StatusLabel.veryGood;
    if (score >= 50) return Tasmee3StatusLabel.good;
    return Tasmee3StatusLabel.needsImprovement;
  }

  @override
  List<Object> get props => [grades];
}
