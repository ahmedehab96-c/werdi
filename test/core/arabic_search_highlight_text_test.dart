import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/core/widgets/arabic_search_highlight_text.dart';

void main() {
  group('ArabicSearchHighlightText', () {
    test('queryTokens splits normalized words', () {
      expect(
        ArabicSearchHighlightText.queryTokens('بسم  الله'),
        ['بسم', 'الله'],
      );
    });

    test('tokenMatches handles hamza variants', () {
      final tokens = ArabicSearchHighlightText.queryTokens('الرحمن');
      expect(
        ArabicSearchHighlightText.tokenMatches('ٱلرَّحْمَٰنِ', tokens),
        isTrue,
      );
    });

    test('tokenMatches returns false for empty query', () {
      expect(
        ArabicSearchHighlightText.tokenMatches('الله', const []),
        isFalse,
      );
    });
  });
}
