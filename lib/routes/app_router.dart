import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:werdi/core/theme/app_durations.dart';
import 'package:werdi/core/widgets/feature_placeholder.dart';
import 'package:werdi/features/achievements/presentation/pages/achievements_page.dart';
import 'package:werdi/features/auth/presentation/pages/auth_page.dart';
import 'package:werdi/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:werdi/features/home/presentation/pages/home_page.dart';
import 'package:werdi/features/memorization/presentation/pages/memorization_page.dart';
import 'package:werdi/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:werdi/features/profile/presentation/pages/profile_page.dart';
import 'package:werdi/features/quran/presentation/pages/quran_page.dart';
import 'package:werdi/features/review/presentation/pages/review_page.dart';
import 'package:werdi/features/settings/presentation/pages/settings_page.dart';
import 'package:werdi/features/settings/presentation/pages/notifications_page.dart';
import 'package:werdi/features/splash/presentation/pages/splash_page.dart';
import 'package:werdi/features/tasmee3/presentation/pages/tasmee3_page.dart';
import 'package:werdi/routes/app_routes.dart';

final class AppRouter {
  const AppRouter._();

  static CustomTransitionPage<void> _page(GoRouterState state, Widget child) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppDurations.routeEnter,
      reverseTransitionDuration: AppDurations.routeExit,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0.015, 0),
          end: Offset.zero,
        ).animate(fade);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splashPath,
    routes: <RouteBase>[
      GoRoute(
        name: AppRoutes.splash,
        path: AppRoutes.splashPath,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const SplashPage(),
          transitionDuration: AppDurations.slow,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        name: AppRoutes.onboarding,
        path: AppRoutes.onboardingPath,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const OnboardingPage(),
          transitionDuration: AppDurations.slow,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offset =
                Tween<Offset>(
                  begin: const Offset(0.02, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                );
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offset, child: child),
            );
          },
        ),
      ),
      GoRoute(
        name: AppRoutes.auth,
        path: AppRoutes.authPath,
        pageBuilder: (context, state) => _page(state, const AuthPage()),
      ),
      GoRoute(
        name: AppRoutes.forgotPassword,
        path: AppRoutes.forgotPasswordPath,
        pageBuilder: (context, state) =>
            _page(state, const ForgotPasswordPage()),
      ),
      GoRoute(
        name: AppRoutes.home,
        path: AppRoutes.homePath,
        pageBuilder: (context, state) => _page(state, const HomePage()),
      ),
      GoRoute(
        name: AppRoutes.quran,
        path: AppRoutes.quranPath,
        pageBuilder: (context, state) => _page(state, const QuranPage()),
      ),
      GoRoute(
        name: AppRoutes.memorization,
        path: AppRoutes.memorizationPath,
        pageBuilder: (context, state) => _page(state, const MemorizationPage()),
      ),
      GoRoute(
        name: AppRoutes.review,
        path: AppRoutes.reviewPath,
        pageBuilder: (context, state) => _page(state, const ReviewPage()),
      ),
      GoRoute(
        name: AppRoutes.tasmee3,
        path: AppRoutes.tasmee3Path,
        pageBuilder: (context, state) => _page(state, const Tasmee3Page()),
      ),
      GoRoute(
        name: AppRoutes.achievements,
        path: AppRoutes.achievementsPath,
        pageBuilder: (context, state) => _page(state, const AchievementsPage()),
      ),
      GoRoute(
        name: AppRoutes.profile,
        path: AppRoutes.profilePath,
        pageBuilder: (context, state) => _page(state, const ProfilePage()),
      ),
      GoRoute(
        name: AppRoutes.settings,
        path: AppRoutes.settingsPath,
        pageBuilder: (context, state) => _page(state, const SettingsPage()),
      ),
      GoRoute(
        name: AppRoutes.notifications,
        path: AppRoutes.notificationsPath,
        pageBuilder: (context, state) =>
            _page(state, const NotificationsPage()),
      ),
    ],
    errorBuilder: (context, state) =>
        const FeaturePlaceholder(title: 'Not Found'),
  );
}
