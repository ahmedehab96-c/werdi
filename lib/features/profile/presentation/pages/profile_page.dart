import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/constants/app_assets.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/navigation/shell_tab_coordinator.dart';
import 'package:werdi/core/responsive/responsive_utils.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_animated_progress.dart';
import 'package:werdi/core/widgets/app_badge_chip.dart';
import 'package:werdi/core/widgets/app_error_state.dart';
import 'package:werdi/core/widgets/app_loading_state.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_shell_scaffold.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/core/widgets/responsive_dialog.dart';
import 'package:werdi/features/goals/domain/models/user_goals.dart';
import 'package:werdi/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:werdi/features/profile/presentation/cubit/profile_state.dart';
import 'package:werdi/routes/app_routes.dart';
import 'package:werdi/shared/repositories/user_progress_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ProfileCubit(
      progressRepository: AppInjector.userProgressGateway,
      achievementsRepository: AppInjector.achievementsRepository,
      tasmee3Repository: AppInjector.tasmee3Gateway,
      goalsRepository: AppInjector.userGoalsRepository,
      preferences: AppInjector.appPreferences,
    )..load();
    ShellTabCoordinator.onProfileTabSelected = () {
      if (mounted) _cubit.load();
    };
  }

  @override
  void dispose() {
    ShellTabCoordinator.onProfileTabSelected = null;
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
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

          return ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              _ProfileHeader(displayName: state.displayName),
              SizedBox(height: AppSpacing.md),
              _StatsRow(progress: progress),
              SizedBox(height: AppSpacing.md),
              _BadgesCard(badges: state.earnedBadgeLabels),
              SizedBox(height: AppSpacing.md),
              _GoalsCard(progress: progress, goals: state.goals),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = displayName.isNotEmpty ? displayName : l10n.appName;
    final size = ResponsiveUtils.responsiveWidth(context, 52).clamp(48.0, 64.0);

    return AppSurfaceCard(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.responsiveRadius(context, 14),
            ),
            child: Image.asset(
              AppAssets.logo,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          IconButton(
            tooltip: l10n.editName,
            onPressed: () => _editName(context),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }

  Future<void> _editName(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<ProfileCubit>();
    final controller = TextEditingController(text: displayName);

    final saved = await showResponsiveDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Padding(
          padding: ResponsiveUtils.cardPadding(dialogContext),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(
                l10n.editName,
                style: Theme.of(dialogContext).textTheme.titleLarge,
              ),
              SizedBox(
                height: ResponsiveUtils.responsiveSpacing(dialogContext, 16),
              ),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: l10n.nameHint,
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              SizedBox(
                height: ResponsiveUtils.responsiveSpacing(dialogContext, 16),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(l10n.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (saved == true) {
      await cubit.saveDisplayName(controller.text);
    }
    controller.dispose();
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.progress});

  final UserProgressSnapshot progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (l10n.memorizedAyahsCount, '${progress.memorizedAyahCount}'),
      (l10n.reviewSessionsCount, '${progress.reviewedItemsCount}'),
      (l10n.streakLabel, '${progress.streakDays}'),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _StatCell(label: items[i].$1, value: items[i].$2),
          ),
        ],
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppSurfaceCard(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.responsivePadding(context, 8),
        vertical: ResponsiveUtils.responsivePadding(context, 12),
      ),
      child: Column(
        children: [
          AppText(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 4)),
          AppText(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _BadgesCard extends StatelessWidget {
  const _BadgesCard({required this.badges});

  final List<String> badges;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            context.l10n.yourBadges,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: AppSpacing.sm),
          if (badges.isEmpty)
            AppText(
              context.l10n.noBadges,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: badges.map((label) => AppBadgeChip(label: label)).toList(),
            ),
        ],
      ),
    );
  }
}

class _GoalsCard extends StatelessWidget {
  const _GoalsCard({required this.progress, required this.goals});

  final UserProgressSnapshot progress;
  final UserGoals goals;

  @override
  Widget build(BuildContext context) {
    final memorized = progress.memorizedAyahCount;
    final goalAyahs = goals.memorizationGoalAyahs;
    final memProgress = (memorized / goalAyahs).clamp(0.0, 1.0);

    final reviewed = progress.reviewedItemsCount;
    final goalReviews = goals.reviewSessionsGoal;
    final reviewProgress = (reviewed / goalReviews).clamp(0.0, 1.0);
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return AppSurfaceCard(
      onTap: () => context.goToShellTab(AppRoutes.goals),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  l10n.currentGoals,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          _GoalRow(
            text: l10n.memorizeGoal(goalAyahs),
            value: '$memorized/$goalAyahs',
            progress: memProgress,
          ),
          SizedBox(height: AppSpacing.sm),
          _GoalRow(
            text: l10n.reviewSessionsGoal(goalReviews),
            value: '$reviewed/$goalReviews',
            progress: reviewProgress,
          ),
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.text,
    required this.value,
    required this.progress,
  });

  final String text;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: AppText(text)),
            AppText(
              value,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xxs),
        AppAnimatedProgress(value: progress, minHeight: 6, borderRadius: 20),
      ],
    );
  }
}
