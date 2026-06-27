import 'package:go_router/go_router.dart';
import 'package:werdi/core/animations/app_page_transitions.dart';
import 'package:werdi/core/widgets/feature_placeholder.dart';
import 'package:werdi/features/achievements/presentation/pages/achievements_page.dart';
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

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splashPath,
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
      GoRoute(
        name: AppRoutes.home,
        path: AppRoutes.homePath,
        pageBuilder: (context, state) =>
            AppPageTransitions.homeReveal(state, const HomePage()),
      ),
      GoRoute(
        name: AppRoutes.quran,
        path: AppRoutes.quranPath,
        pageBuilder: (context, state) =>
            AppPageTransitions.standard(state, const QuranPage()),
      ),
      GoRoute(
        name: AppRoutes.memorization,
        path: AppRoutes.memorizationPath,
        pageBuilder: (context, state) =>
            AppPageTransitions.standard(state, const MemorizationPage()),
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
        name: AppRoutes.profile,
        path: AppRoutes.profilePath,
        pageBuilder: (context, state) =>
            AppPageTransitions.standard(state, const ProfilePage()),
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
    ],
    errorBuilder: (context, state) =>
        const FeaturePlaceholder(title: 'Not Found'),
  );
}
