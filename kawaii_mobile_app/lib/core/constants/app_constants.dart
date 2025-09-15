class AppConstants {
  // App Information
  static const String appName = 'KawaiiChain Wallet';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://api.kawaii.com/v1';
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Authentication
  static const int otpLength = 6;
  static const int otpExpireTime = 300; // 5 minutes in seconds
  static const int maxLoginAttempts = 5;
  static const int lockoutDuration = 900; // 15 minutes in seconds

  // Password Requirements
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const String passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';

  // PIN Code
  static const int pinCodeLength = 6;
  static const int maxPinAttempts = 3;

  // Validation Patterns
  static const String phonePattern = r'^1[3-9]\d{9}$';
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 16.0;

  static const double defaultElevation = 2.0;
  static const double smallElevation = 1.0;
  static const double largeElevation = 4.0;

  // Animation Durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);

  // Local Storage Keys
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String pinEnabledKey = 'pin_enabled';

  // Feature Flags
  static const bool enableBiometric = true;
  static const bool enableSocialLogin = true;
  static const bool enableDarkMode = true;
  static const bool enableNotifications = true;

  // Wallet Constants
  static const int maxWalletAccounts = 10;
  static const List<String> supportedCurrencies = ['BTC', 'ETH', 'USDT'];

  // Transaction Limits (in cents)
  static const int minTransactionAmount = 100; // $1.00
  static const int maxDailyTransactionAmount = 1000000; // $10,000.00
  static const int maxMonthlyTransactionAmount = 10000000; // $100,000.00

  // Error Messages
  static const String networkErrorMessage = '网络连接失败，请检查网络设置';
  static const String serverErrorMessage = '服务器错误，请稍后重试';
  static const String unknownErrorMessage = '未知错误，请联系客服';
  static const String validationErrorMessage = '输入信息有误，请检查后重试';

  // Success Messages
  static const String registrationSuccessMessage = '注册成功，欢迎使用KawaiiChain钱包';
  static const String loginSuccessMessage = '登录成功';
  static const String passwordResetSuccessMessage = '密码重置成功';
  static const String otpSentSuccessMessage = '验证码已发送';

  // Contact Information
  static const String supportEmail = 'support@kawaii.com';
  static const String supportPhone = '+86 400-123-4567';
  static const String websiteUrl = 'https://kawaii.com';
  static const String privacyPolicyUrl = 'https://kawaii.com/privacy';
  static const String termsOfServiceUrl = 'https://kawaii.com/terms';
}