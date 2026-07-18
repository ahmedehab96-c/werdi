import 'package:flutter/material.dart';
import 'package:werdi/core/responsive/responsive_helper.dart';

export 'responsive_helper.dart';
export 'responsive_utils.dart';

/// Density / content buckets aligned with [ResponsiveHelper] breakpoints.
enum ScreenSize { compact, medium, expanded, wide }

/// Layout helpers for content density (ayah scale, column counts, etc.).
abstract final class Responsive {
  static double widthOf(BuildContext context) =>
      ResponsiveHelper.screenWidth(context);

  static double heightOf(BuildContext context) =>
      ResponsiveHelper.screenHeight(context);

  static ScreenSize sizeOf(BuildContext context) {
    final width = widthOf(context);
    if (width < 360) return ScreenSize.compact;
    if (width < ResponsiveHelper.mobileBreakpoint) return ScreenSize.medium;
    if (width < ResponsiveHelper.desktopBreakpoint) return ScreenSize.expanded;
    return ScreenSize.wide;
  }

  static bool isCompact(BuildContext context) =>
      sizeOf(context) == ScreenSize.compact;

  static bool isWide(BuildContext context) =>
      sizeOf(context) == ScreenSize.wide;

  static double contentMaxWidth(BuildContext context) =>
      ResponsiveHelper.contentMaxWidth(context);

  static double horizontalPadding(BuildContext context) =>
      ResponsiveHelper.adaptivePadding(context);

  static double ayahFontScale(BuildContext context) {
    final width = widthOf(context);
    if (width < 320) return 0.82;
    if (width < 360) return 0.9;
    if (width > 430 && width < ResponsiveHelper.mobileBreakpoint) return 1.06;
    if (ResponsiveHelper.isTablet(context)) return 1.12;
    if (ResponsiveHelper.isDesktop(context)) return 1.18;
    return 1.0;
  }

  static double logoWatermarkSize(BuildContext context) {
    return switch (ResponsiveHelper.deviceTypeOf(context)) {
      DeviceType.mobile => isCompact(context) ? 140.0 : 180.0,
      DeviceType.tablet => 220.0,
      DeviceType.desktop => 260.0,
    };
  }

  static int gridColumns(
    BuildContext context, {
    int compact = 2,
    int medium = 2,
    int expanded = 3,
    int wide = 5,
  }) {
    return switch (sizeOf(context)) {
      ScreenSize.compact => compact,
      ScreenSize.medium => medium,
      ScreenSize.expanded => expanded,
      ScreenSize.wide => wide,
    };
  }

  static T valueFor<T>(
    BuildContext context, {
    required T compact,
    required T medium,
    T? expanded,
    T? wide,
  }) {
    return switch (sizeOf(context)) {
      ScreenSize.compact => compact,
      ScreenSize.medium => medium,
      ScreenSize.expanded => expanded ?? medium,
      ScreenSize.wide => wide ?? expanded ?? medium,
    };
  }
}
