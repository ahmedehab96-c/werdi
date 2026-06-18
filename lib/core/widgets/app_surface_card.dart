import 'package:flutter/material.dart';
import 'package:werdi/core/theme/app_durations.dart';
import 'package:werdi/core/theme/app_elevation.dart';
import 'package:werdi/core/theme/app_spacing.dart';

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    required this.child,
    super.key,
    this.padding,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.98, end: 1),
      duration: AppDurations.fast,
      curve: Curves.easeOut,
      builder: (context, scale, _) {
        return Opacity(
          opacity: scale,
          child: Transform.scale(
            scale: scale,
            child: Container(
              padding: padding ?? EdgeInsets.all(AppSpacing.md),
              decoration: AppElevation.card(context, color: color),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
