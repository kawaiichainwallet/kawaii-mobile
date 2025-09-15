import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/utils/logger.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  bool _rememberMe = false;

  // Services
  final SecureStorageService _secureStorage = SecureStorageService();
  final AppLogger _logger = AppLogger();

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
    required String password,
    required String transactionPassword,
  }) async {
    try {
      _setStatus(AuthStatus.loading);

      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // For demo purposes, create a mock user
      _user = UserModel(
        id: '1',
        phoneNumber: phoneNumber,
        email: null,
        isPhoneVerified: true,
        isEmailVerified: false,
        kycLevel: KYCLevel.level1,
        createdAt: DateTime.now(),
      );

      // Save authentication data
      await _saveAuthData('mock_access_token', 'mock_refresh_token');

      _setStatus(AuthStatus.authenticated);
      _logger.info('User registered successfully with phone: $phoneNumber');
      return true;
    } catch (e) {
      _setError('注册失败：$e');
      return false;
    }
  }

  // Register with email
  Future<bool> registerWithEmail({
    required String email,
    required String verificationCode,
    required String password,
    required String transactionPassword,
  }) async {
    try {
      _setStatus(AuthStatus.loading);

      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      _user = UserModel(
        id: '1',
        phoneNumber: null,
        email: email,
        isPhoneVerified: false,
        isEmailVerified: true,
        kycLevel: KYCLevel.level1,
        createdAt: DateTime.now(),
      );

      await _saveAuthData('mock_access_token', 'mock_refresh_token');

      _setStatus(AuthStatus.authenticated);
      _logger.info('User registered successfully with email: $email');
      return true;
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
    required String type, // 'register', 'login', 'forgot_password'
  }) async {
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 1));

      _logger.info('Verification code sent to: $target for $type');
      return true;
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
      // TODO: Implement token validation API call
      await Future.delayed(const Duration(seconds: 1));

      // For demo, create mock user
      _user = UserModel(
        id: '1',
        phoneNumber: '+86 138****8888',
        email: 'user@example.com',
        isPhoneVerified: true,
        isEmailVerified: true,
        kycLevel: KYCLevel.level2,
        createdAt: DateTime.now(),
      );

      _setStatus(AuthStatus.authenticated);
    } catch (e) {
      await _secureStorage.clearAll();
      _setStatus(AuthStatus.unauthenticated);
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