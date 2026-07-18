import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/features/tasmee3/domain/services/ayah_speech_evaluator.dart';

void main() {
  group('AyahSpeechEvaluation.normalizeArabicWord', () {
    test('strips diacritics and unifies letter forms', () {
      expect(
        AyahSpeechEvaluation.normalizeArabicWord('بِسْمِ'),
        'بسم',
      );
      expect(
        AyahSpeechEvaluation.normalizeArabicWord('الرَّحْمَـٰنِ'),
        'الرحمن',
      );
      expect(
        AyahSpeechEvaluation.normalizeArabicWord('إِيَّاكَ'),
        'اياك',
      );
    });
  });

  group('AyahSpeechEvaluation.wordsFuzzyEqual', () {
    test('accepts small STT typos', () {
      expect(
        AyahSpeechEvaluation.wordsFuzzyEqual('الرحمن', 'الرحمان'),
        isTrue,
      );
      expect(
        AyahSpeechEvaluation.wordsFuzzyEqual('بسم', 'باسم'),
        isTrue,
      );
      expect(
        AyahSpeechEvaluation.wordsFuzzyEqual('الله', 'الرحمن'),
        isFalse,
      );
    });
  });

  group('AyahSpeechEvaluation.evaluate', () {
    test('scores perfect Arabic recitation highly', () {
      const expected = 'بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ';
      const spoken = 'بسم الله الرحمن الرحيم';

      final result = AyahSpeechEvaluation.evaluate(
        expected: expected,
        spoken: spoken,
      );

      expect(result.accuracyPercent, greaterThanOrEqualTo(90));
      expect(result.expectedWordCorrect.every((c) => c), isTrue);
    });

    test('handles merged STT tokens', () {
      const expected = 'بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ';
      const spoken = 'بسمالله الرحمن الرحيم';

      final result = AyahSpeechEvaluation.evaluate(
        expected: expected,
        spoken: spoken,
      );

      expect(result.accuracyPercent, greaterThanOrEqualTo(75));
    });

    test('returns zero for empty spoken text', () {
      final result = AyahSpeechEvaluation.evaluate(
        expected: 'الْحَمْدُ لِلَّهِ',
        spoken: '',
      );
      expect(result.accuracyPercent, 0);
      expect(result.expectedWordCorrect.every((c) => !c), isTrue);
    });

    test('flags mostly non-Arabic speech', () {
      final result = AyahSpeechEvaluation.evaluate(
        expected: 'بِسْمِ اللَّهِ',
        spoken: 'in the name of god',
      );
      expect(result.isMostlyNonArabic, isTrue);
      expect(result.accuracyPercent, 0);
    });
  });

  group('AyahSpeechEvaluation.evaluateBlock', () {
    test('aligns multi-ayah recitation in order', () {
      final ayahs = [
        'بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ',
        'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      ];
      const spoken =
          'بسم الله الرحمن الرحيم الحمد لله رب العالمين';

      final results = AyahSpeechEvaluation.evaluateBlock(
        expectedAyahs: ayahs,
        spoken: spoken,
      );

      expect(results, hasLength(2));
      expect(results[0].accuracyPercent, greaterThanOrEqualTo(75));
      expect(results[1].accuracyPercent, greaterThanOrEqualTo(75));
    });
  });
}
