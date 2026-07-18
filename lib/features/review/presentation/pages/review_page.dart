import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_button.dart';
import 'package:werdi/core/widgets/app_empty_state.dart';
import 'package:werdi/core/widgets/app_icon_container.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_status_chip.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/core/widgets/quran_ayah_text.dart';
import 'package:werdi/features/review/domain/models/review_item.dart';
import 'package:werdi/features/review/domain/models/smart_review_plan.dart';
import 'package:werdi/features/review/presentation/cubit/review_cubit.dart';
import 'package:werdi/features/review/presentation/cubit/review_state.dart';
import 'package:werdi/core/extensions/context_extensions.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReviewCubit(
        repository: AppInjector.reviewGateway,
        progressRepository: AppInjector.userProgressGateway,
        goalsRepository: AppInjector.userGoalsRepository,
      ),
      child: const _ReviewView(),
    );
  }
}

class _ReviewView extends StatelessWidget {
  const _ReviewView();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text(context.l10n.reviewTitle)),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: BlocBuilder<ReviewCubit, ReviewState>(
          builder: (context, state) {
            if (state.items.isEmpty) {
              return AppEmptyState(
                title: context.l10n.noReviewItems,
                subtitle: context.l10n.noReviewItemsSubtitle,
                icon: Icons.check_circle_outline_rounded,
              );
            }

            if (state.sessionActive && state.sessionComplete) {
              return _SessionCompleteView(
                onDone: () => context.read<ReviewCubit>().endSmartSession(),
              );
            }

            if (state.sessionActive && state.currentSessionItem != null) {
              return _SmartSessionView(
                state: state,
                item: state.currentSessionItem!,
              );
            }

            return ListView.separated(
              itemCount: state.items.length + 1,
              separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _SmartReviewPlanCard(plan: state.plan);
                }
                final item = state.items[index - 1];
                final inPlan = state.plan?.sessionItems
                        .any((sessionItem) => sessionItem.id == item.id) ??
                    false;
                return _ReviewSmartCard(item: item, highlighted: inPlan);
              },
            );
          },
        ),
      ),
    );
  }
}

class _SmartReviewPlanCard extends StatelessWidget {
  const _SmartReviewPlanCard({required this.plan});

  final SmartReviewPlan? plan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final plan = this.plan;

    if (plan == null || !plan.hasSession) {
      return const SizedBox.shrink();
    }

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIconContainer(
                icon: Icons.auto_awesome_rounded,
                size: 48,
                background: theme.colorScheme.primaryContainer,
                foreground: theme.colorScheme.primary,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      l10n.smartReviewPlanTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    AppText(
                      l10n.smartReviewPlanSubtitle(
                        plan.difficultCount,
                        plan.pendingCount,
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    AppText(
                      l10n.smartReviewDailyQuota(plan.dailyQuota),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          AppButton(
            label: l10n.startSmartReviewSession,
            onPressed: () => context.read<ReviewCubit>().startSmartSession(),
            icon: const Icon(Icons.play_arrow_rounded),
          ),
        ],
      ),
    );
  }
}

class _SmartSessionView extends StatelessWidget {
  const _SmartSessionView({
    required this.state,
    required this.item,
  });

  final ReviewState state;
  final ReviewItem item;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReviewCubit>();
    final l10n = context.l10n;
    final plan = state.plan!;
    final current = state.sessionIndex + 1;
    final total = plan.sessionItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: AppText(
                l10n.smartReviewSessionProgress(current, total),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            TextButton(
              onPressed: cubit.endSmartSession,
              child: Text(l10n.endSmartReviewSession),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(value: current / total),
        SizedBox(height: AppSpacing.md),
        Expanded(
          child: SingleChildScrollView(
            child: _ReviewSmartCard(item: item, highlighted: true),
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        AppButton(
          label: l10n.markReviewedAndNext,
          onPressed: () => cubit.markCurrentReviewedAndAdvance(),
          icon: const Icon(Icons.check_circle_outline_rounded),
        ),
        SizedBox(height: AppSpacing.xs),
        AppButton(
          label: l10n.nextReviewItem,
          onPressed: cubit.skipCurrentSessionItem,
          icon: const Icon(Icons.skip_next_rounded),
          variant: AppButtonVariant.outlined,
        ),
      ],
    );
  }
}

class _SessionCompleteView extends StatelessWidget {
  const _SessionCompleteView({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.celebration_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: AppSpacing.md),
          AppText(
            context.l10n.smartReviewSessionComplete,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),
          AppButton(
            label: context.l10n.endSmartReviewSession,
            onPressed: onDone,
          ),
        ],
      ),
    );
  }
}

