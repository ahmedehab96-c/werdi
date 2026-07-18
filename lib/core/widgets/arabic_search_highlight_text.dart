import 'package:flutter/material.dart';
import 'package:werdi/core/utils/arabic_text_normalizer.dart';

/// Highlights all query tokens inside Arabic text (word-aware + substring).
class ArabicSearchHighlightText extends StatelessWidget {
  const ArabicSearchHighlightText({
    required this.text,
    required this.query,
    super.key,
    this.style,
    this.highlightStyle,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final String query;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  static List<String> queryTokens(String query) {
    final normalized = ArabicTextNormalizer.normalize(query);
    if (normalized.isEmpty) return const [];
    return normalized
        .split(' ')
        .map((token) => token.trim())
        .where((token) => token.isNotEmpty)
        .toList();
  }

  static bool tokenMatches(String token, List<String> queryTokens) {
    if (queryTokens.isEmpty) return false;
    final normalizedToken = ArabicTextNormalizer.normalize(token);
    if (normalizedToken.isEmpty) return false;
    for (final q in queryTokens) {
      if (normalizedToken.contains(q) || q.contains(normalizedToken)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = queryTokens(query);
    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    if (tokens.isEmpty) {
      return Text(
        text,
        textAlign: textAlign,
        textDirection: TextDirection.rtl,
        style: baseStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final effectiveHighlight = highlightStyle ??
        baseStyle?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        );

    final words = text.split(RegExp(r'\s+'));
    final spans = <InlineSpan>[];
    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      final isMatch = tokenMatches(word, tokens);
      spans.add(
        TextSpan(
          text: word,
          style: isMatch ? effectiveHighlight : baseStyle,
        ),
      );
      if (i != words.length - 1) {
        spans.add(TextSpan(text: ' ', style: baseStyle));
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: textAlign,
      textDirection: TextDirection.rtl,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
