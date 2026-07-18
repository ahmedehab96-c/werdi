import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/responsive/responsive_utils.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_animated_progress.dart';
import 'package:werdi/core/widgets/app_button.dart';
import 'package:werdi/core/widgets/app_error_state.dart';
import 'package:werdi/core/widgets/app_loading_state.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/core/widgets/responsive_bottom_sheet.dart';
import 'package:werdi/features/goals/domain/models/user_goals.dart';
import 'package:werdi/features/goals/presentation/cubit/goals_cubit.dart';
import 'package:werdi/features/goals/presentation/cubit/goals_state.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GoalsCubit(
        goalsRepository: AppInjector.userGoalsRepository,
        progressRepository: AppInjector.userProgressGateway,
        database: AppInjector.appDatabase,
      )..load(),
      child: const _GoalsView(),
    );
  }
}

class _GoalsView extends StatelessWidget {
  const _GoalsView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      appBar: AppBar(title: Text(l10n.goalsTitle)),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.addGoal,
        onPressed: () => _showAddGoalSheet(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: BlocBuilder<GoalsCubit, GoalsState>(
        builder: (context, state) {
          if (state.status == GoalsStatus.loading) {
            return AppLoadingState(message: l10n.loading);
          }
          if (state.status == GoalsStatus.error && state.progress == null) {
            return AppErrorState(
              message: state.errorMessage,
              onRetry: () => context.read<GoalsCubit>().load(),
            );
          }

          final progress = state.progress;
          final memorized = progress?.memorizedAyahCount ?? 0;
          final reviewed = progress?.reviewedItemsCount ?? 0;
          final todayAyahs = state.todayMemorizedAyahs;
          final bottomPad = ResponsiveUtils.responsiveSpacing(context, 88);

          return Stack(
            children: [
              ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  bottomPad,
                ),
                children: [
                  _GoalCard(
                    icon: Icons.wb_sunny_rounded,
                    title: l10n.dailyGoal,
                    current: todayAyahs,
                    target: state.goals.dailyTargetAyahs,
                    max: 50,
                    onChanged: (v) =>
                        context.read<GoalsCubit>().setDailyTarget(v),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  _GoalCard(
                    icon: Icons.menu_book_rounded,
                    title: l10n.memorizeGoal(state.goals.memorizationGoalAyahs),
                    current: memorized,
                    target: state.goals.memorizationGoalAyahs,
                    max: 1000,
                    onChanged: (v) =>
                        context.read<GoalsCubit>().setMemorizationGoal(v),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  _GoalCard(
                    icon: Icons.replay_rounded,
                    title: l10n.reviewSessionsGoal(
                      state.goals.reviewSessionsGoal,
                    ),
                    current: reviewed,
                    target: state.goals.reviewSessionsGoal,
                    max: 50,
                    onChanged: (v) =>
                        context.read<GoalsCubit>().setReviewGoal(v),
                  ),
                  if (state.goals.customGoals.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.md),
                    AppText(
                      l10n.customGoals,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    ...state.goals.customGoals.map(
                      (goal) => Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.xs),
                        child: _CustomGoalTile(
                          goal: goal,
                          current: memorized,
                          onDelete: () => context
                              .read<GoalsCubit>()
                              .removeCustomGoal(goal.id),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (state.status == GoalsStatus.saving)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(minHeight: 2),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showAddGoalSheet(BuildContext context) async {
    final l10n = context.l10n;
    final titleController = TextEditingController();
    final targetController = TextEditingController(text: '10');
    final cubit = context.read<GoalsCubit>();

    final saved = await showResponsiveBottomSheet<bool>(
      context: context,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: ResponsiveUtils.responsivePadding(sheetContext, 16),
            right: ResponsiveUtils.responsivePadding(sheetContext, 16),
            top: ResponsiveUtils.responsivePadding(sheetContext, 16),
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom +
                ResponsiveUtils.responsivePadding(sheetContext, 16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(
                l10n.addGoal,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              SizedBox(height: AppSpacing.sm),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: l10n.goalTitleLabel,
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: AppSpacing.sm),
              TextField(
                controller: targetController,
                decoration: InputDecoration(
                  labelText: l10n.goalTargetLabel,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.saveGoal,
                onPressed: () => Navigator.pop(sheetContext, true),
              ),
            ],
          ),
        );
      },
    );

    if (saved == true && context.mounted) {
      final target = int.tryParse(targetController.text.trim()) ?? 10;
      await cubit.addCustomGoal(
        title: titleController.text,
        target: target,
      );
    }

    titleController.dispose();
    targetController.dispose();
  }
}

class _GoalCard extends StatefulWidget {
  const _GoalCard({
    required this.icon,
    required this.title,
    required this.current,
    required this.target,
    required this.max,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final int current;
  final int target;
  final double max;
  final ValueChanged<int> onChanged;

  @override
  State<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<_GoalCard> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.target.toDouble();
  }

  @override
  void didUpdateWidget(covariant _GoalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      _sliderValue = widget.target.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress =
        widget.target == 0 ? 0.0 : (widget.current / widget.target).clamp(0.0, 1.0);
    final divisions = (widget.max - 1).round().clamp(1, 999);

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, color: scheme.primary, size: 22),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: AppText(
                  widget.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              AppText(
                '${widget.current}/${widget.target}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          AppAnimatedProgress(value: progress, minHeight: 6, borderRadius: 20),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _sliderValue.clamp(1, widget.max),
                  min: 1,
                  max: widget.max,
                  divisions: divisions,
                  label: _sliderValue.round().toString(),
                  onChanged: (v) => setState(() => _sliderValue = v),
                  onChangeEnd: (v) => widget.onChanged(v.round()),
                ),
              ),
              SizedBox(
                width: ResponsiveUtils.responsiveWidth(context, 40),
                child: AppText(
                  '${_sliderValue.round()}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomGoalTile extends StatelessWidget {
  const _CustomGoalTile({
    required this.goal,
    required this.current,
    required this.onDelete,
  });

  final UserCustomGoal goal;
  final int current;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final progress = (current / goal.target).clamp(0.0, 1.0);

    return Dismissible(
      key: ValueKey(goal.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: AppSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppText(
                    goal.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                AppText(
                  '$current/${goal.target}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs),
            AppAnimatedProgress(value: progress, minHeight: 6, borderRadius: 16),
          ],
        ),
      ),
    );
  }
}
