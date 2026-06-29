import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/responsive/responsive.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_spacing.dart';
import 'package:werdi/features/home/presentation/cubit/home_cubit.dart';
import 'package:werdi/features/home/presentation/cubit/home_state.dart';
import 'package:werdi/features/home/presentation/widgets/home_dashboard_cards.dart';
import 'package:werdi/features/home/presentation/widgets/home_greeting_section.dart';
import 'package:werdi/features/home/presentation/widgets/home_quick_actions_grid.dart';
import 'package:werdi/features/home/presentation/widgets/home_section_title.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final HomeCubit _cubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit = HomeCubit(dashboardService: AppInjector.homeDashboardService)
      ..initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cubit.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: BlocBuilder<HomeCubit, HomeState>(
        buildWhen: (previous, current) =>
            previous.isRefreshing != current.isRefreshing ||
            previous.userName != current.userName ||
            previous.motivationSubtitle != current.motivationSubtitle ||
            previous.dailyCompletedAyahs != current.dailyCompletedAyahs ||
            previous.dailyTargetAyahs != current.dailyTargetAyahs ||
            previous.currentSurahName != current.currentSurahName ||
            previous.totalMemorizationProgress !=
                current.totalMemorizationProgress ||
            previous.currentSurahProgress != current.currentSurahProgress ||
            previous.weeklyMemorizedAyahs != current.weeklyMemorizedAyahs ||
            previous.weeklyProgress != current.weeklyProgress ||
            previous.streakDays != current.streakDays ||
            previous.badges != current.badges ||
            previous.currentMilestoneAyahs != current.currentMilestoneAyahs ||
            previous.nextMilestoneAyahs != current.nextMilestoneAyahs ||
            previous.nextBadgeTitle != current.nextBadgeTitle,
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => context.read<HomeCubit>().refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              children: [
                if (state.isRefreshing)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                HomeGreetingSection(state: state),
                AppVSpace.of(AppSpacing.lg),
                DailyGoalCard(state: state),
                AppVSpace.of(AppSpacing.lg),
                ProgressOverviewCard(state: state),
                AppVSpace.of(AppSpacing.lg),
                HomeSectionTitle(title: context.l10n.quickActionsTitle),
                AppVSpace.of(AppSpacing.sm),
                const HomeQuickActionsGrid(),
                AppVSpace.of(AppSpacing.lg),
                _responsiveBottomCards(context, state),
                AppVSpace.of(AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _responsiveBottomCards(BuildContext context, HomeState state) {
    return _responsivePair(
      StreakCard(state: state),
      AchievementsPreviewCard(state: state),
    );
  }

  Widget _responsivePair(Widget first, Widget second) {
    const gap = 12.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (Responsive.sizeOf(context).index >= ScreenSize.expanded.index) {
          return Row(
            children: [
              Expanded(child: first),
              const SizedBox(width: gap),
              Expanded(child: second),
            ],
          );
        }
        return Column(
          children: [first, const SizedBox(height: gap), second],
        );
      },
    );
  }
}
