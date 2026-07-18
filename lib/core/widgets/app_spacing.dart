import 'package:flutter/widgets.dart';
import 'package:werdi/core/responsive/responsive_utils.dart';

final class AppVSpace {
  const AppVSpace._();

  static Widget of(double value) => SizedBox(height: value);

  static Widget responsive(BuildContext context, double value) =>
      SizedBox(height: ResponsiveUtils.responsiveSpacing(context, value));
}

final class AppHSpace {
  const AppHSpace._();

  static Widget of(double value) => SizedBox(width: value);

  static Widget responsive(BuildContext context, double value) =>
      SizedBox(width: ResponsiveUtils.responsiveSpacing(context, value));
}
