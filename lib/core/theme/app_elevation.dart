import 'package:flutter/material.dart';
import 'package:werdi/core/theme/app_radius.dart';
import 'package:werdi/core/theme/app_shadows.dart';

final class AppElevation {
  const AppElevation._();

  static BoxDecoration card(BuildContext context, {Color? color}) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: color ?? theme.colorScheme.surface,
      borderRadius: AppRadius.card,
      boxShadow: AppShadows.byBrightness(theme.brightness),
    );
  }
}
