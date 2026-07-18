import 'package:flutter/material.dart';

/// Device form-factor for adaptive chrome (nav, grids, padding).
enum DeviceType { mobile, tablet, desktop }

/// Central responsive API used across Werdi.
///
/// Breakpoints:
/// - Mobile: width < 600
/// - Tablet: 600–1024
/// - Desktop: width > 1024
abstract final class ResponsiveHelper {
  static const double mobileBreakpoint = 600;
  static const double desktopBreakpoint = 1024;
  static const double minTouchTarget = 48;

  static const double _designWidth = 390;
  static const double _designHeight = 844;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static Orientation orientationOf(BuildContext context) =>
      MediaQuery.orientationOf(context);

  static bool isLandscape(BuildContext context) =>
      orientationOf(context) == Orientation.landscape;

  static DeviceType deviceTypeOf(BuildContext context) {
    final width = screenWidth(context);
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < desktopBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static bool isMobile(BuildContext context) =>
      deviceTypeOf(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      deviceTypeOf(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      deviceTypeOf(context) == DeviceType.desktop;

  static bool isSmallPhone(BuildContext context) => screenWidth(context) < 360;

  static bool isFoldable(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final ratio = size.width / size.height;
    return size.shortestSide >= 600 && ratio > 0.65 && ratio < 1.55;
  }

  /// Which primary navigation chrome to use.
  static NavChrome navChromeOf(BuildContext context) {
    final width = screenWidth(context);
    if (width >= desktopBreakpoint) return NavChrome.side;
    if (width >= mobileBreakpoint) return NavChrome.rail;
    return NavChrome.bottom;
  }

  static double _widthScale(BuildContext context) =>
      (screenWidth(context) / _designWidth).clamp(0.82, 1.45);

  static double _heightScale(BuildContext context) =>
      (screenHeight(context) / _designHeight).clamp(0.82, 1.45);

  static double _bucketScale(BuildContext context) =>
      switch (deviceTypeOf(context)) {
        DeviceType.mobile => isSmallPhone(context) ? 0.9 : 1.0,
        DeviceType.tablet => 1.08,
        DeviceType.desktop => 1.16,
      };

  static double adaptiveWidth(BuildContext context, double value) =>
      value * _widthScale(context) * _bucketScale(context);

  static double adaptiveHeight(BuildContext context, double value) =>
      value * _heightScale(context) * _bucketScale(context);

  static double adaptiveFont(BuildContext context, double size) {
    final scaled = size * _widthScale(context) * _bucketScale(context);
    return MediaQuery.textScalerOf(context).scale(scaled);
  }

  static double adaptiveSpacing(BuildContext context, double value) =>
      adaptiveWidth(context, value);

  static double adaptivePadding(BuildContext context, [double? base]) {
    if (base != null) return adaptiveSpacing(context, base);
    return switch (deviceTypeOf(context)) {
      DeviceType.mobile => isSmallPhone(context) ? 12.0 : 16.0,
      DeviceType.tablet => 20.0,
      DeviceType.desktop => 28.0,
    };
  }

  static double adaptiveRadius(BuildContext context, double value) =>
      adaptiveWidth(context, value).clamp(value * 0.85, value * 1.25);

  static double adaptiveIcon(BuildContext context, double value) =>
      adaptiveFont(context, value);

  static double minTouchTargetSize(BuildContext context) =>
      adaptiveHeight(context, minTouchTarget)
          .clamp(minTouchTarget, minTouchTarget * 1.2);

  static EdgeInsets pagePadding(BuildContext context) {
    final pad = adaptivePadding(context);
    return EdgeInsets.symmetric(horizontal: pad, vertical: pad);
  }

  static EdgeInsets cardPadding(BuildContext context) =>
      EdgeInsets.all(adaptivePadding(context, 16));

  static EdgeInsets dialogInsetPadding(BuildContext context) {
    final horizontal = switch (deviceTypeOf(context)) {
      DeviceType.mobile => adaptiveWidth(context, 16),
      DeviceType.tablet => adaptiveWidth(context, 48),
      DeviceType.desktop => adaptiveWidth(context, 96),
    };
    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: adaptiveHeight(context, 24),
    );
  }

  static double dialogMaxWidth(BuildContext context) =>
      switch (deviceTypeOf(context)) {
        DeviceType.mobile => screenWidth(context) * 0.92,
        DeviceType.tablet => 520,
        DeviceType.desktop => 640,
      };

  static double bottomSheetMaxWidth(BuildContext context) =>
      switch (deviceTypeOf(context)) {
        DeviceType.mobile => screenWidth(context),
        DeviceType.tablet => 640,
        DeviceType.desktop => 720,
      };

  static double contentMaxWidth(BuildContext context) {
    final width = screenWidth(context);
    if (width >= 1400) return 1200;
    if (width >= desktopBreakpoint) return 1040;
    if (width >= mobileBreakpoint) return 720;
    return width;
  }

  /// Cell extent for adaptive grids (phone 2 → tablet 3–4 → desktop 5–6).
  static double adaptiveGrid(BuildContext context) {
    return switch (deviceTypeOf(context)) {
      DeviceType.mobile => isSmallPhone(context) ? 160.0 : 180.0,
      DeviceType.tablet => isLandscape(context) ? 200.0 : 220.0,
      DeviceType.desktop => 240.0,
    };
  }

  static double gridChildAspectRatio(BuildContext context, {double base = 2}) {
    if (isDesktop(context)) return base * 1.2;
    if (isTablet(context) && isLandscape(context)) return base * 1.15;
    if (isSmallPhone(context)) return base * 0.92;
    return base;
  }

  static SliverGridDelegate adaptiveGridDelegate(
    BuildContext context, {
    double? maxCrossAxisExtent,
    double childAspectRatio = 2,
    double crossAxisSpacing = 12,
    double mainAxisSpacing = 12,
  }) {
    return SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: maxCrossAxisExtent ?? adaptiveGrid(context),
      childAspectRatio: gridChildAspectRatio(context, base: childAspectRatio),
      crossAxisSpacing: adaptiveSpacing(context, crossAxisSpacing),
      mainAxisSpacing: adaptiveSpacing(context, mainAxisSpacing),
    );
  }

  static Widget horizontalGap(BuildContext context, double value) =>
      SizedBox(width: adaptiveSpacing(context, value));

  static Widget verticalGap(BuildContext context, double value) =>
      SizedBox(height: adaptiveSpacing(context, value));
}

enum NavChrome { bottom, rail, side }
