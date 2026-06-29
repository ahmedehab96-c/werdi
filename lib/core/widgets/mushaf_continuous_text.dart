import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:werdi/core/responsive/responsive.dart';
import 'package:werdi/core/theme/app_colors.dart';

class MushafAyahSegment {
  const MushafAyahSegment({required this.ayahNumber, required this.text});

  final int ayahNumber;
  final String text;
}

/// Continuous mushaf-style ayah flow (RTL, inline end markers).
class MushafContinuousText extends StatelessWidget {
  const MushafContinuousText({
    required this.ayahs,
    super.key,
    this.fontScale = 1.0,
    this.lineHeight = 2.15,
    this.sepiaEnabled = false,
    this.highlightAyahNumber,
    this.onAyahTap,
    this.showFrame = true,
  });

  final List<MushafAyahSegment> ayahs;
  final double fontScale;
  final double lineHeight;
  final bool sepiaEnabled;
  final int? highlightAyahNumber;
  final ValueChanged<int>? onAyahTap;
  final bool showFrame;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inkColor = sepiaEnabled
        ? const Color(0xFF4E342E)
        : theme.colorScheme.onSurface;
    final baseSize = (theme.textTheme.headlineSmall?.fontSize ?? 22) *
        fontScale *
        Responsive.ayahFontScale(context);
    final baseStyle = GoogleFonts.amiri(
      fontSize: baseSize,
      height: lineHeight,
      color: inkColor,
      fontWeight: FontWeight.w500,
    );
    final markerStyle = baseStyle.copyWith(
      fontSize: baseSize * 0.72,
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w700,
    );
    final highlightStyle = baseStyle.copyWith(
      backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
    );

    final spans = <InlineSpan>[];
    for (var i = 0; i < ayahs.length; i++) {
      final ayah = ayahs[i];
      final isHighlighted = highlightAyahNumber == ayah.ayahNumber;
      spans.add(
        TextSpan(
          text: ayah.text,
          style: isHighlighted ? highlightStyle : baseStyle,
          recognizer: onAyahTap == null
              ? null
              : (TapGestureRecognizer()..onTap = () => onAyahTap!(ayah.ayahNumber)),
        ),
      );
      spans.add(TextSpan(text: ' ', style: baseStyle));
      spans.add(
        TextSpan(
          text: _ayahMarker(ayah.ayahNumber),
          style: markerStyle,
          recognizer: onAyahTap == null
              ? null
              : (TapGestureRecognizer()..onTap = () => onAyahTap!(ayah.ayahNumber)),
        ),
      );
      if (i != ayahs.length - 1) {
        spans.add(TextSpan(text: '  ', style: baseStyle));
      }
    }

    final content = SelectableText.rich(
      TextSpan(children: spans),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
    );

    if (!showFrame) return content;

    final paperColor = sepiaEnabled
        ? const Color(0xFFF5ECD7)
        : theme.colorScheme.surfaceContainerLowest.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.35 : 0.9,
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: paperColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.brandSecondary.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: content,
      ),
    );
  }

  static String _ayahMarker(int number) {
    final digits = number.toString().split('').join('');
    return ' ﴿$digits﴾ ';
  }
}
