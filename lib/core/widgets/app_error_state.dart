import 'package:flutter/material.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/responsive/responsive_utils.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';

/// Consistent error placeholder with an optional retry action.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.message,
    super.key,
    this.title,
    this.icon = Icons.error_outline_rounded,
    this.onRetry,
    this.retryLabel,
  });

  final String message;
  final String? title;
  final IconData icon;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveUtils.contentMaxWidth(context).clamp(0, 420),
        ),
        child: AppSurfaceCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: ResponsiveUtils.responsiveIconSize(context, 40),
                color: Theme.of(context).colorScheme.error,
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 10)),
              if (title != null) ...[
                AppText(title!, style: Theme.of(context).textTheme.titleSmall),
                SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 4)),
              ],
              AppText(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (onRetry != null) ...[
                SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 12)),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: ResponsiveUtils.minTouchTargetSize(context),
                  ),
                  child: FilledButton.icon(
                    onPressed: onRetry,
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: ResponsiveUtils.responsiveIconSize(context, 18),
                    ),
                    label: Text(retryLabel ?? context.l10n.retry),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
