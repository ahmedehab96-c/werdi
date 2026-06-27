import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:werdi/core/theme/app_durations.dart';

/// Reusable motion presets for Werdi UI.
extension WerdiMotion on Widget {
  Widget fadeInQuick() =>
      animate().fadeIn(duration: AppDurations.fast, curve: Curves.easeOut);

  Widget fadeInSmooth() => animate().fadeIn(
        duration: AppDurations.normal,
        curve: Curves.easeOutCubic,
      );

  /// Staggered list / section entrance (index 0, 1, 2…).
  Widget entranceStagger(
    int index, {
    int stepMs = 70,
    double slideY = 0.07,
  }) =>
      animate(delay: (stepMs * index).ms)
          .fadeIn(duration: AppDurations.normal, curve: Curves.easeOutCubic)
          .slideY(
            begin: slideY,
            end: 0,
            duration: AppDurations.normal,
            curve: Curves.easeOutCubic,
          )
          .scale(
            begin: const Offset(0.96, 0.96),
            end: const Offset(1, 1),
            duration: AppDurations.normal,
            curve: Curves.easeOutCubic,
          );

  Widget slideUpEntrance({Duration delay = Duration.zero}) => animate(
        delay: delay,
      )
          .fadeIn(duration: AppDurations.normal, curve: Curves.easeOutCubic)
          .slideY(
            begin: 0.12,
            end: 0,
            duration: AppDurations.slow,
            curve: Curves.easeOutCubic,
          );

  Widget popIn({Duration delay = Duration.zero}) => animate(delay: delay)
      .fadeIn(duration: AppDurations.normal, curve: Curves.easeOutBack)
      .scale(
        begin: const Offset(0.88, 0.88),
        end: const Offset(1, 1),
        duration: AppDurations.slow,
        curve: Curves.easeOutBack,
      );

  /// Gentle floating loop for logos and hero icons.
  Widget floatLoop({Duration duration = const Duration(milliseconds: 2200)}) =>
      animate(onPlay: (controller) => controller.repeat(reverse: true))
          .moveY(
            begin: -6,
            end: 6,
            duration: duration,
            curve: Curves.easeInOut,
          );

  /// Shimmer highlight sweep (subtle, one-shot).
  Widget shimmerOnce({Duration delay = Duration.zero}) => animate(
        delay: delay,
      ).shimmer(
        duration: AppDurations.slow,
        color: Colors.white.withValues(alpha: 0.35),
      );

  Widget tapFeedback({double pressedScale = 0.96}) =>
      _TapFeedback(scale: pressedScale, child: this);
}

class _TapFeedback extends StatefulWidget {
  const _TapFeedback({required this.child, required this.scale});

  final Widget child;
  final double scale;

  @override
  State<_TapFeedback> createState() => _TapFeedbackState();
}

class _TapFeedbackState extends State<_TapFeedback> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: AppDurations.instant,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
