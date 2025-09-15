import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/presentation/screens/auth_selection_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/otp_verification_screen.dart';
import '../features/auth/presentation/screens/password_setup_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../shared/providers/auth_provider.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: _handleRedirect,
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthSelectionScreen(),
        routes: [
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
            path: '/otp-verification',
            name: 'otp-verification',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return OTPVerificationScreen(
                phoneNumber: extra?['phoneNumber'] ?? '',
                email: extra?['email'] ?? '',
                verificationType: extra?['type'] ?? 'register',
              );
            },
          ),
          GoRoute(
            path: '/password-setup',
            name: 'password-setup',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return PasswordSetupScreen(
                phoneNumber: extra?['phoneNumber'] ?? '',
                email: extra?['email'] ?? '',
              );
            },
          ),
          GoRoute(
            path: '/forgot-password',
            name: 'forgot-password',
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
        ],
      ),

      // Main App Routes (After Authentication)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Home Screen - Coming Soon'),
          ),
        ),
      ),
    ],
  );

  // Route Guard - Handle Authentication Redirects
  static String? _handleRedirect(BuildContext context, GoRouterState state) {
    final authProvider = context.read<AuthProvider>();
    final location = state.matchedLocation;

    // If user is not authenticated and trying to access protected routes
    if (!authProvider.isAuthenticated && location.startsWith('/home')) {
      return '/auth';
    }

    // If user is authenticated and trying to access auth routes
    if (authProvider.isAuthenticated &&
        (location.startsWith('/auth') || location == '/splash' || location == '/onboarding')) {
      return '/home';
    }

    // Allow access to the requested route
    return null;
  }
}