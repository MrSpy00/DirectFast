import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/views/welcome_screen.dart';
import '../../features/splash/views/splash_screen.dart';
import '../../features/home/views/home_screen.dart';
import '../../features/history/views/history_screen.dart';
import '../../features/settings/views/settings_screen.dart';
import '../../features/settings/views/data_backup_screen.dart';
import '../../features/settings/views/privacy_dashboard_screen.dart';
import '../../features/utils/views/utils_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String home = '/home';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String dataBackup = '/settings/data-backup';
  static const String privacyDashboard = '/settings/privacy-dashboard';
  static const String utils = '/utils';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: home,
        name: 'home',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: welcome,
        name: 'welcome',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const WelcomeScreen(),
        ),
      ),
      GoRoute(
        path: history,
        name: 'history',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const HistoryScreen(),
        ),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: dataBackup,
        name: 'data-backup',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const DataBackupScreen(),
        ),
      ),
      GoRoute(
        path: privacyDashboard,
        name: 'privacy-dashboard',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const PrivacyDashboardScreen(),
        ),
      ),
      GoRoute(
        path: utils,
        name: 'utils',
        pageBuilder: (context, state) {
          final initialTab = state.extra is int ? state.extra as int : 0;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: UtilsScreen(initialTab: initialTab),
          );
        },
      ),
    ],
  );

  static Page<dynamic> _buildPageWithTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}
