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
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final bool enableEntrance;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? EdgeInsets.all(AppSpacing.md),
      decoration: AppElevation.card(context, color: color),
      child: child,
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
