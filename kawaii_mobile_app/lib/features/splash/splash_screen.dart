import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/theme_provider.dart';
import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  final AppLogger _logger = AppLogger();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    _textAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    );

    // Start logo animation
    _logoController.forward();

    // Start text animation after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textController.forward();
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize logger
      AppLogger().initialize();
      _logger.info('App started');

      // Initialize providers
      if (mounted) {
        await context.read<ThemeProvider>().initialize();
      }
      if (mounted) {
        await context.read<AuthProvider>().initialize();
      }

      // Check if this is the first launch
      await _checkFirstLaunch();
    } catch (e) {
      _logger.error('Failed to initialize app: $e');
      // Handle initialization error
      if (mounted) {
        _navigateToAuth();
      }
    }
  }

  Future<void> _checkFirstLaunch() async {
    await Future.delayed(const Duration(seconds: 2)); // Minimum splash duration

    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool(AppConstants.isFirstLaunchKey) ?? true;

      if (isFirstLaunch) {
        // Mark as not first launch
        await prefs.setBool(AppConstants.isFirstLaunchKey, false);
        _navigateToOnboarding();
      } else {
        _checkAuthenticationStatus();
      }
    } catch (e) {
      _logger.error('Failed to check first launch: $e');
      _navigateToAuth();
    }
  }

  void _checkAuthenticationStatus() {
    final authProvider = context.read<AuthProvider>();

    if (authProvider.isAuthenticated) {
      _navigateToHome();
    } else {
      _navigateToAuth();
    }
  }

  void _navigateToOnboarding() {
    if (mounted) {
      context.go('/onboarding');
    }
  }

  void _navigateToAuth() {
    if (mounted) {
      context.go('/auth');
    }
  }

  void _navigateToHome() {
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Animation
                ScaleTransition(
                  scale: _logoAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 10),
                          blurRadius: 30,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 60,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // App Name Animation
                FadeTransition(
                  opacity: _textAnimation,
                  child: Column(
                    children: [
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '安全 · 便捷 · 可信赖',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),

                // Loading Indicator
                FadeTransition(
                  opacity: _textAnimation,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '正在加载...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}