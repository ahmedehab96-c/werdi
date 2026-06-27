import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/constants/app_assets.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_animated_progress.dart';
import 'package:werdi/core/widgets/app_badge_chip.dart';
import 'package:werdi/core/widgets/app_error_state.dart';
import 'package:werdi/core/widgets/app_loading_state.dart';
import 'package:werdi/core/widgets/app_metric_tile.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:werdi/features/profile/presentation/cubit/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(
        progressRepository: AppInjector.userProgressGateway,
        achievementsRepository: AppInjector.achievementsRepository,
        tasmee3Repository: AppInjector.tasmee3Gateway,
      )..load(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text(context.l10n.profileTitle)),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return AppLoadingState(message: context.l10n.loading);
          }
          if (state.status == ProfileStatus.error) {
            return AppErrorState(
              message: state.errorMessage,
              onRetry: () => context.read<ProfileCubit>().load(),
            );
          }

          final progress = state.progress!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _ProfileHeaderCard(),
                SizedBox(height: AppSpacing.md),
                _StatsCard(progress: progress),
                SizedBox(height: AppSpacing.md),
                _AchievementsCard(badges: state.earnedBadgeLabels),
                SizedBox(height: AppSpacing.md),
                _GoalsCard(progress: progress),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard();

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              AppAssets.logo,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  context.l10n.appName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                AppText(
                  context.l10n.profileLocalSubtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.progress});

  final dynamic progress;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(context.l10n.overallProgress, style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final l10n = context.l10n;
              if (constraints.maxWidth < 420) {
                return Column(
                  children: [
                    AppMetricTile(
                      title: l10n.memorizedAyahsCount,
                      value: '${progress.memorizedAyahCount}',
                    ),
                    const SizedBox(height: 8),
                    AppMetricTile(
                      title: l10n.reviewSessionsCount,
                      value: '${progress.reviewedItemsCount}',
                    ),
                    const SizedBox(height: 8),
                    AppMetricTile(
                      title: l10n.streakLabel,
                      value: '${progress.streakDays}',
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: AppMetricTile(
                      title: l10n.memorizedAyahsCount,
                      value: '${progress.memorizedAyahCount}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppMetricTile(
                      title: l10n.reviewSessionsCount,
                      value: '${progress.reviewedItemsCount}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppMetricTile(
                      title: l10n.streakLabel,
                      value: '${progress.streakDays}',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AchievementsCard extends StatelessWidget {
  const _AchievementsCard({required this.badges});

  final List<String> badges;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(context.l10n.yourBadges, style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: AppSpacing.xs),
          if (badges.isEmpty)
            AppText(
              context.l10n.noBadges,
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: badges
                  .map((label) => AppBadgeChip(label: label))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _GoalsCard extends StatelessWidget {
  const _GoalsCard({required this.progress});

  final dynamic progress;

  @override
  Widget build(BuildContext context) {
    final memorized = progress.memorizedAyahCount as int;
    const goalAyahs = 300;
    final memProgress = (memorized / goalAyahs).clamp(0.0, 1.0);

    final reviewed = progress.reviewedItemsCount as int;
    const goalReviews = 15;
    final reviewProgress = (reviewed / goalReviews).clamp(0.0, 1.0);
    final l10n = context.l10n;

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.currentGoals,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: AppSpacing.sm),
          _GoalRow(
            text: l10n.memorizeGoal(goalAyahs),
            progress: memProgress,
            subtitle: memorized >= goalAyahs
                ? l10n.goalDone
                : l10n.ayahsRemaining(goalAyahs - memorized),
          ),
          SizedBox(height: AppSpacing.xs),
          _GoalRow(
            text: l10n.reviewSessionsGoal(goalReviews),
            progress: reviewProgress,
            subtitle: reviewed >= goalReviews
                ? l10n.goalDone
                : l10n.remainingSessions(goalReviews - reviewed),
          ),
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.text,
    required this.progress,
    required this.subtitle,
  });

  final String text;
  final double progress;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: AppText(text)),
            AppText(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xxs),
        AppAnimatedProgress(value: progress, minHeight: 7, borderRadius: 20),
      ],
    );
  }
}
