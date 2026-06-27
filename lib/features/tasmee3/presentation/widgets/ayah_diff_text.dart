import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mushaf-style ayah with per-word coloring: correct vs mistake/missed.
class AyahDiffText extends StatelessWidget {
  const AyahDiffText({
    required this.words,
    required this.wordCorrect,
    super.key,
    this.fontScale = 1.0,
  });

  final List<String> words;
  final List<bool> wordCorrect;
  final double fontScale;

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
              index < wordCorrect.length ? wordCorrect[index] : false;
          return Text(
            words[index],
            style: baseStyle.copyWith(
              color: correct ? scheme.primary : scheme.error,
              decoration: correct ? null : TextDecoration.underline,
              decorationColor: scheme.error,
            ),
          );
        }),
      ),
    );
  }
}
