import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:werdi/core/theme/app_colors.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/features/home/presentation/models/home_quick_action.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/routes/app_routes.dart';

class HomeQuickActionsGrid extends StatelessWidget {
  const HomeQuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actions = [
      (
        action: HomeQuickAction(
          title: l10n.memorizeNow,
          subtitle: l10n.memorizeAndTestSubtitle,
          icon: Icons.menu_book_rounded,
          type: HomeQuickActionType.memorize,
        ),
        color: AppColors.brandPrimary,
      ),
      (
        action: HomeQuickAction(
          title: l10n.reviewAction,
          subtitle: l10n.reviewSubtitle,
          icon: Icons.history_edu_rounded,
          type: HomeQuickActionType.review,
        ),
        color: AppColors.brandSecondary,
      ),
      (
        action: HomeQuickAction(
          title: l10n.openQuran,
          subtitle: l10n.openQuranSubtitle,
          icon: Icons.auto_stories_rounded,
          type: HomeQuickActionType.quran,
        ),
        color: AppColors.success,
      ),
    ];

    return Column(
      children: actions.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < actions.length - 1 ? AppSpacing.sm : 0,
          ),
          child: _ActionCard(
            action: item.action,
            accent: item.color,
          ),
        );
      }).toList(),
    );
  }
}

class _ActionCard extends StatefulWidget {
  const _ActionCard({
    required this.action,
    required this.accent,
  });

  final HomeQuickAction action;
  final Color accent;

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _pressed = false;

  void _onTap() {
    switch (widget.action.type) {
      case HomeQuickActionType.memorize:
        context.pushNamed(AppRoutes.memorization);
      case HomeQuickActionType.review:
        context.pushNamed(AppRoutes.review);
      case HomeQuickActionType.quran:
        context.pushNamed(AppRoutes.quran);
      case HomeQuickActionType.test:
        context.pushNamed(AppRoutes.memorization);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: _onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        scale: _pressed ? 0.98 : 1,
        curve: Curves.easeOutCubic,
        child: AppSurfaceCard(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.accent.withValues(alpha: 0.18),
                      widget.accent.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.accent.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  widget.action.icon,
                  color: widget.accent,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ScaledLabel(
                      text: widget.action.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    SizedBox(height: 2.h),
                    _ScaledLabel(
                      text: widget.action.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14.sp,
                textDirection: TextDirection.ltr,
                color: widget.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScaledLabel extends StatelessWidget {
  const _ScaledLabel({required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Text(text, maxLines: 1, style: style),
    );
  }
}
