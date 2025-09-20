import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/utils/logger.dart';
import '../../core/api/api_client.dart';
import '../../core/api/auth_api.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/encryption_service.dart';

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
  final AuthApi _authApi = AuthApi.instance;
  final BiometricService _biometricService = BiometricService.instance;
  final EncryptionService _encryptionService = EncryptionService.instance;

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
      final isLoggedIn = await _authApi.isLoggedIn();
      if (isLoggedIn) {
        // Validate token and get user info
        final isValid = await _authApi.validateToken();
        if (isValid) {
          await _fetchUserInfo();
          _setStatus(AuthStatus.authenticated);
        } else {
          // Token 无效，尝试刷新
          try {
            await _authApi.refreshToken();
            await _fetchUserInfo();
            _setStatus(AuthStatus.authenticated);
          } catch (e) {
            _logger.error('Token refresh failed during initialization: $e');
            await _authApi.logout();
            _setStatus(AuthStatus.unauthenticated);
          }
        }
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

        // 保存记住我偏好
        await _saveRememberMePreference();

        // 获取用户信息
        await _fetchUserInfo();

        _setStatus(AuthStatus.authenticated);
        _logger.info('User registered successfully with phone: $phoneNumber');
        return true;
      } else {
        _setError(response.msg);
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

        // 保存记住我偏好
        await _saveRememberMePreference();

        // 获取用户信息
        await _fetchUserInfo();

        _setStatus(AuthStatus.authenticated);
        _logger.info('User registered successfully with email: $email');
        return true;
      } else {
        _setError(response.msg);
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
    required String identifier, // phone, email or username
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      _setStatus(AuthStatus.loading);
      _rememberMe = rememberMe;

      final response = await _authApi.login(
        identifier: identifier,
        password: password,
      );

      if (response.success && response.data != null) {
        final loginData = response.data!;

        // 创建用户模型
        _user = UserModel(
          id: loginData.userId,
          username: loginData.username,
          phoneNumber: loginData.phone,
          email: loginData.email,
          isPhoneVerified: loginData.phone != null,
          isEmailVerified: loginData.email != null,
          kycLevel: KYCLevel.level1, // 默认值，可从用户详情获取
          createdAt: DateTime.now(), // 默认值，可从用户详情获取
        );

        // 保存记住我偏好
        await _saveRememberMePreference();

        // 获取完整的用户信息
        try {
          await _fetchUserInfo();
        } catch (e) {
          _logger.error('Failed to fetch complete user info: $e');
          // 不影响登录流程，使用基本信息
        }

        _setStatus(AuthStatus.authenticated);
        _logger.info('User logged in successfully: $identifier');
        return true;
      } else {
        _setError(response.msg);
        return false;
      }
    } on ApiException catch (e) {
      _setError('登录失败：${e.message}');
      return false;
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

      final response = await _authApi.loginWithOtp(
        phone: phoneNumber,
        otpCode: otp,
      );

      if (response.success && response.data != null) {
        final loginData = response.data!;

        // 创建用户模型
        _user = UserModel(
          id: loginData.userId,
          username: loginData.username,
          phoneNumber: loginData.phone,
          email: loginData.email,
          isPhoneVerified: true, // OTP登录说明手机已验证
          isEmailVerified: loginData.email != null,
          kycLevel: KYCLevel.level1, // 默认值，可从用户详情获取
          createdAt: DateTime.now(), // 默认值，可从用户详情获取
        );

        // 获取完整的用户信息
        try {
          await _fetchUserInfo();
        } catch (e) {
          _logger.error('Failed to fetch complete user info: $e');
          // 不影响登录流程，使用基本信息
        }

        _setStatus(AuthStatus.authenticated);
        _logger.info('User logged in with OTP: $phoneNumber');
        return true;
      } else {
        _setError(response.msg);
        return false;
      }
    } on ApiException catch (e) {
      _setError('验证码登录失败：${e.message}');
      return false;
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
      R<void> response;

      if (purpose == 'login' && targetType == 'phone') {
        // 使用专门的登录验证码接口
        response = await _authApi.sendLoginOtp(phone: target);
      } else {
        // 使用通用的OTP接口（注册等）
        response = await _apiClient.sendOtp(
          target: target,
          type: targetType,
          purpose: purpose,
        );
      }

      if (response.success) {
        _logger.info('Verification code sent to: $target for $purpose');
        return true;
      } else {
        _setError(response.msg);
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

      // 调用服务端登出接口
      await _authApi.logout();

      _user = null;
      _setStatus(AuthStatus.unauthenticated);
      _logger.info('User logged out');
    } catch (e) {
      _logger.error('Logout error: $e');
      // 即使服务端登出失败，也要清除本地状态
      _user = null;
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
        throw Exception(response.msg);
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

  Future<void> _saveRememberMePreference() async {
    if (_rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', true);
    }
  }

  Future<void> _clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // 便利方法：检查当前用户ID
  Future<String?> getCurrentUserId() async {
    return _authApi.getCurrentUserId();
  }

  // 便利方法：检查当前用户名
  Future<String?> getCurrentUsername() async {
    return _authApi.getCurrentUsername();
  }

  // 便利方法：检查是否有有效的访问令牌
  Future<bool> hasValidToken() async {
    return _authApi.validateToken();
  }

  // 便利方法：刷新用户信息
  Future<bool> refreshUserInfo() async {
    try {
      await _fetchUserInfo();
      return true;
    } catch (e) {
      _logger.error('Failed to refresh user info: $e');
      return false;
    }
  }

  // 生物识别相关方法

  /// 检查设备是否支持生物识别
  Future<bool> isBiometricSupported() async {
    return _biometricService.isDeviceSupported();
  }

  /// 检查是否可以进行生物识别
  Future<bool> canUseBiometric() async {
    return _biometricService.canCheckBiometrics();
  }

  /// 检查是否已启用生物识别登录
  Future<bool> isBiometricLoginEnabled() async {
    return _biometricService.isBiometricLoginEnabled();
  }

  /// 获取生物识别状态描述
  Future<String> getBiometricStatusDescription() async {
    return _biometricService.getBiometricStatusDescription();
  }

  /// 启用生物识别登录
  Future<bool> enableBiometricLogin({
    required String identifier,
    required String password,
  }) async {
    try {
      _setStatus(AuthStatus.loading);

      // 检查设备支持
      if (!await _biometricService.canCheckBiometrics()) {
        _setError('设备不支持生物识别或未设置生物识别');
        return false;
      }

      // 加密凭据
      final encryptedCredentials = _encryptionService.encryptCredentials(
        identifier: identifier,
        password: password,
      );

      // 启用生物识别登录
      final success = await _biometricService.enableBiometricLogin(
        credentials: encryptedCredentials,
      );

      if (success) {
        _logger.info('生物识别登录已启用');
        notifyListeners();
        return true;
      } else {
        _setError('启用生物识别登录失败');
        return false;
      }
    } catch (e) {
      _setError('启用生物识别登录失败：$e');
      return false;
    } finally {
      if (_status == AuthStatus.loading) {
        _setStatus(AuthStatus.unauthenticated);
      }
    }
  }

  /// 禁用生物识别登录
  Future<void> disableBiometricLogin() async {
    try {
      await _biometricService.disableBiometricLogin();
      _logger.info('生物识别登录已禁用');
      notifyListeners();
    } catch (e) {
      _logger.error('禁用生物识别登录失败: $e');
    }
  }

  /// 生物识别登录
  Future<bool> loginWithBiometric() async {
    try {
      _setStatus(AuthStatus.loading);

      // 检查是否启用了生物识别登录
      if (!await _biometricService.isBiometricLoginEnabled()) {
        _setError('生物识别登录未启用');
        return false;
      }

      // 进行生物识别认证并获取凭据
      final encryptedCredentials = await _biometricService.authenticateForLogin();
      if (encryptedCredentials == null) {
        _setError('生物识别认证失败或被取消');
        return false;
      }

      // 解密凭据
      final credentials = _encryptionService.decryptCredentials(encryptedCredentials);
      if (credentials == null) {
        _setError('解密登录凭据失败');
        await _biometricService.disableBiometricLogin(); // 清理无效凭据
        return false;
      }

      final identifier = credentials['identifier'] as String?;
      final password = credentials['password'] as String?;

      if (identifier == null || password == null) {
        _setError('凭据格式无效');
        await _biometricService.disableBiometricLogin(); // 清理无效凭据
        return false;
      }

      // 使用解密的凭据进行登录
      final response = await _authApi.login(
        identifier: identifier,
        password: password,
      );

      if (response.success && response.data != null) {
        final loginData = response.data!;

        // 创建用户模型
        _user = UserModel(
          id: loginData.userId,
          username: loginData.username,
          phoneNumber: loginData.phone,
          email: loginData.email,
          isPhoneVerified: loginData.phone != null,
          isEmailVerified: loginData.email != null,
          kycLevel: KYCLevel.level1, // 默认值，可从用户详情获取
          createdAt: DateTime.now(), // 默认值，可从用户详情获取
        );

        // 获取完整的用户信息
        try {
          await _fetchUserInfo();
        } catch (e) {
          _logger.error('Failed to fetch complete user info: $e');
          // 不影响登录流程，使用基本信息
        }

        _setStatus(AuthStatus.authenticated);
        _logger.info('生物识别登录成功: $identifier');
        return true;
      } else {
        _setError(response.msg);
        // 如果凭据失效，禁用生物识别登录
        if (response.msg.contains('密码') || response.msg.contains('用户')) {
          await _biometricService.disableBiometricLogin();
        }
        return false;
      }
    } on Exception catch (e) {
      _setError('生物识别登录失败：$e');
      return false;
    } catch (e) {
      _setError('生物识别登录失败：$e');
      return false;
    }
  }

  /// 在成功登录后提示用户启用生物识别
  Future<void> promptBiometricSetup({
    required String identifier,
    required String password,
  }) async {
    try {
      // 检查是否已经启用
      if (await _biometricService.isBiometricLoginEnabled()) {
        return;
      }

      // 检查设备支持
      if (!await _biometricService.canCheckBiometrics()) {
        return;
      }

      // 这里可以显示对话框询问用户是否要启用生物识别登录
      // 具体实现可以在UI层处理
      _logger.info('可以提示用户启用生物识别登录');
    } catch (e) {
      _logger.error('检查生物识别设置失败: $e');
    }
  }
}