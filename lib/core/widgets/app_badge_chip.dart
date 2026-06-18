import 'package:flutter/material.dart';
import 'package:werdi/core/theme/app_radius.dart';
import 'package:werdi/core/widgets/app_text.dart';

class AppBadgeChip extends StatelessWidget {
  const AppBadgeChip({required this.label, super.key, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.primaryContainer,
        borderRadius: AppRadius.chip,
      ),
      child: AppText(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
