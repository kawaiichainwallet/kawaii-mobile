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
      _logger.info('AuthApi.login() 开始: identifier=$identifier');
      final response = await _apiClient.login(
        identifier: identifier,
        password: password,
      );

      _logger.info('AuthApi.login() 响应: success=${response.success}');

      if (response.success && response.data != null) {
        _logger.info('保存登录 Token...');
        await _saveTokens(response.data!);
        _logger.info('Token 保存成功');
      } else {
        _logger.warning('登录失败: ${response.msg}');
      }

      return response;
    } catch (e, stackTrace) {
      _logger.error('登录失败: $e');
      _logger.error('堆栈: $stackTrace');
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
    _logger.info('开始执行登出操作');

    // 先清除本地存储，确保即使服务端调用失败也能登出
    try {
      _logger.info('清除本地存储...');
      await _secureStorage.clearAll();
      _logger.info('本地存储已清除');
    } catch (e) {
      _logger.error('清除本地存储失败: $e');
      rethrow;
    }

    // 尝试调用服务端登出接口（非关键操作）
    try {
      _logger.info('调用服务端登出接口...');
      await _apiClient.logout().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _logger.warning('服务端登出接口超时');
          return R<void>(success: false, msg: '超时');
        },
      );
      _logger.info('服务端登出成功');
    } catch (e) {
      _logger.error('服务端登出失败: $e');
      // 不抛出异常，因为本地已经清除
    }

    _logger.info('登出操作完成');
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
    await _secureStorage.setUserId(loginResponse.userId.toString());
    await _secureStorage.setUsername(loginResponse.username);

    _logger.info('Token保存成功: userId=${loginResponse.userId}');
  }

  /// 保存注册后的Token到安全存储
  Future<void> saveRegistrationTokens(RegisterResponse registerResponse) async {
    await _secureStorage.setAccessToken(registerResponse.accessToken);
    await _secureStorage.setRefreshToken(registerResponse.refreshToken);
    await _secureStorage.setUserId(registerResponse.userId.toString());
    await _secureStorage.setUsername(registerResponse.username);

    _logger.info('注册Token保存成功: userId=${registerResponse.userId}');
  }

  /// 获取当前用户ID
  Future<int?> getCurrentUserId() async {
    final userIdStr = await _secureStorage.getUserId();
    if (userIdStr == null) return null;
    return int.tryParse(userIdStr);
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