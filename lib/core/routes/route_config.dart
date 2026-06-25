import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quizlett/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:quizlett/src/features/auth/presentation/screens/auth_screen.dart';
import 'package:quizlett/src/features/home/presentation/screens/home_screen.dart';
import 'package:quizlett/src/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:quizlett/src/features/profile/presentation/screens/profile_screen.dart';
import 'package:quizlett/src/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:quizlett/src/features/quiz/presentation/screens/results_screen.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      notifyListeners();
    });
  }
}

class RouteConfig {
  final Ref _ref;

  RouteConfig(this._ref);

  late final GoRouter goRouter = GoRouter(
    initialLocation: '/',
    refreshListenable: RouterNotifier(_ref),
    redirect: (context, state) {
      final authState = _ref.read(authControllerProvider);
      final isAuthenticated = authState is Authenticated;
      final isAuthRoute = state.matchedLocation == '/auth';

      if (!isAuthenticated && !isAuthRoute) {
        return '/auth';
      }
      if (isAuthenticated && isAuthRoute) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.leaderboard_outlined),
                  selectedIcon: Icon(Icons.leaderboard_rounded),
                  label: 'Leaderboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/leaderboard',
                builder: (context, state) => const LeaderboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/quiz/:categoryId',
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId'] ?? '';
          return QuizScreen(categoryId: categoryId);
        },
      ),
      GoRoute(
        path: '/quiz-results',
        builder: (context, state) => const ResultsScreen(),
      ),
    ],
  );
}
