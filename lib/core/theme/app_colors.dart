import 'package:flutter/material.dart';

final class AppColors {
  const AppColors._();

  // Brand — WERDI palette (deep navy + gold + light-blue)
  static const Color brandPrimary = Color(0xFF1A56C4);
  static const Color brandSecondary = Color(0xFFC9A227);
  static const Color brandAccent = Color(0xFF4FC3F7);
  static const Color brandPrimaryContainer = Color(0xFFD0E4FF);
  static const Color brandAccentContainer = Color(0xFF0A1E3D);

  // Light tokens
  static const Color lightBackground = Color(0xFFF0F4FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFE8EEF8);
  static const Color lightBorder = Color(0xFFC5D3E8);

  // Dark tokens — deep navy matching WERDI logo background
  static const Color darkBackground = Color(0xFF060E22);
  static const Color darkSurface = Color(0xFF0D1A33);
  static const Color darkSurfaceSubtle = Color(0xFF111F3C);
  static const Color darkBorder = Color(0xFF1B2E50);

  // Text
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF4A5A7A);
  static const Color textMutedLight = Color(0xFF7080A0);
  static const Color textPrimaryDark = Color(0xFFF0F5FF);
  static const Color textSecondaryDark = Color(0xFFABC0DC);
  static const Color textMutedDark = Color(0xFF7890B0);

  // Semantic
  static const Color success = Color(0xFF1E9E57);
  static const Color warning = Color(0xFFE3A028);
  static const Color error = Color(0xFFD64545);
  static const Color info = Color(0xFF4FC3F7);

  // Legacy aliases (temporary compatibility)
  static const Color primary = brandPrimary;
  static const Color secondary = brandSecondary;
  static const Color accent = brandAccent;
}
