import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/navigation/shell_tab_coordinator.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_shell_scaffold.dart';
import 'package:werdi/core/widgets/app_spacing.dart';
import 'package:werdi/features/home/presentation/cubit/home_cubit.dart';
import 'package:werdi/features/home/presentation/cubit/home_state.dart';
import 'package:werdi/features/home/presentation/widgets/home_dashboard_cards.dart';
import 'package:werdi/features/home/presentation/widgets/home_greeting_section.dart';
import 'package:werdi/features/home/presentation/widgets/home_quick_actions_grid.dart';
import 'package:werdi/routes/app_routes.dart';

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
    _cubit = HomeCubit(
      dashboardService: AppInjector.homeDashboardService,
      goalsRepository: AppInjector.userGoalsRepository,
    )..initialize();
    ShellTabCoordinator.onHomeTabSelected = () {
      if (mounted) _cubit.refresh();
    };
  }

  @override
  void dispose() {
    ShellTabCoordinator.onHomeTabSelected = null;
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
            previous.dailyCompletedAyahs != current.dailyCompletedAyahs ||
            previous.dailyTargetAyahs != current.dailyTargetAyahs ||
            previous.currentSurahName != current.currentSurahName ||
            previous.totalMemorizationProgress !=
                current.totalMemorizationProgress ||
            previous.currentSurahProgress != current.currentSurahProgress ||
            previous.weeklyMemorizedAyahs != current.weeklyMemorizedAyahs ||
            previous.streakDays != current.streakDays,
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => context.read<HomeCubit>().refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
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
                DailyGoalCard(
                  state: state,
                  onTap: () => context.goToShellTab(AppRoutes.goals),
                ),
                AppVSpace.of(AppSpacing.md),
                ProgressOverviewCard(state: state),
                AppVSpace.of(AppSpacing.lg),
                const HomeQuickActionsGrid(),
                AppVSpace.of(AppSpacing.md),
                StreakCard(state: state),
                AppVSpace.of(AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }
}
