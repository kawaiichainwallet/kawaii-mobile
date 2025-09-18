import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/utils/logger.dart';
import '../../core/api/api_client.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

enum RegisterStep {
  selectMethod,    // 选择注册方式
  inputInfo,       // 输入手机号/邮箱
  verifyOtp,       // 验证OTP
  setPassword,     // 设置密码
  completed        // 注册完成
}

enum RegisterMethod {
  phone,          // 手机号注册
  email           // 邮箱注册
}

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  bool _rememberMe = false;

  // Services
  final SecureStorageService _secureStorage = SecureStorageService();
  final AppLogger _logger = AppLogger();
  final ApiClient _apiClient = ApiClient.instance;

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get rememberMe => _rememberMe;

  // Initialize authentication state
  Future<void> initialize() async {
    try {
      _setStatus(AuthStatus.loading);

      // Check if user has valid token
      final token = await _secureStorage.getAccessToken();
      if (token != null) {
        // Validate token and get user info
        await _validateTokenAndGetUser(token);
      } else {
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      _logger.error('Failed to initialize auth: $e');
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  // Register with phone number
  Future<bool> registerWithPhone({
    required String phoneNumber,
    required String verificationCode,
    required String username,
    required String password,
    required String confirmPassword,
    required bool agreeToTerms,
  }) async {
    try {
      _setStatus(AuthStatus.loading);

      final response = await _apiClient.registerWithOtp(
        target: phoneNumber,
        type: 'phone',
        otpCode: verificationCode,
        username: username,
        password: password,
        confirmPassword: confirmPassword,
        agreeToTerms: agreeToTerms,
      );

      if (response.success && response.data != null) {
        final registerData = response.data!;

        // 保存认证数据
        await _saveAuthData(registerData.accessToken, registerData.refreshToken);

        // 获取用户信息
        await _fetchUserInfo();

        _setStatus(AuthStatus.authenticated);
        _logger.info('User registered successfully with phone: $phoneNumber');
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } on ApiException catch (e) {
      _setError('注册失败：${e.message}');
      return false;
    } catch (e) {
      _setError('注册失败：$e');
      return false;
    }
  }

  // Register with email
  Future<bool> registerWithEmail({
    required String email,
    required String verificationCode,
    required String username,
    required String password,
    required String confirmPassword,
    required bool agreeToTerms,
  }) async {
    try {
      _setStatus(AuthStatus.loading);

      final response = await _apiClient.registerWithOtp(
        target: email,
        type: 'email',
        otpCode: verificationCode,
        username: username,
        password: password,
        confirmPassword: confirmPassword,
        agreeToTerms: agreeToTerms,
      );

      if (response.success && response.data != null) {
        final registerData = response.data!;

        // 保存认证数据
        await _saveAuthData(registerData.accessToken, registerData.refreshToken);

        // 获取用户信息
        await _fetchUserInfo();

        _setStatus(AuthStatus.authenticated);
        _logger.info('User registered successfully with email: $email');
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } on ApiException catch (e) {
      _setError('注册失败：${e.message}');
      return false;
    } catch (e) {
      _setError('注册失败：$e');
      return false;
    }
  }

  // Login with credentials
  Future<bool> login({
    required String identifier, // phone or email
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      _setStatus(AuthStatus.loading);
      _rememberMe = rememberMe;

      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // For demo purposes, validate basic credentials
      if (password.length < 6) {
        throw Exception('密码错误');
      }

      _user = UserModel(
        id: '1',
        phoneNumber: identifier.contains('@') ? null : identifier,
        email: identifier.contains('@') ? identifier : null,
        isPhoneVerified: true,
        isEmailVerified: true,
        kycLevel: KYCLevel.level2,
        createdAt: DateTime.now(),
      );

      await _saveAuthData('mock_access_token', 'mock_refresh_token');

      _setStatus(AuthStatus.authenticated);
      _logger.info('User logged in successfully: $identifier');
      return true;
    } catch (e) {
      _setError('登录失败：$e');
      return false;
    }
  }

  // Quick login with OTP
  Future<bool> quickLoginWithOTP({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      _setStatus(AuthStatus.loading);

      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 2));

      _user = UserModel(
        id: '1',
        phoneNumber: phoneNumber,
        email: null,
        isPhoneVerified: true,
        isEmailVerified: false,
        kycLevel: KYCLevel.level2,
        createdAt: DateTime.now(),
      );

      await _saveAuthData('mock_access_token', 'mock_refresh_token');

      _setStatus(AuthStatus.authenticated);
      _logger.info('User logged in with OTP: $phoneNumber');
      return true;
    } catch (e) {
      _setError('验证码登录失败：$e');
      return false;
    }
  }

  // Send verification code
  Future<bool> sendVerificationCode({
    required String target, // phone or email
    required String targetType, // 'phone' or 'email'
    required String purpose, // 'register', 'login', 'reset_password'
  }) async {
    try {
      final response = await _apiClient.sendOtp(
        target: target,
        type: targetType,
        purpose: purpose,
      );

      if (response.success) {
        _logger.info('Verification code sent to: $target for $purpose');
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } on ApiException catch (e) {
      _setError('发送验证码失败：${e.message}');
      return false;
    } catch (e) {
      _setError('发送验证码失败：$e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _setStatus(AuthStatus.loading);

      // Clear stored data
      await _secureStorage.clearAll();
      await _clearPreferences();

      _user = null;
      _setStatus(AuthStatus.unauthenticated);
      _logger.info('User logged out');
    } catch (e) {
      _logger.error('Logout error: $e');
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String identifier,
    required String verificationCode,
    required String newPassword,
  }) async {
    try {
      _setStatus(AuthStatus.loading);

      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 2));

      _logger.info('Password reset for: $identifier');
      return true;
    } catch (e) {
      _setError('重置密码失败：$e');
      return false;
    } finally {
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  // Private methods
  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _status = AuthStatus.error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _validateTokenAndGetUser(String token) async {
    try {
      await _fetchUserInfo();
      _setStatus(AuthStatus.authenticated);
    } catch (e) {
      _logger.error('Token validation failed: $e');
      await _secureStorage.clearAll();
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  Future<void> _fetchUserInfo() async {
    try {
      final response = await _apiClient.getUserInfo();

      if (response.success && response.data != null) {
        final userInfo = response.data!;

        _user = UserModel(
          id: userInfo.userId,
          username: userInfo.username,
          phoneNumber: userInfo.phoneNumber,
          email: userInfo.email,
          isPhoneVerified: userInfo.isPhoneVerified,
          isEmailVerified: userInfo.isEmailVerified,
          kycLevel: _mapKycLevel(userInfo.kycLevel),
          createdAt: userInfo.createdAt,
        );
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _logger.error('Failed to fetch user info: $e');
      rethrow;
    }
  }

  KYCLevel _mapKycLevel(String level) {
    switch (level.toUpperCase()) {
      case 'LEVEL_1':
        return KYCLevel.level1;
      case 'LEVEL_2':
        return KYCLevel.level2;
      case 'LEVEL_3':
        return KYCLevel.level3;
      default:
        return KYCLevel.level1;
    }
  }

  Future<void> _saveAuthData(String accessToken, String refreshToken) async {
    await _secureStorage.setAccessToken(accessToken);
    await _secureStorage.setRefreshToken(refreshToken);

    if (_rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', true);
    }
  }

  Future<void> _clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}