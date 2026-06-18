import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:werdi/core/theme/app_durations.dart';

extension FadeInAnimation on Widget {
  Widget fadeInQuick() => animate().fadeIn(duration: AppDurations.fast);
  Widget fadeInSmooth() => animate().fadeIn(duration: AppDurations.normal);
}
