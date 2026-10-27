import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/services/api_service.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/job_list_screen.dart';
import '../screens/job_details_screen.dart';
import '../screens/search_screen.dart';
import '../screens/saved_jobs_screen.dart';
import '../screens/applications_screen.dart';
import '../models/user_model.dart';
import '../screens/profile_screen.dart';
import '../screens/edit_profile_screen.dart';

/// AppRouter centralizes all navigation using GoRouter.
///
/// In an interview or viva, you can explain:
/// "GoRouter provides declarative routing, URL parsing, deep linking,
/// and guards that prevent unauthenticated users from accessing protected screens."
class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/jobs',
        name: 'jobs',
        builder: (context, state) => const JobListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'job_details',
            builder: (context, state) {
              final idStr = state.pathParameters['id'] ?? '1';
              final id = int.tryParse(idStr) ?? 1;
              return JobDetailsScreen(jobId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/saved-jobs',
        name: 'saved_jobs',
        builder: (context, state) => const SavedJobsScreen(),
      ),
      GoRoute(
        path: '/applications',
        name: 'applications',
        builder: (context, state) => const ApplicationsScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            name: 'edit_profile',
            builder: (context, state) =>
                EditProfileScreen(initialUser: state.extra as UserModel?),
          ),
        ],
      ),
    ],

    // Route guard: Protect private screens if user does not have a token
    redirect: (context, state) async {
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/';

      if (isAuthRoute) return null;

      final hasToken = await ApiService().hasToken();
      if (!hasToken) {
        return '/login';
      }

      return null;
    },
  );
}
