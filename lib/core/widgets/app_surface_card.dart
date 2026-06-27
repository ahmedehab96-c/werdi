import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:werdi/core/theme/app_durations.dart';
import 'package:werdi/core/theme/app_elevation.dart';
import 'package:werdi/core/theme/app_spacing.dart';

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
    final card = Container(
      padding: padding ?? EdgeInsets.all(AppSpacing.md),
      decoration: AppElevation.card(context, color: color),
      child: child,
    );

    final interactive = onTap == null
        ? card
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: card,
            ),
          );

    if (!enableEntrance) return interactive;

    return interactive
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
