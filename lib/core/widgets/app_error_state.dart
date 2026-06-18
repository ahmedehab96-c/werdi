import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';

/// Consistent error placeholder with an optional retry action.
///
/// Mirrors [AppSurfaceCard]-based states (empty/loading) so all non-content
/// states share the same visual language across the app.
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
      child: SizedBox(
        width: 360.w,
        child: AppSurfaceCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 40.sp,
                color: Theme.of(context).colorScheme.error,
              ),
              SizedBox(height: 10.h),
              if (title != null) ...[
                AppText(title!, style: Theme.of(context).textTheme.titleSmall),
                SizedBox(height: 4.h),
              ],
              AppText(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (onRetry != null) ...[
                SizedBox(height: 12.h),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(retryLabel ?? context.l10n.retry),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
