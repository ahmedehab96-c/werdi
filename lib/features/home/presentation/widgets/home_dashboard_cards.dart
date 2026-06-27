import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_badge_chip.dart';
import 'package:werdi/core/widgets/app_animated_progress.dart';
import 'package:werdi/core/widgets/app_button.dart';
import 'package:werdi/core/widgets/app_metric_tile.dart';
import 'package:werdi/core/widgets/app_icon_container.dart';
import 'package:werdi/core/widgets/app_status_chip.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/home/presentation/cubit/home_state.dart';
import 'package:werdi/routes/app_routes.dart';

class _HomeCardHeader extends StatelessWidget {
  const _HomeCardHeader({
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIconContainer(icon: icon, size: 44.w),
        SizedBox(width: 10.w),
        Expanded(
          child: AppText(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({required this.state, super.key});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSurfaceCard(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeCardHeader(icon: Icons.flag_rounded, title: l10n.dailyGoal),
          SizedBox(height: 10.h),
          AppText(
            l10n.dailyGoalDescription(
              state.dailyTargetAyahs,
              state.currentSurahName,
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: 14.h),
          Column(
            children: [
              AppAnimatedProgress(
                value: state.dailyProgress,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.45),
                borderRadius: 40,
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    '${(state.dailyProgress * 100).round()}%',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  AppText(
                    l10n.ayahsFraction(
                      state.dailyCompletedAyahs,
                      state.dailyTargetAyahs,
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          AppButton(
            label: l10n.continueMemorizing,
            onPressed: () => context.pushNamed(AppRoutes.memorization),
          ),
        ],
      ),
    );
  }
}

class ProgressOverviewCard extends StatelessWidget {
  const ProgressOverviewCard({required this.state, super.key});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeCardHeader(
            icon: Icons.insights_rounded,
            title: l10n.progressOverview,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: AppMetricTile(
                  title: l10n.total,
                  value: '${(state.totalMemorizationProgress * 100).round()}%',
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: AppMetricTile(
                  title: l10n.currentSurah,
                  value: '${(state.currentSurahProgress * 100).round()}%',
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: AppMetricTile(
                  title: l10n.thisWeek,
                  value: l10n.ayahUnit(state.weeklyMemorizedAyahs),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _WeeklyBars(values: state.weeklyProgress),
        ],
      ),
    );
  }
}

class LastMemorizedSurahCard extends StatelessWidget {
  const LastMemorizedSurahCard({required this.state, super.key});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeCardHeader(
            icon: Icons.play_circle_outline_rounded,
            title: l10n.continueJourney,
          ),
          SizedBox(height: 10.h),
          AppText(state.lastMemorizedContext),
          SizedBox(height: 4.h),
          AppText(
            l10n.lastReview(state.lastReviewContext),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: 10.h),
          AppButton(
            label: l10n.resumeFromLastPosition,
            onPressed: () => context.pushNamed(AppRoutes.memorization),
          ),
        ],
      ),
    );
  }
}

class ReviewReminderCard extends StatelessWidget {
  const ReviewReminderCard({required this.state, super.key});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSurfaceCard(
      color: Theme.of(
        context,
      ).colorScheme.secondaryContainer.withValues(alpha: 0.55),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeCardHeader(
            icon: Icons.notifications_active_rounded,
            title: l10n.reviewReminder,
            trailing: state.hasOverdueReviews
                ? AppStatusChip(
                    label: l10n.overdueShort(state.overdueReviewCount),
                    foreground: Theme.of(context).colorScheme.error,
                  )
                : null,
          ),
          SizedBox(height: 8.h),
          AppText(l10n.reviewDueToday(state.reviewDueCount)),
          SizedBox(height: 12.h),
          AppButton(
            label: l10n.startReview,
            onPressed: () => context.pushNamed(AppRoutes.review),
          ),
        ],
      ),
    );
  }
}

