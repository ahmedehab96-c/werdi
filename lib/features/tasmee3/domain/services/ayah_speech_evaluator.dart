import 'package:werdi/features/tasmee3/domain/services/ayah_text_utils.dart';

export 'package:werdi/features/tasmee3/domain/services/ayah_text_utils.dart'
    show splitAyahWords, accuracyFromWordMarks;

/// Compares recognized speech against the expected Quranic ayah.
class AyahSpeechEvaluation {
  const AyahSpeechEvaluation({
    required this.expectedWords,
    required this.expectedWordCorrect,
    required this.spokenText,
    required this.accuracyPercent,
    required this.isMostlyNonArabic,
  });

  final List<String> expectedWords;
  final List<bool> expectedWordCorrect;
  final String spokenText;
  final int accuracyPercent;
  final bool isMostlyNonArabic;

  static AyahSpeechEvaluation empty(String expected) {
    final words = splitAyahWords(expected);
    return AyahSpeechEvaluation(
      expectedWords: words,
      expectedWordCorrect: List<bool>.filled(words.length, false),
      spokenText: '',
      accuracyPercent: 0,
      isMostlyNonArabic: false,
    );
  }

  static AyahSpeechEvaluation evaluate({
    required String expected,
    required String spoken,
  }) {
    final expectedWords = splitAyahWords(expected);
    if (expectedWords.isEmpty) {
      return empty(expected);
    }
    if (spoken.trim().isEmpty) {
      return AyahSpeechEvaluation(
        expectedWords: expectedWords,
        expectedWordCorrect: List<bool>.filled(expectedWords.length, false),
        spokenText: '',
        accuracyPercent: 0,
        isMostlyNonArabic: false,
      );
    }
    if (_isMostlyNonArabic(spoken)) {
      return AyahSpeechEvaluation(
        expectedWords: expectedWords,
        expectedWordCorrect: List<bool>.filled(expectedWords.length, false),
        spokenText: spoken,
        accuracyPercent: 0,
        isMostlyNonArabic: true,
      );
    }

    final normExpected = expectedWords.map(_normalizeArabic).toList();
    final spokenWords = splitAyahWords(spoken);
    final normSpoken = spokenWords.map(_normalizeArabic).toList();

    final matchedExpected = _lcsMatchedExpectedIndexes(
      spoken: normSpoken,
      expected: normExpected,
    );
    final expectedWordCorrect = List<bool>.generate(
      expectedWords.length,
      (i) => matchedExpected.contains(i),
    );
    final correct = matchedExpected.length;
    final accuracy = ((correct / expectedWords.length) * 100).round();

    return AyahSpeechEvaluation(
      expectedWords: expectedWords,
      expectedWordCorrect: expectedWordCorrect,
      spokenText: spoken,
      accuracyPercent: accuracy,
      isMostlyNonArabic: false,
    );
  }

  static bool _isMostlyNonArabic(String text) {
    final chars = text.replaceAll(RegExp(r'\s'), '');
    if (chars.isEmpty) return false;
    final arabic =
        RegExp(r'[\u0600-\u06FF]').allMatches(chars).length;
    return arabic / chars.length < 0.4;
  }

  static String _normalizeArabic(String text) {
    return text
        .replaceAll(RegExp(r'[\u0640]'), '')
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll(RegExp(r'[\u06DD\u06DE\u06E9]'), '')
        .replaceAll(RegExp(r'[^\u0621-\u063A\u0641-\u064A0-9 ]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ٱ', 'ا')
        .replaceAll('ـ', '')
        .trim();
  }

  static Set<int> _lcsMatchedExpectedIndexes({
    required List<String> spoken,
    required List<String> expected,
  }) {
    final m = spoken.length;
    final n = expected.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        if (spoken[i - 1].isNotEmpty && spoken[i - 1] == expected[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
        }
      }
    }
    final matched = <int>{};
    var i = m;
    var j = n;
    while (i > 0 && j > 0) {
      if (spoken[i - 1].isNotEmpty && spoken[i - 1] == expected[j - 1]) {
        matched.add(j - 1);
        i -= 1;
        j -= 1;
      } else if (dp[i - 1][j] >= dp[i][j - 1]) {
        i -= 1;
      } else {
        j -= 1;
      }
    }
    return matched;
  }
}
