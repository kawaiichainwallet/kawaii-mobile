import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/router/app_router.dart';

class KawaiiWalletApp extends ConsumerWidget {
  const KawaiiWalletApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'KawaiiChain Wallet',
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // TODO: 从状态管理中读取

      // Router Configuration
      routerConfig: router,

      // Localization
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],

      // System UI Configuration
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        final isDark = brightness == Brightness.dark;

        // 设置状态栏样式
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
        );

        return child!;
      },
    );
  }
}