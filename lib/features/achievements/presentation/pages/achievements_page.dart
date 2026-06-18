import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_animated_progress.dart';
import 'package:werdi/core/widgets/app_badge_chip.dart';
import 'package:werdi/core/widgets/app_empty_state.dart';
import 'package:werdi/core/widgets/app_error_state.dart';
import 'package:werdi/core/widgets/app_loading_state.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_section_header.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/achievements/domain/models/achievement_item.dart';
import 'package:werdi/features/achievements/presentation/cubit/achievements_cubit.dart';
import 'package:werdi/features/achievements/presentation/cubit/achievements_state.dart';
import 'package:werdi/core/extensions/context_extensions.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AchievementsCubit(
        repository: AppInjector.achievementsRepository,
      )..load(),
      child: const _AchievementsView(),
    );
  }
}

class _AchievementsView extends StatelessWidget {
  const _AchievementsView();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text(context.l10n.achievementsTitle)),
      body: BlocBuilder<AchievementsCubit, AchievementsState>(
        builder: (context, state) {
          if (state.status == AchievementsStatus.loading) {
            return AppLoadingState(message: context.l10n.loadingAchievements);
          }

          if (state.status == AchievementsStatus.error) {
            return AppErrorState(
              message: state.errorMessage,
              onRetry: () => context.read<AchievementsCubit>().load(),
            );
          }

          return ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              _ProgressCard(earned: state.earned),
              SizedBox(height: AppSpacing.md),
              if (state.earned.isNotEmpty) ...[
                AppSectionHeader(title: context.l10n.earnedBadges),
                SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: state.earned
                      .map((a) => AppBadgeChip(label: a.title))
                      .toList(),
                ),
                SizedBox(height: AppSpacing.md),
              ],
              if (state.upcoming.isNotEmpty) ...[
                AppSectionHeader(title: context.l10n.upcomingGoals),
                SizedBox(height: AppSpacing.xs),
                ...state.upcoming.map((a) => _UpcomingTile(item: a)),
              ],
              if (state.earned.isEmpty && state.upcoming.isEmpty)
                AppEmptyState(
                  title: context.l10n.noAchievements,
                  subtitle: context.l10n.noAchievementsSubtitle,
                  icon: Icons.emoji_events_outlined,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.earned});
  final List<AchievementItem> earned;

  @override
  Widget build(BuildContext context) {
    const total = 6;
    final count = earned.length.clamp(0, total);
    final progress = total > 0 ? count / total : 0.0;

    final l10n = context.l10n;
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(title: l10n.overallProgressLabel),
          SizedBox(height: AppSpacing.sm),
          AppText(l10n.badgesProgress(count, total)),
          SizedBox(height: AppSpacing.xs),
          AppAnimatedProgress(value: progress),
          SizedBox(height: AppSpacing.xs),
          AppText(
            count >= total ? l10n.allBadgesEarned : l10n.remainingBadges(total - count),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _UpcomingTile extends StatelessWidget {
  const _UpcomingTile({required this.item});
  final AchievementItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: AppSurfaceCard(
        child: Row(
          children: [
            const Icon(Icons.emoji_events_outlined, size: 28),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppText(
                item.title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const Icon(Icons.lock_outline_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
