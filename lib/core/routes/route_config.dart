import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quizlett/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:quizlett/src/features/auth/presentation/screens/auth_screen.dart';
import 'package:quizlett/src/features/home/presentation/screens/home_screen.dart';
import 'package:quizlett/src/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:quizlett/src/features/profile/presentation/screens/profile_screen.dart';
import 'package:quizlett/src/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:quizlett/src/features/quiz/presentation/screens/results_screen.dart';

class RouteConfig {
  final Ref _ref;

  RouteConfig(this._ref);

  late final GoRouter goRouter = GoRouter(
    initialLocation: '/',
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
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
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
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
