import 'package:flutter/material.dart';
import 'package:werdi/core/responsive/responsive_helper.dart';

export 'responsive_helper.dart';

/// Backward-compatible alias around [ResponsiveHelper].
abstract final class ResponsiveUtils {
  static const double minTouchTarget = ResponsiveHelper.minTouchTarget;

  static double screenWidth(BuildContext context) =>
      ResponsiveHelper.screenWidth(context);

  static double screenHeight(BuildContext context) =>
      ResponsiveHelper.screenHeight(context);

  static Orientation orientationOf(BuildContext context) =>
      ResponsiveHelper.orientationOf(context);

  static bool isLandscape(BuildContext context) =>
      ResponsiveHelper.isLandscape(context);

  static bool isSmallPhone(BuildContext context) =>
      ResponsiveHelper.isSmallPhone(context);

  static bool isNormalPhone(BuildContext context) {
    final width = screenWidth(context);
    return width >= 360 && width < 400;
  }

  static bool isLargePhone(BuildContext context) {
    final width = screenWidth(context);
    return width >= 400 && width < 600;
  }

  static bool isTablet(BuildContext context) =>
      ResponsiveHelper.isTablet(context);

  static bool isFoldable(BuildContext context) =>
      ResponsiveHelper.isFoldable(context);

  static double responsiveWidth(BuildContext context, double value) =>
      ResponsiveHelper.adaptiveWidth(context, value);

  static double responsiveHeight(BuildContext context, double value) =>
      ResponsiveHelper.adaptiveHeight(context, value);

  static double responsiveFont(BuildContext context, double size) =>
      ResponsiveHelper.adaptiveFont(context, size);

  static double font(BuildContext context, double size) =>
      responsiveFont(context, size);

  static double responsiveSpacing(BuildContext context, double value) =>
      ResponsiveHelper.adaptiveSpacing(context, value);

  static double responsivePadding(BuildContext context, double value) =>
      ResponsiveHelper.adaptivePadding(context, value);

  static double responsiveRadius(BuildContext context, double value) =>
      ResponsiveHelper.adaptiveRadius(context, value);

  static double responsiveIconSize(BuildContext context, double value) =>
      ResponsiveHelper.adaptiveIcon(context, value);

  static double minTouchTargetSize(BuildContext context) =>
      ResponsiveHelper.minTouchTargetSize(context);

  static EdgeInsets pagePadding(BuildContext context) =>
      ResponsiveHelper.pagePadding(context);

  static EdgeInsets cardPadding(BuildContext context) =>
      ResponsiveHelper.cardPadding(context);

  static EdgeInsets dialogInsetPadding(BuildContext context) =>
      ResponsiveHelper.dialogInsetPadding(context);

  static double dialogMaxWidth(BuildContext context) =>
      ResponsiveHelper.dialogMaxWidth(context);

  static double bottomSheetMaxWidth(BuildContext context) =>
      ResponsiveHelper.bottomSheetMaxWidth(context);

  static double contentMaxWidth(BuildContext context) =>
      ResponsiveHelper.contentMaxWidth(context);

  static double gridMaxCrossAxisExtent(BuildContext context) =>
      ResponsiveHelper.adaptiveGrid(context);

  static double gridChildAspectRatio(BuildContext context, {double base = 2}) =>
      ResponsiveHelper.gridChildAspectRatio(context, base: base);

  static Widget horizontalGap(BuildContext context, double value) =>
      ResponsiveHelper.horizontalGap(context, value);

  static Widget verticalGap(BuildContext context, double value) =>
      ResponsiveHelper.verticalGap(context, value);
}

/// Shorthand accessors on [BuildContext].
extension ResponsiveContextX on BuildContext {
  double get rw => ResponsiveHelper.screenWidth(this);
  double get rh => ResponsiveHelper.screenHeight(this);

  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);
  bool get isSmallPhone => ResponsiveHelper.isSmallPhone(this);

  DeviceType get deviceType => ResponsiveHelper.deviceTypeOf(this);
  NavChrome get navChrome => ResponsiveHelper.navChromeOf(this);

  double responsiveWidth(double value) =>
      ResponsiveHelper.adaptiveWidth(this, value);
  double responsiveHeight(double value) =>
      ResponsiveHelper.adaptiveHeight(this, value);
  double responsiveFont(double size) =>
      ResponsiveHelper.adaptiveFont(this, size);
  double responsiveSpacing(double value) =>
      ResponsiveHelper.adaptiveSpacing(this, value);
  double responsivePadding(double value) =>
      ResponsiveHelper.adaptivePadding(this, value);
  double responsiveRadius(double value) =>
      ResponsiveHelper.adaptiveRadius(this, value);

  double adaptiveWidth(double value) =>
      ResponsiveHelper.adaptiveWidth(this, value);
  double adaptiveHeight(double value) =>
      ResponsiveHelper.adaptiveHeight(this, value);
  double adaptiveFont(double size) => ResponsiveHelper.adaptiveFont(this, size);
  double adaptiveSpacing(double value) =>
      ResponsiveHelper.adaptiveSpacing(this, value);
  double adaptivePadding([double? base]) =>
      ResponsiveHelper.adaptivePadding(this, base);
  double adaptiveRadius(double value) =>
      ResponsiveHelper.adaptiveRadius(this, value);
}
