import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/history_screen.dart';
import '../features/home_screen.dart';
import '../features/login_screen.dart';
import '../features/profile_screen.dart';
import '../features/shell_navigation_screen.dart';
import '../services/attendance_store.dart';
import 'route_names.dart';

class AppRouter {
  const AppRouter._();

  static GoRouter createRouter({
    required AttendanceStore store,
    required bool isLoggedIn,
    required VoidCallback onLoginSuccess,
    required VoidCallback onLogout,
  }) {
    final shellNavigatorKey = GlobalKey<NavigatorState>();

    return GoRouter(
      initialLocation: isLoggedIn ? RouteNames.home.path : RouteNames.login.path,
      redirect: (context, state) async {
        final isLoginPage = state.matchedLocation == RouteNames.login.path;

        if (!isLoggedIn && !isLoginPage) {
          return RouteNames.login.path;
        }

        if (isLoggedIn && isLoginPage) {
          return RouteNames.home.path;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: RouteNames.login.path,
          name: 'login',
          builder: (context, state) => LoginScreen(
            onLoginSuccess: onLoginSuccess,
          ),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return ShellNavigationScreen(
              navigationShell: navigationShell,
              onLogout: onLogout,
            );
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.home.path,
                  name: 'home',
                  builder: (context, state) => HomeScreen(store: store),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.history.path,
                  name: 'history',
                  builder: (context, state) => HistoryScreen(store: store),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.profile.path,
                  name: 'profile',
                  builder: (context, state) => ProfileScreen(
                    onLogout: onLogout,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
