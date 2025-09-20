import '../storage/secure_storage_service.dart';
import '../utils/logger.dart';
import 'api_client.dart';

class AuthApi {
  final ApiClient _apiClient = ApiClient.instance;
  final SecureStorageService _secureStorage = SecureStorageService();
  final AppLogger _logger = AppLogger();

  static AuthApi? _instance;

  static AuthApi get instance {
    _instance ??= AuthApi._internal();
    return _instance!;
  }

  AuthApi._internal();

  /// 用户名/邮箱/手机号 + 密码登录
  Future<R<LoginResponse>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _apiClient.login(
        identifier: identifier,
        password: password,
      );

      if (response.success && response.data != null) {
        await _saveTokens(response.data!);
      }

      return response;
    } catch (e) {
      _logger.error('登录失败: $e');
      rethrow;
    }
  }

  /// 手机验证码登录
  Future<R<LoginResponse>> loginWithOtp({
    required String phone,
    required String otpCode,
  }) async {
    try {
      final response = await _apiClient.loginWithOtp(
        phone: phone,
        otpCode: otpCode,
      );

      if (response.success && response.data != null) {
        await _saveTokens(response.data!);
      }

      return response;
    } catch (e) {
      _logger.error('OTP登录失败: $e');
      rethrow;
    }
  }

  /// 发送登录验证码
  Future<R<void>> sendLoginOtp({
    required String phone,
  }) async {
    return _apiClient.sendLoginOtp(phone: phone);
  }

  /// 刷新Token
  Future<R<LoginResponse>> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        throw ApiException(
          message: 'Refresh Token不存在',
          code: 'REFRESH_TOKEN_NOT_FOUND',
        );
      }

      final response = await _apiClient.refreshToken(
        refreshToken: refreshToken,
      );

      if (response.success && response.data != null) {
        await _saveTokens(response.data!);
      }

      return response;
    } catch (e) {
      _logger.error('刷新Token失败: $e');
      await logout();
      rethrow;
    }
  }

  /// 用户登出
  Future<void> logout() async {
    try {
      // 调用服务端登出接口
      await _apiClient.logout();
    } catch (e) {
      _logger.error('服务端登出失败: $e');
      // 即使服务端登出失败，也要清除本地Token
    } finally {
      // 清除本地存储的Token
      await _secureStorage.clearAll();
    }
  }

  /// 检查用户是否已登录
  Future<bool> isLoggedIn() async {
    final accessToken = await _secureStorage.getAccessToken();
    return accessToken != null;
  }

  /// 获取当前用户的访问Token
  Future<String?> getAccessToken() async {
    return _secureStorage.getAccessToken();
  }

  /// 获取当前用户的刷新Token
  Future<String?> getRefreshToken() async {
    return _secureStorage.getRefreshToken();
  }

  /// 保存登录Token到安全存储
  Future<void> _saveTokens(LoginResponse loginResponse) async {
    await _secureStorage.setAccessToken(loginResponse.accessToken);
    await _secureStorage.setRefreshToken(loginResponse.refreshToken);
    await _secureStorage.setUserId(loginResponse.userId);
    await _secureStorage.setUsername(loginResponse.username);

    _logger.info('Token保存成功: userId=${loginResponse.userId}');
  }

  /// 获取当前用户ID
  Future<String?> getCurrentUserId() async {
    return _secureStorage.getUserId();
  }

  /// 获取当前用户名
  Future<String?> getCurrentUsername() async {
    return _secureStorage.getUsername();
  }

  /// 验证Token是否有效
  Future<bool> validateToken() async {
    try {
      final response = await _apiClient.validateToken();
      return response.success;
    } catch (e) {
      _logger.error('Token验证失败: $e');
      return false;
    }
  }
}