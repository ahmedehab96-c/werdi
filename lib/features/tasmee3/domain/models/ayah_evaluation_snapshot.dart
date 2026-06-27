import 'package:equatable/equatable.dart';

class AyahEvaluationSnapshot extends Equatable {
  const AyahEvaluationSnapshot({
    required this.ayahNumber,
    required this.expectedText,
    required this.spokenText,
    required this.expectedWords,
    required this.expectedWordCorrect,
    required this.accuracyPercent,
    required this.gradeLabel,
  });

  final int ayahNumber;
  final String expectedText;
  final String spokenText;
  final List<String> expectedWords;
  final List<bool> expectedWordCorrect;
  final int accuracyPercent;
  final String gradeLabel;

  bool get hasErrors => expectedWordCorrect.any((c) => !c);

  @override
  List<Object?> get props => [
        ayahNumber,
        expectedText,
        spokenText,
        expectedWords,
        expectedWordCorrect,
        accuracyPercent,
        gradeLabel,
      ];
}
