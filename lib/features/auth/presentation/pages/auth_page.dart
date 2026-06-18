import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:werdi/core/theme/app_elevation.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_spacing.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/auth/presentation/pages/login_page.dart';
import 'package:werdi/features/auth/presentation/pages/register_page.dart';
import 'package:werdi/features/auth/presentation/widgets/auth_header.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/routes/app_routes.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        maxContentWidth: 480,
        body: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                title: l10n.authWelcomeTitle,
                subtitle: l10n.authWelcomeSubtitle,
              ),
              AppVSpace.of(AppSpacing.xl),
              Container(
                decoration: AppElevation.card(context),
                child: TabBar(
                  tabs: [
                    Tab(text: l10n.loginTab),
                    Tab(text: l10n.registerTab),
                  ],
                ),
              ),
              AppVSpace.of(AppSpacing.md),
              const Expanded(
                child: TabBarView(children: [LoginPage(), RegisterPage()]),
              ),
              AppVSpace.of(AppSpacing.xs),
              TextButton(
                onPressed: () => context.goNamed(AppRoutes.home),
                child: AppText(l10n.continueAsGuest),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