class DailyMotivationCard extends StatelessWidget {
  const DailyMotivationCard({required this.state, super.key});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSurfaceCard(
      color: Theme.of(
        context,
      ).colorScheme.tertiaryContainer.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeCardHeader(
            icon: Icons.auto_awesome_rounded,
            title: l10n.dailyMotivation,
          ),
          SizedBox(height: 10.h),
          AppText(
            '“${state.dailyQuote}”',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          SizedBox(height: 6.h),
          AppText(l10n.motivationFooter),
        ],
      ),
    );
  }
}

class StreakCard extends StatelessWidget {
  const StreakCard({required this.state, super.key});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSurfaceCard(
      onTap: () => context.pushNamed(AppRoutes.achievements),
      child: Row(
        children: [
          AppIconContainer(
            icon: Icons.local_fire_department_rounded,
            size: 52.w,
            background: Colors.orange.withValues(alpha: 0.15),
            foreground: Colors.orange,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.streakTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(height: 4.h),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: AppText(
                    state.streakDays > 0
                        ? l10n.streakConsecutiveDays(state.streakDays)
                        : l10n.startStreakHint,
                    key: ValueKey(state.streakDays),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                SizedBox(height: 4.h),
                AppText(
                  l10n.streakPurposeHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.chevron_left_rounded
                : Icons.chevron_right_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class AchievementsPreviewCard extends StatelessWidget {
  const AchievementsPreviewCard({required this.state, super.key});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSurfaceCard(
      onTap: () => context.pushNamed(AppRoutes.achievements),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeCardHeader(
            icon: Icons.emoji_events_rounded,
            title: l10n.achievementsPreview,
            trailing: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 10.h),
          if (state.badges.isEmpty)
            AppText(
              l10n.noAchievementsSubtitle,
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: state.badges
                  .map((badge) => AppBadgeChip(label: badge))
                  .toList(),
            ),
          SizedBox(height: 12.h),
          AppAnimatedProgress(value: state.milestoneProgress),
          SizedBox(height: 6.h),
          AppText(
            l10n.milestoneProgress(
              state.currentMilestoneAyahs,
              state.nextMilestoneAyahs,
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (state.nextBadgeTitle.isNotEmpty) ...[
            SizedBox(height: 6.h),
            AppText(
              l10n.nextBadgeHint(state.nextBadgeTitle),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class WeeklyInsightsCard extends StatelessWidget {
  const WeeklyInsightsCard({required this.state, super.key});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeCardHeader(
            icon: Icons.calendar_view_week_rounded,
            title: l10n.weeklyInsights,
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: AppMetricTile(
                  title: l10n.reviewAction,
                  value: l10n.ayahUnit(state.weeklyReviewedAyahs),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: AppMetricTile(
                  title: l10n.memorizeLabel,
                  value: l10n.ayahUnit(state.weeklyMemorizedAyahs),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: AppMetricTile(
                  title: l10n.sessionsLabel,
                  value: '${state.weeklySessions}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecommendedPlanCard extends StatelessWidget {
  const RecommendedPlanCard({required this.state, super.key});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSurfaceCard(
      onTap: () => _openRecommendedPlan(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconContainer(
            icon: Icons.lightbulb_rounded,
            size: 48.w,
            background: Theme.of(context).colorScheme.tertiaryContainer,
            foreground: Theme.of(context).colorScheme.tertiary,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.suggestedPlanToday,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 6.h),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: AppText(
                    state.recommendedNextStep,
                    key: ValueKey(state.recommendedNextStep),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.chevron_left_rounded
                : Icons.chevron_right_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  void _openRecommendedPlan(BuildContext context) {
    switch (state.recommendedPlanAction) {
      case HomePlanAction.review:
        context.pushNamed(AppRoutes.review);
      case HomePlanAction.tasmee3:
        context.pushNamed(AppRoutes.tasmee3);
      case HomePlanAction.memorize:
        context.pushNamed(AppRoutes.memorization);
    }
  }
}

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 64.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values
            .map(
              (value) => Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  height: value.clamp(0.0, 1.0) * 58.h,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(
                      alpha: 0.12 + (value * 0.5),
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
