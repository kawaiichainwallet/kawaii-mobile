import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';

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
      // TODO: Initialize necessary services
      // - Check network connectivity
      // - Load cached data
      // - Initialize encryption service

      // Check if this is the first launch
      await _checkFirstLaunch();
    } catch (e) {
      // Handle initialization error
      if (mounted) {
        _navigateToAuthSelection();
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
      _navigateToAuthSelection();
    }
  }

  void _checkAuthenticationStatus() {
    // TODO: Check if user is logged in
    // For now, always navigate to auth selection
    _navigateToAuthSelection();
  }

  void _navigateToOnboarding() {
    if (mounted) {
      context.go(AppRoutes.onboarding);
    }
  }

  void _navigateToAuthSelection() {
    if (mounted) {
      context.go(AppRoutes.authSelection);
    }
  }

  void _navigateToMain() {
    if (mounted) {
      context.go(AppRoutes.main);
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryLight,
              AppTheme.secondaryColor,
            ],
          ),
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
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      boxShadow: AppTheme.shadowLg,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingXl),

                // App Name Animation
                FadeTransition(
                  opacity: _textAnimation,
                  child: Column(
                    children: [
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        '安全 · 便捷 · 可信赖',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacing2xl),

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
                            Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      Text(
                        '正在加载...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
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