import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:werdi/core/animations/app_animations.dart';
import 'package:werdi/core/constants/app_assets.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/theme/app_durations.dart';
import 'package:werdi/core/theme/app_radius.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_button.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_spacing.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:werdi/features/onboarding/presentation/models/onboarding_item.dart';
import 'package:werdi/routes/app_routes.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = <OnboardingItem>[
      OnboardingItem(
        title: l10n.onboardingTitle1,
        subtitle: l10n.onboardingSubtitle1,
      ),
      OnboardingItem(
        title: l10n.onboardingTitle2,
        subtitle: l10n.onboardingSubtitle2,
      ),
      OnboardingItem(
        title: l10n.onboardingTitle3,
        subtitle: l10n.onboardingSubtitle3,
      ),
      OnboardingItem(
        title: l10n.onboardingTitle4,
        subtitle: l10n.onboardingSubtitle4,
      ),
    ];
    return BlocProvider(
      create: (_) => OnboardingCubit(totalPages: items.length),
      child: _OnboardingView(items: items),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView({required this.items});

  final List<OnboardingItem> items;

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _animateToPage(int index) async {
    await _pageController.animateToPage(
      index,
      duration: AppDurations.slow,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, int>(
      builder: (context, currentPage) {
        final cubit = context.read<OnboardingCubit>();
        final isLast = cubit.isLast;

        return AppScaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: () async {
                      cubit.skip();
                      await _animateToPage(widget.items.length - 1);
                    },
                    child: AppText(context.l10n.skip),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.items.length,
                    onPageChanged: cubit.setPage,
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      return _OnboardingCard(item: item).fadeInSmooth();
                    },
                  ),
                ),
                _PageDots(count: widget.items.length, current: currentPage),
                AppVSpace.of(AppSpacing.lg),
                AppButton(
                  label: isLast ? context.l10n.startNow : context.l10n.next,
                  onPressed: () async {
                    if (isLast) {
                      context.goNamed(AppRoutes.home);
                      return;
                    }
                    cubit.next();
                    await _animateToPage(currentPage + 1);
                  },
                  icon: Icon(
                    isLast
                        ? Icons.play_arrow_rounded
                        : Icons.arrow_back_rounded,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({required this.item});

  final OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Builder(
          builder: (context) {
            final side = (MediaQuery.sizeOf(context).width * 0.62).clamp(
              180.0,
              260.0,
            );
            return Container(
              width: side,
              height: side,
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                borderRadius: AppRadius.card,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.surfaceContainerHighest,
                  ],
                ),
              ),
              child: Image.asset(AppAssets.logo),
            );
          },
        ),
        AppVSpace.of(AppSpacing.xl),
        AppText(
          item.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        AppVSpace.of(AppSpacing.sm),
        AppText(
          item.subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = current == index;
        return AnimatedContainer(
          duration: AppDurations.fast,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: active ? 22 : 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: active
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.18),
          ),
        );
      }),
    );
  }
}
