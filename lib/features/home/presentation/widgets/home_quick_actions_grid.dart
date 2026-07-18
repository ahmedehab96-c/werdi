import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/responsive/responsive_utils.dart';
import 'package:werdi/core/theme/app_colors.dart';
import 'package:werdi/core/widgets/app_shell_scaffold.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/home/presentation/models/home_quick_action.dart';
import 'package:werdi/routes/app_routes.dart';

/// Compact 3-action row — title only, no subtitles.
class HomeQuickActionsGrid extends StatelessWidget {
  const HomeQuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actions = [
      (
        title: l10n.memorizeNow,
        icon: Icons.menu_book_rounded,
        color: AppColors.brandPrimary,
        type: HomeQuickActionType.memorize,
      ),
      (
        title: l10n.reviewAction,
        icon: Icons.history_edu_rounded,
        color: AppColors.brandSecondary,
        type: HomeQuickActionType.review,
      ),
      (
        title: l10n.openQuran,
        icon: Icons.auto_stories_rounded,
        color: AppColors.success,
        type: HomeQuickActionType.quran,
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          Expanded(
            child: _ActionTile(
              title: actions[i].title,
              icon: actions[i].icon,
              accent: actions[i].color,
              type: actions[i].type,
            ),
          ),
          if (i < actions.length - 1)
            SizedBox(width: ResponsiveUtils.responsiveSpacing(context, 8)),
        ],
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.icon,
    required this.accent,
    required this.type,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final HomeQuickActionType type;

  void _onTap(BuildContext context) {
    switch (type) {
      case HomeQuickActionType.memorize:
      case HomeQuickActionType.test:
        context.goToShellTab(AppRoutes.memorization);
      case HomeQuickActionType.review:
        context.pushNamed(AppRoutes.review);
      case HomeQuickActionType.quran:
        context.goToShellTab(AppRoutes.quran);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = ResponsiveUtils.responsiveRadius(context, 16);

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: () => _onTap(context),
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveUtils.responsiveSpacing(context, 14),
              horizontal: ResponsiveUtils.responsiveSpacing(context, 8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: accent, size: context.responsiveFont(26)),
                SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 8)),
                AppText(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
