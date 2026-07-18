import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:werdi/core/responsive/responsive_helper.dart';
import 'package:werdi/core/theme/app_spacing.dart';

/// Mushaf-style ayah with per-word coloring; words are tappable when [onWordTap] is set.
class AyahDiffText extends StatelessWidget {
  const AyahDiffText({
    required this.words,
    required this.wordCorrect,
    super.key,
    this.fontScale = 1.0,
    this.onWordTap,
  });

  final List<String> words;
  final List<bool> wordCorrect;
  final double fontScale;
  final ValueChanged<int>? onWordTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fontSize =
        ResponsiveHelper.adaptiveFont(context, 22 * fontScale).clamp(16.0, 32.0);
    final baseStyle = GoogleFonts.amiri(
      fontSize: fontSize,
      height: 2.0,
      fontWeight: FontWeight.w600,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
        alignment: WrapAlignment.center,
        runSpacing: AppSpacing.sm,
        spacing: AppSpacing.xs,
        children: List.generate(words.length, (index) {
          final correct =
              index < wordCorrect.length ? wordCorrect[index] : true;
          final color = correct ? scheme.primary : scheme.error;
          final child = Text(
            words[index],
            style: baseStyle.copyWith(
              color: color,
              decoration: correct ? null : TextDecoration.underline,
              decorationColor: scheme.error,
            ),
          );
          if (onWordTap == null) return child;
          return InkWell(
            onTap: () => onWordTap!(index),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxs,
                vertical: AppSpacing.xxs,
              ),
              child: child,
            ),
          );
        }),
      ),
    );
  }
}
