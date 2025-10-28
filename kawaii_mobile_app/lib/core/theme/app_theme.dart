import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 应用主题配置
///
/// 设计原则：
/// 1. 现代简洁 - Material 3 设计语言
/// 2. 品牌一致性 - Kawaii 品牌色
/// 3. 可访问性 - WCAG AA 标准
/// 4. 深浅主题 - 支持日夜间模式
class AppTheme {
  // ==================== 品牌颜色 ====================

  /// 主色 - 可爱粉色（Kawaii Pink）
  static const Color primaryColor = Color(0xFFFF6B9D);
  static const Color primaryLight = Color(0xFFFFABCD);
  static const Color primaryDark = Color(0xFFE91E63);

  /// 次级色 - 淡紫色
  static const Color secondaryColor = Color(0xFF9C27B0);
  static const Color secondaryLight = Color(0xFFCE93D8);
  static const Color secondaryDark = Color(0xFF6A1B9A);

  /// 强调色 - 活力橙
  static const Color accentColor = Color(0xFFFF9800);

  // ==================== 功能颜色 ====================

  /// 成功色
  static const Color successColor = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  /// 警告色
  static const Color warningColor = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  /// 错误色
  static const Color errorColor = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);

  /// 信息色
  static const Color infoColor = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // ==================== 中性颜色 ====================

  /// 文字颜色
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textHint = Color(0xFF9E9E9E);

  /// 背景颜色
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  /// 分割线颜色
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);

  // ==================== 资产涨跌颜色 ====================

  /// 上涨（绿色）- 遵循国际惯例
  static const Color priceUp = Color(0xFF4CAF50);

  /// 下跌（红色）
  static const Color priceDown = Color(0xFFF44336);

  // ==================== 间距系统 ====================

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacing2xl = 48.0;

  // ==================== 圆角系统 ====================

  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // ==================== 阴影 ====================

  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // ==================== 浅色主题 ====================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // 颜色方案
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      primaryContainer: primaryLight,
      secondary: secondaryColor,
      secondaryContainer: secondaryLight,
      error: errorColor,
      surface: surfaceLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
      onSurface: textPrimary,
    ),

    // 脚手架背景色
    scaffoldBackgroundColor: backgroundLight,

    // AppBar 主题
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: surfaceLight,
      foregroundColor: textPrimary,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // 卡片主题
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        side: BorderSide(color: dividerLight, width: 1),
      ),
      color: surfaceLight,
    ),

    // 输入框主题
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: dividerLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: dividerLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingMd,
        vertical: spacingMd,
      ),
    ),

    // 按钮主题
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        side: const BorderSide(color: primaryColor),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // 底部导航栏主题
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: surfaceLight,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),

    // 分割线主题
    dividerTheme: const DividerThemeData(
      color: dividerLight,
      thickness: 1,
      space: 1,
    ),

    // 字体
    fontFamily: 'Roboto',

    // 文字主题
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
      titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: textPrimary),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textPrimary),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: textSecondary),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: textHint),
    ),
  );

  // ==================== 深色主题 ====================

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: primaryLight,
      primaryContainer: primaryDark,
      secondary: secondaryLight,
      secondaryContainer: secondaryDark,
      error: errorLight,
      surface: surfaceDark,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onError: Colors.black,
      onSurface: Colors.white,
    ),

    scaffoldBackgroundColor: backgroundDark,

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: surfaceDark,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        side: BorderSide(color: dividerDark, width: 1),
      ),
      color: surfaceDark,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: surfaceDark,
      selectedItemColor: primaryLight,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),

    dividerTheme: const DividerThemeData(
      color: dividerDark,
      thickness: 1,
      space: 1,
    ),

    fontFamily: 'Roboto',
  );
}
