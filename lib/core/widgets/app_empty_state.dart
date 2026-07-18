import 'package:flutter/material.dart';
import 'package:werdi/core/responsive/responsive_utils.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    required this.subtitle,
    super.key,
    this.icon = Icons.inbox_rounded,
    this.action,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: ResponsiveUtils.responsiveIconSize(context, 36),
          ),
          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 8)),
          AppText(title, style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 4)),
          AppText(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (action != null) ...[
            SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 10)),
            action!,
          ],
        ],
      ),
    );
  }
}