class _ReviewSmartCard extends StatefulWidget {
  const _ReviewSmartCard({
    required this.item,
    this.highlighted = false,
  });

  final ReviewItem item;
  final bool highlighted;

  @override
  State<_ReviewSmartCard> createState() => _ReviewSmartCardState();
}

class _ReviewSmartCardState extends State<_ReviewSmartCard> {
  bool _ayahExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReviewCubit>();
    final item = widget.item;
    final theme = Theme.of(context);

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.highlighted) ...[
            AppStatusChip(
              label: context.l10n.smartReviewPlanBadge,
              foreground: theme.colorScheme.primary,
              background: theme.colorScheme.primaryContainer,
            ),
            SizedBox(height: AppSpacing.xs),
          ],
          Row(
            children: [
              Expanded(
                child: AppText(
                  item.title,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              _PriorityLabel(priority: item.priority),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          AppText(item.subtitle, style: theme.textTheme.bodySmall),

          if (item.ayahText.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: () => setState(() => _ayahExpanded = !_ayahExpanded),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      _ayahExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    AppText(
                      _ayahExpanded
                          ? context.l10n.hideAyahs
                          : context.l10n.showAyahs,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_ayahExpanded)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(top: AppSpacing.xs),
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: QuranAyahText(
                  text: item.ayahText,
                  textAlign: TextAlign.right,
                  fontScale: 0.95,
                  showFrame: true,
                ),
              ),
          ],

          SizedBox(height: AppSpacing.sm),

          LayoutBuilder(
            builder: (context, constraints) {
              final l10n = context.l10n;
              final compact = constraints.maxWidth < 400;
              if (compact) {
                return Column(
                  children: [
                    AppButton(
                      label: item.reviewed ? l10n.reviewed : l10n.markReviewed,
                      onPressed: () => cubit.markReviewed(item.id),
                      icon: Icon(
                        item.reviewed
                            ? Icons.check_circle_rounded
                            : Icons.check_circle_outline_rounded,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: l10n.repeat,
                            onPressed: () => cubit.repeat(item.id),
                            icon: const Icon(Icons.replay_rounded),
                            variant: AppButtonVariant.outlined,
                          ),
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: AppButton(
                            label: item.difficult
                                ? l10n.difficult
                                : l10n.difficultQuestion,
                            onPressed: () => cubit.markDifficult(item.id),
                            icon: Icon(
                              item.difficult
                                  ? Icons.flag_rounded
                                  : Icons.outlined_flag_rounded,
                            ),
                            variant: AppButtonVariant.outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: item.reviewed ? l10n.reviewed : l10n.markReviewed,
                      onPressed: () => cubit.markReviewed(item.id),
                      icon: Icon(
                        item.reviewed
                            ? Icons.check_circle_rounded
                            : Icons.check_circle_outline_rounded,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: AppButton(
                      label: l10n.repeat,
                      onPressed: () => cubit.repeat(item.id),
                      icon: const Icon(Icons.replay_rounded),
                      variant: AppButtonVariant.outlined,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: AppButton(
                      label: item.difficult
                          ? l10n.difficult
                          : l10n.difficultQuestion,
                      onPressed: () => cubit.markDifficult(item.id),
                      icon: Icon(
                        item.difficult
                            ? Icons.flag_rounded
                            : Icons.outlined_flag_rounded,
                      ),
                      variant: AppButtonVariant.outlined,
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

class _PriorityLabel extends StatelessWidget {
  const _PriorityLabel({required this.priority});

  final ReviewPriority priority;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (text, color) = switch (priority) {
      ReviewPriority.high => (l10n.highPriority, Colors.redAccent),
      ReviewPriority.medium => (l10n.mediumPriority, Colors.orange),
      ReviewPriority.low => (l10n.lowPriority, Colors.green),
    };

    return AppStatusChip(
      label: text,
      foreground: color,
      background: color.withValues(alpha: 0.15),
    );
  }
}
