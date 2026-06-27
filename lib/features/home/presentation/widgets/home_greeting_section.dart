import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:werdi/core/animations/app_animations.dart';
import 'package:werdi/core/constants/app_assets.dart';
import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_spacing.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/home/presentation/cubit/home_state.dart';
import 'package:werdi/routes/app_routes.dart';

class HomeGreetingSection extends StatelessWidget {
  const HomeGreetingSection({required this.state, super.key});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                state.userName.isEmpty ? AppConstants.appName : state.userName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ).slideUpEntrance(),
              if (state.motivationSubtitle.isNotEmpty) ...[
                AppVSpace.of(AppSpacing.xs),
                AppText(
                  state.motivationSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                ).slideUpEntrance(delay: const Duration(milliseconds: 80)),
              ],
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              tooltip: 'الإشعارات',
              onPressed: () => context.pushNamed(AppRoutes.notifications),
              icon: const Icon(Icons.notifications_none_rounded),
            ).tapFeedback(),
            IconButton(
              tooltip: context.l10n.settingsTitle,
              onPressed: () => context.pushNamed(AppRoutes.settings),
              icon: const Icon(Icons.settings_outlined),
            ).tapFeedback(),
            SizedBox(
              width: 44.w,
              height: 44.w,
              child: Image.asset(
                AppAssets.logo,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ).floatLoop(),
          ],
        ),
      ],
    );
  }
}
