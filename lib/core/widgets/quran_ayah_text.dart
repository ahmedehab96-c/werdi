import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:werdi/core/responsive/responsive.dart';
import 'package:werdi/core/theme/app_colors.dart';
import 'package:werdi/core/utils/arabic_text_normalizer.dart';

/// Mushaf-style Uthmani ayah text (Amiri, RTL, ornamental frame).
class QuranAyahText extends StatelessWidget {
  const QuranAyahText({
    required this.text,
    super.key,
    this.textAlign = TextAlign.center,
    this.fontSize,
    this.fontScale = 1.0,
    this.lineHeight = 2.1,
    this.sepiaEnabled = false,
    this.highlightQuery,
    this.highlightEnabled = false,
    this.style,
    this.showFrame = true,
  });

  final String text;
  final TextAlign textAlign;
  final double? fontSize;
  final double fontScale;
  final double lineHeight;
  final bool sepiaEnabled;
  final String? highlightQuery;
  final bool highlightEnabled;
  final TextStyle? style;
  final bool showFrame;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseSize =
        fontSize ?? theme.textTheme.headlineMedium?.fontSize ?? 24;
    final inkColor = sepiaEnabled
        ? const Color(0xFF4E342E)
        : theme.colorScheme.onSurface;
    final responsiveScale = Responsive.ayahFontScale(context);
    final baseStyle = GoogleFonts.amiri(
      fontSize: baseSize * fontScale * responsiveScale,
      height: lineHeight,
      color: inkColor,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
    ).merge(style);

    final paperColor = sepiaEnabled
        ? const Color(0xFFF5ECD7)
        : theme.colorScheme.surfaceContainerLowest.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.35 : 0.85,
          );

    final content = _buildText(context, baseStyle);

    if (!showFrame) return content;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: paperColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.brandSecondary.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandPrimary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.valueFor(
            context,
            compact: 10,
            medium: 14,
            expanded: 16,
          ),
          vertical: Responsive.valueFor(
            context,
            compact: 12,
            medium: 16,
            expanded: 18,
          ),
        ),
        child: content,
      ),
    );
  }

  Widget _buildText(BuildContext context, TextStyle baseStyle) {
    final rawQuery = highlightQuery?.trim() ?? '';
    if (!highlightEnabled || rawQuery.isEmpty) {
      return Text(
        text,
        textAlign: textAlign,
        textDirection: TextDirection.rtl,
        style: baseStyle,
      );
    }

    final normalizedQuery = ArabicTextNormalizer.normalize(rawQuery);
    if (normalizedQuery.isEmpty) {
      return Text(
        text,
        textAlign: textAlign,
        textDirection: TextDirection.rtl,
        style: baseStyle,
      );
    }

    final tokens = text.split(RegExp(r'\s+'));
    final highlightStyle = baseStyle.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w700,
    );
    final spans = <InlineSpan>[];
    for (var i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      final isMatch = ArabicTextNormalizer.normalize(token)
          .contains(normalizedQuery);
      spans.add(
        TextSpan(
          text: token,
          style: isMatch ? highlightStyle : baseStyle,
        ),
      );
      if (i != tokens.length - 1) {
        spans.add(TextSpan(text: ' ', style: baseStyle));
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: textAlign,
      textDirection: TextDirection.rtl,
    );
  }
}
