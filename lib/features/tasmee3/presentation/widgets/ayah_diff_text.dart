import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final baseStyle = GoogleFonts.amiri(
      fontSize: (22 * fontScale).sp,
      height: 2.0,
      fontWeight: FontWeight.w600,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 10.h,
        spacing: 8.w,
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
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
              child: child,
            ),
          );
        }),
      ),
    );
  }
}
