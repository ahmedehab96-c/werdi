import 'package:flutter/material.dart';
import 'package:werdi/core/responsive/responsive_utils.dart';
import 'package:werdi/core/widgets/app_text.dart';

/// Compact stat tile — height adapts to label length.
class AppMetricTile extends StatelessWidget {
  const AppMetricTile({required this.title, required this.value, super.key});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.responsivePadding(context, 6),
        vertical: ResponsiveUtils.responsivePadding(context, 10),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.responsiveRadius(context, 12),
        ),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 4)),
          AppText(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
