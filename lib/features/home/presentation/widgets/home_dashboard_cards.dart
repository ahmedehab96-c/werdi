import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/responsive/responsive_utils.dart';
import 'package:werdi/core/widgets/app_animated_progress.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/home/presentation/cubit/home_state.dart';
import 'package:werdi/routes/app_routes.dart';

/// Soft, professional daily goal — no loud gradient, minimal chrome.
class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({
    required this.state,
    this.onTap,
    super.key,
  });

  final HomeState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final progress = (state.dailyProgress * 100).round();
    final radius = ResponsiveUtils.responsiveRadius(context, 18);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: scheme.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Padding(
            padding: ResponsiveUtils.cardPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        l10n.dailyGoal,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: scheme.onPrimaryContainer,
                            ),
                      ),
                    ),
                    AppText(
                      '$progress%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.primary,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 8)),
                AppText(
                  l10n.dailyGoalDescription(
                    state.dailyTargetAyahs,
                    state.currentSurahName,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onPrimaryContainer.withValues(alpha: 0.85),
                      ),
                ),
                SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 14)),
                AppAnimatedProgress(
                  value: state.dailyProgress,
                  minHeight: 6,
                  backgroundColor: scheme.primary.withValues(alpha: 0.12),
                ),
                SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 8)),
                AppText(
                  l10n.ayahsFraction(
                    state.dailyCompletedAyahs,
                    state.dailyTargetAyahs,
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
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

/// Three clean stats — no heavy headers or chart chrome.
class ProgressOverviewCard extends StatelessWidget {
  const ProgressOverviewCard({required this.state, super.key});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gap = ResponsiveUtils.responsiveSpacing(context, 8);

    return AppSurfaceCard(
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              value: '${(state.totalMemorizationProgress * 100).round()}%',
              label: l10n.total,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _Stat(
              value: '${(state.currentSurahProgress * 100).round()}%',
              label: l10n.currentSurah,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _Stat(
              value: '${state.weeklyMemorizedAyahs}',
              label: l10n.thisWeek,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        AppText(
          value,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 4)),
        AppText(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

/// Single compact streak line — opens achievements.
class StreakCard extends StatelessWidget {
  const StreakCard({required this.state, super.key});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final label = state.streakDays > 0
        ? l10n.streakConsecutiveDays(state.streakDays)
        : l10n.startStreakHint;

    return AppSurfaceCard(
      onTap: () => context.pushNamed(AppRoutes.achievements),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: Colors.orange.shade700,
            size: ResponsiveUtils.responsiveIconSize(context, 24),
          ),
          SizedBox(width: ResponsiveUtils.responsiveSpacing(context, 10)),
          Expanded(
            child: AppText(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.chevron_left_rounded
                : Icons.chevron_right_rounded,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
