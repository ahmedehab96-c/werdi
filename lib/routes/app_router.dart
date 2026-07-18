import 'package:go_router/go_router.dart';
import 'package:werdi/core/animations/app_page_transitions.dart';
import 'package:werdi/core/widgets/app_shell_scaffold.dart';
import 'package:werdi/core/widgets/feature_placeholder.dart';
import 'package:werdi/features/achievements/presentation/pages/achievements_page.dart';
import 'package:werdi/features/goals/presentation/pages/goals_page.dart';
import 'package:werdi/features/home/presentation/pages/home_page.dart';
import 'package:werdi/features/memorization/presentation/pages/memorization_page.dart';
import 'package:werdi/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:werdi/features/profile/presentation/pages/profile_page.dart';
import 'package:werdi/features/quran/presentation/pages/quran_page.dart';
import 'package:werdi/features/review/presentation/pages/review_page.dart';
import 'package:werdi/features/quran/presentation/pages/offline_recitations_page.dart';
import 'package:werdi/features/settings/presentation/pages/settings_page.dart';
import 'package:werdi/features/settings/presentation/pages/notifications_page.dart';
import 'package:werdi/features/splash/presentation/pages/splash_page.dart';
import 'package:werdi/features/tasmee3/presentation/pages/tasmee3_page.dart';
import 'package:werdi/routes/app_routes.dart';

final class AppRouter {
  const AppRouter._();

  /// When set (e.g. `--dart-define=SCREENSHOT_ROUTE=/quran`), skip splash and
  /// open that path — used for Play Store screenshot capture.
  static const String screenshotRoute = String.fromEnvironment(
    'SCREENSHOT_ROUTE',
  );

  static final GoRouter router = GoRouter(
    initialLocation: screenshotRoute.isEmpty
        ? AppRoutes.splashPath
        : screenshotRoute,
    routes: <RouteBase>[
      GoRoute(
        name: AppRoutes.splash,
        path: AppRoutes.splashPath,
        pageBuilder: (context, state) =>
            AppPageTransitions.splash(state, const SplashPage()),
      ),
      GoRoute(
        name: AppRoutes.onboarding,
        path: AppRoutes.onboardingPath,
        pageBuilder: (context, state) =>
            AppPageTransitions.welcome(state, const OnboardingPage()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.home,
                path: AppRoutes.homePath,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomePage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.quran,
                path: AppRoutes.quranPath,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: QuranPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.memorization,
                path: AppRoutes.memorizationPath,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: MemorizationPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.goals,
                path: AppRoutes.goalsPath,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: GoalsPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.profile,
                path: AppRoutes.profilePath,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfilePage(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        name: AppRoutes.review,
        path: AppRoutes.reviewPath,
        pageBuilder: (context, state) =>
            AppPageTransitions.standard(state, const ReviewPage()),
      ),
      GoRoute(
        name: AppRoutes.tasmee3,
        path: AppRoutes.tasmee3Path,
        pageBuilder: (context, state) =>
            AppPageTransitions.standard(state, const Tasmee3Page()),
      ),
      GoRoute(
        name: AppRoutes.achievements,
        path: AppRoutes.achievementsPath,
        pageBuilder: (context, state) =>
            AppPageTransitions.standard(state, const AchievementsPage()),
      ),
      GoRoute(
        name: AppRoutes.settings,
        path: AppRoutes.settingsPath,
        pageBuilder: (context, state) =>
            AppPageTransitions.standard(state, const SettingsPage()),
      ),
      GoRoute(
        name: AppRoutes.notifications,
        path: AppRoutes.notificationsPath,
        pageBuilder: (context, state) =>
            AppPageTransitions.standard(state, const NotificationsPage()),
      ),
      GoRoute(
        name: AppRoutes.offlineRecitations,
        path: AppRoutes.offlineRecitationsPath,
        pageBuilder: (context, state) => AppPageTransitions.standard(
          state,
          const OfflineRecitationsPage(),
        ),
      ),
    ],
    errorBuilder: (context, state) =>
        const FeaturePlaceholder(title: 'Not Found'),
  );
}
