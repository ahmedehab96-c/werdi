import 'package:flutter/material.dart';
import 'package:werdi/core/constants/app_assets.dart';
import 'package:werdi/core/responsive/responsive.dart';
import 'package:werdi/core/theme/app_colors.dart';

/// Soft gradient with a watermark logo integrated into the screen.
class AppBrandedBackground extends StatelessWidget {
  const AppBrandedBackground({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final logoSize = Responsive.logoWatermarkSize(context);
    final logoLarge = logoSize * 1.35;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark
                  ? [
                      AppColors.darkBackground,
                      AppColors.darkSurfaceSubtle,
                      AppColors.brandAccentContainer.withValues(alpha: 0.55),
                    ]
                  : [
                      AppColors.lightBackground,
                      AppColors.brandPrimaryContainer.withValues(alpha: 0.45),
                      AppColors.lightSurfaceSubtle,
                    ],
            ),
          ),
        ),
        Positioned(
          top: -16,
          left: isRtl ? null : -28,
          right: isRtl ? -28 : null,
          child: Opacity(
            opacity: isDark ? 0.07 : 0.1,
            child: Image.asset(
              AppAssets.logo,
              width: logoSize,
              height: logoSize,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          bottom: -36,
          left: isRtl ? -40 : null,
          right: isRtl ? null : -40,
          child: Opacity(
            opacity: isDark ? 0.05 : 0.07,
            child: Image.asset(
              AppAssets.logo,
              width: logoLarge,
              height: logoLarge,
              fit: BoxFit.contain,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
