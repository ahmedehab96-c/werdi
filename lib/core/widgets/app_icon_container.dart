import 'package:flutter/material.dart';
import 'package:werdi/core/responsive/responsive_utils.dart';
import 'package:werdi/core/theme/app_radius.dart';

class AppIconContainer extends StatelessWidget {
  const AppIconContainer({
    required this.icon,
    super.key,
    this.size,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final double? size;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolvedSize =
        size ?? ResponsiveUtils.responsiveWidth(context, 40);
    final iconSize = ResponsiveUtils.responsiveIconSize(context, 20);
    return Container(
      width: resolvedSize,
      height: resolvedSize,
      decoration: BoxDecoration(
        color: background ?? scheme.primaryContainer,
        borderRadius: AppRadius.iconContainer,
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: iconSize,
        color: foreground ?? scheme.primary,
      ),
    );
  }
}
