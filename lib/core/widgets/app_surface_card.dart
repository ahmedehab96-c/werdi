import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:werdi/core/responsive/responsive_utils.dart';
import 'package:werdi/core/theme/app_durations.dart';

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    required this.child,
    super.key,
    this.padding,
    this.color,
    this.enableEntrance = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final bool enableEntrance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = ResponsiveUtils.responsiveRadius(context, 16);
    final borderRadius = BorderRadius.circular(radius);
    final surfaceColor = color ?? theme.colorScheme.surface;
    final content = Padding(
      padding: padding ?? ResponsiveUtils.cardPadding(context),
      child: child,
    );

    // Material is the painted surface (no DecoratedBox fill) so nested
    // ListTiles can draw ink splash on the correct ancestor.
    final card = Material(
      color: surfaceColor,
      elevation: theme.brightness == Brightness.dark ? 2.5 : 1.25,
      shadowColor: theme.brightness == Brightness.dark
          ? const Color(0x4D000000)
          : const Color(0x14081510),
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              child: content,
            ),
    );

    if (!enableEntrance) return card;

    return card
        .animate()
        .fadeIn(duration: AppDurations.fast, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.98, 0.98),
          end: const Offset(1, 1),
          duration: AppDurations.fast,
          curve: Curves.easeOutCubic,
        );
  }
}
