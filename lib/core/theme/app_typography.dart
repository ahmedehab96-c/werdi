import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:werdi/core/theme/app_colors.dart';

final class AppTypography {
  const AppTypography._();

  static TextTheme lightTextTheme() {
    final base = GoogleFonts.tajawalTextTheme();
    return base.copyWith(
      displaySmall: GoogleFonts.tajawal(
        fontSize: 36,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryLight,
      ),
      headlineLarge: GoogleFonts.tajawal(
        fontSize: 32,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryLight,
      ),
      titleLarge: GoogleFonts.tajawal(
        fontSize: 24,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryLight,
      ),
      titleMedium: GoogleFonts.tajawal(
        fontSize: 20,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      titleSmall: GoogleFonts.tajawal(
        fontSize: 18,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondaryLight,
      ),
      bodyLarge: GoogleFonts.tajawal(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryLight,
      ),
      bodyMedium: GoogleFonts.tajawal(
        fontSize: 14,
        height: 1.55,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondaryLight,
      ),
      bodySmall: GoogleFonts.tajawal(
        fontSize: 12,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: AppColors.textMutedLight,
      ),
      labelLarge: GoogleFonts.tajawal(
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryLight,
      ),
      labelMedium: GoogleFonts.tajawal(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondaryLight,
      ),
    );
  }

  static TextTheme darkTextTheme() {
    final base = GoogleFonts.tajawalTextTheme();
    return base.copyWith(
      displaySmall: GoogleFonts.tajawal(
        fontSize: 36,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryDark,
      ),
      headlineLarge: GoogleFonts.tajawal(
        fontSize: 32,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryDark,
      ),
      titleLarge: GoogleFonts.tajawal(
        fontSize: 24,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryDark,
      ),
      titleMedium: GoogleFonts.tajawal(
        fontSize: 20,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      titleSmall: GoogleFonts.tajawal(
        fontSize: 18,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondaryDark,
      ),
      bodyLarge: GoogleFonts.tajawal(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark,
      ),
      bodyMedium: GoogleFonts.tajawal(
        fontSize: 14,
        height: 1.55,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondaryDark,
      ),
      bodySmall: GoogleFonts.tajawal(
        fontSize: 12,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: AppColors.textMutedDark,
      ),
      labelLarge: GoogleFonts.tajawal(
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryDark,
      ),
      labelMedium: GoogleFonts.tajawal(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondaryDark,
      ),
    );
  }
}
