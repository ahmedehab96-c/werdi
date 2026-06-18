import 'package:flutter/material.dart';
import 'package:werdi/core/theme/app_radius.dart';
import 'package:werdi/core/widgets/app_text.dart';

class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    required this.label,
    required this.foreground,
    super.key,
    this.background,
  });

  final String label;
  final Color foreground;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background ?? foreground.withValues(alpha: 0.12),
        borderRadius: AppRadius.chip,
      ),
      child: AppText(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
