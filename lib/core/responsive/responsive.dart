import 'package:flutter/material.dart';

/// Screen-size buckets for adaptive layouts (phones small → large, tablets).
enum ScreenSize { compact, medium, expanded, wide }

abstract final class Responsive {
  static double widthOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double heightOf(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static ScreenSize sizeOf(BuildContext context) {
    final width = widthOf(context);
    if (width < 360) return ScreenSize.compact;
    if (width < 600) return ScreenSize.medium;
    if (width < 900) return ScreenSize.expanded;
    return ScreenSize.wide;
  }

  static bool isCompact(BuildContext context) =>
      sizeOf(context) == ScreenSize.compact;

  static bool isWide(BuildContext context) =>
      sizeOf(context) == ScreenSize.wide;

  static double horizontalPadding(BuildContext context) {
    return switch (sizeOf(context)) {
      ScreenSize.compact => 12,
      ScreenSize.medium => 16,
      ScreenSize.expanded => 20,
      ScreenSize.wide => 24,
    };
  }

  static double contentMaxWidth(BuildContext context) {
    final width = widthOf(context);
    if (width >= 900) return 840;
    if (width >= 600) return 560;
    return width;
  }

  static double ayahFontScale(BuildContext context) {
    final width = widthOf(context);
    if (width < 320) return 0.82;
    if (width < 360) return 0.9;
    if (width > 430) return 1.06;
    return 1.0;
  }

  static double logoWatermarkSize(BuildContext context) {
    return switch (sizeOf(context)) {
      ScreenSize.compact => 140,
      ScreenSize.medium => 180,
      ScreenSize.expanded => 220,
      ScreenSize.wide => 260,
    };
  }

  static int gridColumns(
    BuildContext context, {
    int compact = 2,
    int medium = 2,
    int expanded = 3,
    int wide = 4,
  }) {
    return switch (sizeOf(context)) {
      ScreenSize.compact => compact,
      ScreenSize.medium => medium,
      ScreenSize.expanded => expanded,
      ScreenSize.wide => wide,
    };
  }

  static double valueFor(
    BuildContext context, {
    required double compact,
    required double medium,
    double? expanded,
    double? wide,
  }) {
    return switch (sizeOf(context)) {
      ScreenSize.compact => compact,
      ScreenSize.medium => medium,
      ScreenSize.expanded => expanded ?? medium,
      ScreenSize.wide => wide ?? expanded ?? medium,
    };
  }
}
