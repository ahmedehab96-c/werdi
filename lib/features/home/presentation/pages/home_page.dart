import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/animations/app_animations.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_loading_state.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_spacing.dart';
import 'package:werdi/features/home/presentation/cubit/home_cubit.dart';
import 'package:werdi/features/home/presentation/cubit/home_state.dart';
import 'package:werdi/features/home/presentation/widgets/home_dashboard_cards.dart';
import 'package:werdi/features/home/presentation/widgets/home_greeting_section.dart';
import 'package:werdi/features/home/presentation/widgets/home_quick_actions_grid.dart';
import 'package:werdi/features/home/presentation/widgets/home_section_title.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(
        progressRepository: AppInjector.userProgressGateway,
        authRepository: AppInjector.authGateway,
        reviewRepository: AppInjector.localReviewRepository,
        preferences: AppInjector.appPreferences,
      )..initialize(),
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
        builder: (context, state) {
          if (state.isLoading) {
            return AppLoadingState(message: context.l10n.preparingDashboard);
          }
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeGreetingSection(state: state).fadeInSmooth(),
                      AppVSpace.of(AppSpacing.lg),
                      DailyGoalCard(state: state),
                      AppVSpace.of(AppSpacing.lg),
                      ProgressOverviewCard(state: state),
                      AppVSpace.of(AppSpacing.lg),
                      HomeSectionTitle(
                        title: context.l10n.quickActionsTitle,
                      ).fadeInQuick(),
                      AppVSpace.of(AppSpacing.sm),
                      const HomeQuickActionsGrid().fadeInSmooth(),
                      AppVSpace.of(AppSpacing.lg),
                      _responsiveInfoCards(context, state).fadeInSmooth(),
                      AppVSpace.of(AppSpacing.lg),
                      ReviewReminderCard(state: state),
                      AppVSpace.of(AppSpacing.lg),
                      WeeklyInsightsCard(state: state),
                      AppVSpace.of(AppSpacing.lg),
                      _responsiveBottomCards(context, state).fadeInSmooth(),
                      AppVSpace.of(AppSpacing.lg),
                      RecommendedPlanCard(state: state),
                      AppVSpace.of(AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _responsiveInfoCards(BuildContext context, HomeState state) {
    return _responsivePair(
      LastMemorizedSurahCard(state: state),
      DailyMotivationCard(state: state),
    );
  }

  Widget _responsiveBottomCards(BuildContext context, HomeState state) {
    return _responsivePair(
      StreakCard(state: state),
      AchievementsPreviewCard(state: state),
    );
  }

  /// Lays out two cards side by side on wide layouts and stacked on narrow
  /// ones, keeping the gap consistent across both axes.
  Widget _responsivePair(Widget first, Widget second) {
    const gap = 12.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
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
