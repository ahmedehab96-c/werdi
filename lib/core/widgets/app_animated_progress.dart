import 'package:flutter/material.dart';
import 'package:werdi/core/theme/app_durations.dart';

class AppAnimatedProgress extends StatelessWidget {
  const AppAnimatedProgress({
    required this.value,
    super.key,
    this.minHeight = 6,
    this.backgroundColor,
    this.borderRadius = 24,
  });

  final double value;
  final double minHeight;
  final Color? backgroundColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: safeValue),
      duration: AppDurations.normal,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: LinearProgressIndicator(
            value: animatedValue,
            minHeight: minHeight,
            backgroundColor: backgroundColor,
          ),
        );
      },
    );
  }
}
