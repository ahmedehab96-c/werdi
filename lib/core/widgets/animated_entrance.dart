import 'package:flutter/material.dart';
import 'package:werdi/core/animations/app_animations.dart';

/// Wraps a child with staggered entrance motion.
class AnimatedEntrance extends StatelessWidget {
  const AnimatedEntrance({
    required this.index,
    required this.child,
    super.key,
    this.stepMs = 70,
  });

  final int index;
  final Widget child;
  final int stepMs;

  @override
  Widget build(BuildContext context) {
    return child.entranceStagger(index, stepMs: stepMs);
  }
}
