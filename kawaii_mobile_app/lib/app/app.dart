import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'routes.dart';
import 'theme.dart';
import '../shared/providers/auth_provider.dart';
import '../shared/providers/theme_provider.dart';

class KawaiiWalletApp extends StatelessWidget {
  const KawaiiWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'KawaiiChain Wallet',
            debugShowCheckedModeBanner: false,

            // Theme Configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // Router Configuration
            routerConfig: AppRouter.router,

            // Localization
            supportedLocales: const [
              Locale('zh', 'CN'),
              Locale('en', 'US'),
            ],

            // System UI Configuration
            builder: (context, child) {
              // 设置状态栏样式
              SystemChrome.setSystemUIOverlayStyle(
                SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: themeProvider.isDarkMode
                      ? Brightness.light
                      : Brightness.dark,
                  systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
                  systemNavigationBarIconBrightness: themeProvider.isDarkMode
                      ? Brightness.light
                      : Brightness.dark,
                ),
              );

              return child!;
            },
          );
        },
      ),
    );
  }
}