import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:werdi/core/animations/app_animations.dart';
import 'package:werdi/core/constants/app_assets.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/theme/app_radius.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_button.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/routes/app_routes.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  static const _completedKey = 'onboarding_completed';

  static Future<bool> isCompleted() async {
    final value = await AppInjector.appPreferences.getString(_completedKey);
    return value == '1';
  }

  static Future<void> markCompleted() async {
    await AppInjector.appPreferences.setString(_completedKey, '1');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final logoSize =
        (MediaQuery.sizeOf(context).width * 0.38).clamp(120.0, 180.0);

    return AppScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final topGap = (constraints.maxHeight * 0.12).clamp(24.0, 80.0);
          final midGap = (constraints.maxHeight * 0.14).clamp(32.0, 120.0);
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  SizedBox(height: topGap),
                  Container(
                    width: logoSize + 40,
                    height: logoSize + 40,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.card,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primaryContainer,
                          theme.colorScheme.surfaceContainerHighest,
                        ],
                      ),
                    ),
                    child: Image.asset(AppAssets.logo),
                  ).popIn().floatLoop(),
                  SizedBox(height: AppSpacing.xl),
                  AppText(
                    l10n.appName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ).slideUpEntrance(),
                  SizedBox(height: AppSpacing.sm),
                  AppText(
                    l10n.onboardingSubtitle1,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ).slideUpEntrance(
                    delay: const Duration(milliseconds: 120),
                  ),
                  SizedBox(height: midGap),
                  AppButton(
                    label: l10n.startNow,
                    onPressed: () async {
                      await markCompleted();
                      if (context.mounted) context.goNamed(AppRoutes.home);
                    },
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ).slideUpEntrance(
                    delay: const Duration(milliseconds: 200),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
