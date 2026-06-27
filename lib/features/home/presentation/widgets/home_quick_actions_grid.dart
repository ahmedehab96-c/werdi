import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:werdi/core/animations/app_animations.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_icon_container.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/home/presentation/models/home_quick_action.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/routes/app_routes.dart';

class HomeQuickActionsGrid extends StatelessWidget {
  const HomeQuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actions = [
      HomeQuickAction(
        title: l10n.memorizeNow,
        subtitle: l10n.memorizeSubtitle,
        icon: Icons.menu_book_rounded,
        type: HomeQuickActionType.memorize,
      ),
      HomeQuickAction(
        title: l10n.reviewAction,
        subtitle: l10n.reviewSubtitle,
        icon: Icons.history_edu_rounded,
        type: HomeQuickActionType.review,
      ),
      HomeQuickAction(
        title: l10n.testYourself,
        subtitle: l10n.testSubtitle,
        icon: Icons.mic_rounded,
        type: HomeQuickActionType.test,
      ),
      HomeQuickAction(
        title: l10n.openQuran,
        subtitle: l10n.openQuranSubtitle,
        icon: Icons.auto_stories_rounded,
        type: HomeQuickActionType.quran,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 1100
            ? 4
            : constraints.maxWidth > 680
            ? 3
            : 2;
        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * AppSpacing.sm)) / columns;

        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: actions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            return SizedBox(
              width: itemWidth,
              child: _ActionCard(action: action, index: index),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ActionCard extends StatefulWidget {
  const _ActionCard({required this.action, required this.index});

  final HomeQuickAction action;
  final int index;

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () {
        switch (widget.action.type) {
          case HomeQuickActionType.memorize:
            context.pushNamed(AppRoutes.memorization);
          case HomeQuickActionType.review:
            context.pushNamed(AppRoutes.review);
          case HomeQuickActionType.test:
            context.pushNamed(AppRoutes.tasmee3);
          case HomeQuickActionType.quran:
            context.pushNamed(AppRoutes.quran);
        }
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        scale: _pressed ? 0.96 : 1,
        curve: Curves.easeOutCubic,
        child: AppSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIconContainer(icon: widget.action.icon),
              SizedBox(height: 10.h),
              AppText(
                widget.action.title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(height: 4.h),
              AppText(
                widget.action.subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ).entranceStagger(widget.index, stepMs: 90),
    );
  }
}
