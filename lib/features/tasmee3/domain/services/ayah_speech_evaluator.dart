import 'package:werdi/core/utils/arabic_text_normalizer.dart';
import 'package:werdi/features/tasmee3/domain/services/ayah_text_utils.dart';

export 'package:werdi/features/tasmee3/domain/services/ayah_text_utils.dart'
    show splitAyahWords, accuracyFromWordMarks;

/// Compares recognized speech against the expected Quranic ayah.
///
/// Uses Arabic normalization + fuzzy word matching so common STT mistakes
/// (merged tokens, 1–2 letter typos) do not mark a correct recitation as wrong.
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

    final normExpected = expectedWords.map(normalizeArabicWord).toList();
    final normSpoken = _expandSpokenTokens(
      splitAyahWords(spoken).map(normalizeArabicWord).toList(),
      normExpected,
    );

    final matchedExpected = _fuzzyLcsMatchedExpectedIndexes(
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

  /// Evaluates a multi-ayah block against one continuous spoken transcript.
  ///
  /// Aligns spoken words to ayahs in order so later ayahs are not compared
  /// against the whole transcript in isolation.
  static List<AyahSpeechEvaluation> evaluateBlock({
    required List<String> expectedAyahs,
    required String spoken,
  }) {
    if (expectedAyahs.isEmpty) return const [];

    if (spoken.trim().isEmpty || _isMostlyNonArabic(spoken)) {
      return expectedAyahs
          .map(
            (ayah) => evaluate(expected: ayah, spoken: spoken),
          )
          .toList();
    }

    final expectedWordLists =
        expectedAyahs.map(splitAyahWords).toList(growable: false);
    final normExpectedLists = expectedWordLists
        .map((words) => words.map(normalizeArabicWord).toList())
        .toList(growable: false);

    final allExpected = <String>[
      for (final words in normExpectedLists) ...words,
    ];
    final spokenTokens = _expandSpokenTokens(
      splitAyahWords(spoken).map(normalizeArabicWord).toList(),
      allExpected,
    );

    final results = <AyahSpeechEvaluation>[];
    var spokenCursor = 0;

    for (var ayahIndex = 0; ayahIndex < expectedAyahs.length; ayahIndex++) {
      final expectedWords = expectedWordLists[ayahIndex];
      final normExpected = normExpectedLists[ayahIndex];
      if (expectedWords.isEmpty) {
        results.add(empty(expectedAyahs[ayahIndex]));
        continue;
      }

      final remainingSpoken = spokenTokens.sublist(
        spokenCursor.clamp(0, spokenTokens.length),
      );
      final match = _bestSequentialMatch(
        spoken: remainingSpoken,
        expected: normExpected,
      );

      final expectedWordCorrect = List<bool>.generate(
        expectedWords.length,
        (i) => match.matchedExpected.contains(i),
      );
      final correct = match.matchedExpected.length;
      final accuracy = ((correct / expectedWords.length) * 100).round();

      spokenCursor += match.spokenConsumed;
      results.add(
        AyahSpeechEvaluation(
          expectedWords: expectedWords,
          expectedWordCorrect: expectedWordCorrect,
          spokenText: spoken,
          accuracyPercent: accuracy,
          isMostlyNonArabic: false,
        ),
      );
    }

    return results;
  }

  /// Public for tests and shared Quran STT normalization.
  static String normalizeArabicWord(String text) {
    var value = ArabicTextNormalizer.normalize(text);
    value = value
        .replaceAll('ء', '')
        .replaceAll(RegExp(r'(.)\1{2,}'), r'$1$1');
    return value.trim();
  }

  static bool wordsFuzzyEqual(String a, String b) {
    if (a.isEmpty || b.isEmpty) return false;
    if (a == b) return true;

    final maxLen = a.length > b.length ? a.length : b.length;
    final distance = _levenshtein(a, b);
    if (maxLen <= 3) return distance <= 1;
    if (maxLen <= 6) return distance <= 1;
    if (maxLen <= 10) return distance <= 2;
    return distance <= 3;
  }

  static bool _isMostlyNonArabic(String text) {
    final chars = text.replaceAll(RegExp(r'\s'), '');
    if (chars.isEmpty) return false;
    final arabic = RegExp(r'[\u0600-\u06FF]').allMatches(chars).length;
    return arabic / chars.length < 0.4;
  }

  /// Splits STT-merged tokens using expected words as a dictionary.
  static List<String> _expandSpokenTokens(
    List<String> spoken,
    List<String> expected,
  ) {
    if (spoken.isEmpty || expected.isEmpty) return spoken;

    final expectedSet = expected.where((w) => w.isNotEmpty).toSet();
    final expanded = <String>[];

    for (final token in spoken) {
      if (token.isEmpty) continue;
      if (expectedSet.contains(token) || token.length < 6) {
        expanded.add(token);
        continue;
      }

      final parts = _splitMergedToken(token, expectedSet);
      if (parts != null && parts.length > 1) {
        expanded.addAll(parts);
      } else {
        expanded.add(token);
      }
    }
    return expanded;
  }

  static List<String>? _splitMergedToken(
    String token,
    Set<String> dictionary,
  ) {
    final n = token.length;
    final dp = List<List<String>?>.filled(n + 1, null);
    dp[0] = const <String>[];

    for (var i = 0; i < n; i++) {
      final prefix = dp[i];
      if (prefix == null) continue;
      for (var j = i + 1; j <= n; j++) {
        final piece = token.substring(i, j);
        if (!dictionary.contains(piece)) continue;
        final next = [...prefix, piece];
        final existing = dp[j];
        if (existing == null || next.length < existing.length) {
          dp[j] = next;
        }
      }
    }
    return dp[n];
  }

  static Set<int> _fuzzyLcsMatchedExpectedIndexes({
    required List<String> spoken,
    required List<String> expected,
  }) {
    return _fuzzyLcs(spoken: spoken, expected: expected).matchedExpected;
  }

  static _LcsResult _fuzzyLcs({
    required List<String> spoken,
    required List<String> expected,
  }) {
    final m = spoken.length;
    final n = expected.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        if (wordsFuzzyEqual(spoken[i - 1], expected[j - 1])) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
        }
      }
    }

    final matchedExpected = <int>{};
    var lastSpokenIndex = -1;
    var i = m;
    var j = n;
    while (i > 0 && j > 0) {
      if (wordsFuzzyEqual(spoken[i - 1], expected[j - 1])) {
        matchedExpected.add(j - 1);
        if (lastSpokenIndex < 0) lastSpokenIndex = i - 1;
        i -= 1;
        j -= 1;
      } else if (dp[i - 1][j] >= dp[i][j - 1]) {
        i -= 1;
      } else {
        j -= 1;
      }
    }

    // Find first matched spoken index for a tight consume window.
    var firstSpokenIndex = lastSpokenIndex;
    i = m;
    j = n;
    final spokenMatched = <int>[];
    while (i > 0 && j > 0) {
      if (wordsFuzzyEqual(spoken[i - 1], expected[j - 1])) {
        spokenMatched.add(i - 1);
        i -= 1;
        j -= 1;
      } else if (dp[i - 1][j] >= dp[i][j - 1]) {
        i -= 1;
      } else {
        j -= 1;
      }
    }
    if (spokenMatched.isNotEmpty) {
      firstSpokenIndex = spokenMatched.last;
      lastSpokenIndex = spokenMatched.first;
    }

    return _LcsResult(
      matchedExpected: matchedExpected,
      firstSpokenIndex: firstSpokenIndex,
      lastSpokenIndex: lastSpokenIndex,
    );
  }

  static _SequentialMatch _bestSequentialMatch({
    required List<String> spoken,
    required List<String> expected,
  }) {
    if (expected.isEmpty) {
      return const _SequentialMatch(matchedExpected: {}, spokenConsumed: 0);
    }
    if (spoken.isEmpty) {
      return const _SequentialMatch(matchedExpected: {}, spokenConsumed: 0);
    }

    _LcsResult? best;
    var bestStart = 0;

    // Prefer matching near the start of remaining spoken words.
    final maxStart = spoken.length < 3 ? spoken.length : 3;
    for (var start = 0; start < maxStart; start++) {
      final window = spoken.sublist(start);
      final result = _fuzzyLcs(spoken: window, expected: expected);
      if (best == null ||
          result.matchedExpected.length > best.matchedExpected.length) {
        best = result;
        bestStart = start;
        if (result.matchedExpected.length == expected.length) break;
      }
    }

    best ??= const _LcsResult(
      matchedExpected: {},
      firstSpokenIndex: -1,
      lastSpokenIndex: -1,
    );

    if (best.matchedExpected.isEmpty || best.lastSpokenIndex < 0) {
      // Advance a little so we do not stall on one ayah forever.
      final fallback = expected.length.clamp(1, spoken.length);
      return _SequentialMatch(
        matchedExpected: best.matchedExpected,
        spokenConsumed: fallback,
      );
    }

    final consumed = bestStart + best.lastSpokenIndex + 1;
    return _SequentialMatch(
      matchedExpected: best.matchedExpected,
      spokenConsumed: consumed.clamp(1, spoken.length),
    );
  }

  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final prev = List<int>.generate(b.length + 1, (i) => i);
    final curr = List<int>.filled(b.length + 1, 0);

    for (var i = 1; i <= a.length; i++) {
      curr[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        final deletion = prev[j] + 1;
        final insertion = curr[j - 1] + 1;
        final substitution = prev[j - 1] + cost;
        curr[j] = deletion < insertion
            ? (deletion < substitution ? deletion : substitution)
            : (insertion < substitution ? insertion : substitution);
      }
      for (var j = 0; j <= b.length; j++) {
        prev[j] = curr[j];
      }
    }
    return prev[b.length];
  }
}

class _LcsResult {
  const _LcsResult({
    required this.matchedExpected,
    required this.firstSpokenIndex,
    required this.lastSpokenIndex,
  });

  final Set<int> matchedExpected;
  final int firstSpokenIndex;
  final int lastSpokenIndex;
}

class _SequentialMatch {
  const _SequentialMatch({
    required this.matchedExpected,
    required this.spokenConsumed,
  });

  final Set<int> matchedExpected;
  final int spokenConsumed;
}
