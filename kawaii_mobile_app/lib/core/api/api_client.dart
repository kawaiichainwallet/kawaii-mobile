import 'dart:io';
import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';
import '../utils/logger.dart';
import '../config/api_config.dart';

class ApiClient {
  static String get baseUrl => ApiConfig.baseUrl;

  late final Dio _dio;
  final SecureStorageService _secureStorage = SecureStorageService();
  final AppLogger _logger = AppLogger();

  static ApiClient? _instance;

  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  ApiClient._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
      validateStatus: (status) {
        // 接受所有状态码，让我们自己处理
        return status != null && status < 500;
      },
    ));

    // 添加拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 添加授权头
          final token = await _secureStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (ApiConfig.enableLogging) {
            _logger.info('Request: ${options.method} ${options.uri}');
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (ApiConfig.enableLogging) {
            _logger.info('Response: ${response.statusCode} ${response.requestOptions.uri}');
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (ApiConfig.enableLogging) {
            _logger.error('API Error: ${error.requestOptions.method} ${error.requestOptions.uri} - ${error.message}');
          }

          // 处理 token 过期
          if (error.response?.statusCode == 401) {
            await _handleTokenExpiry();
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<void> _handleTokenExpiry() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null) {
        // 尝试刷新 token
        final response = await _dio.post('/kawaii-user/auth/refresh', data: {
          'refreshToken': refreshToken,
        });

        if (response.statusCode == 200) {
          final loginResponse = LoginResponse.fromJson(response.data['data']);

          await _secureStorage.setAccessToken(loginResponse.accessToken);
          await _secureStorage.setRefreshToken(loginResponse.refreshToken);
        }
      } else {
        // 清除所有 token，用户需要重新登录
        await _secureStorage.clearAll();
      }
    } catch (e) {
      _logger.error('Token refresh failed: $e');
      await _secureStorage.clearAll();
    }
  }

  // 通用请求方法
  Future<R<T>> request<T>(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      _logger.info('ApiClient.request() 开始: $method $endpoint');
      _logger.info('请求数据: $data');
      _logger.info('查询参数: $queryParameters');

      late Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(endpoint, queryParameters: queryParameters);
          break;
        case 'POST':
          _logger.info('执行 POST 请求...');
          response = await _dio.post(endpoint, data: data, queryParameters: queryParameters);
          _logger.info('POST 请求完成，状态码: ${response.statusCode}');
          break;
        case 'PUT':
          response = await _dio.put(endpoint, data: data, queryParameters: queryParameters);
          break;
        case 'DELETE':
          response = await _dio.delete(endpoint, queryParameters: queryParameters);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      _logger.info('响应数据: ${response.data}');

      return R<T>.fromJson(
        response.data,
        fromJson: fromJson,
      );
    } on DioException catch (e) {
      _logger.error('DioException: ${e.type}, message: ${e.message}');
      _logger.error('Response: ${e.response?.data}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      _logger.error('Unknown error: $e');
      throw ApiException(
        message: '网络请求失败: $e',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  // 用户相关 API (kawaii-user 服务)
  Future<R<void>> sendOtp({
    required String target,
    required String type,
    required String purpose,
  }) async {
    return request<void>(
      '/kawaii-user/auth/send-register-otp',
      method: 'POST',
      data: {
        'target': target,
        'type': type,
        'purpose': purpose,
      },
    );
  }

  Future<R<Map<String, dynamic>>> verifyOtp({
    required String target,
    required String type,
    required String otpCode,
    required String purpose,
  }) async {
    return request<Map<String, dynamic>>(
      '/kawaii-user/auth/verify-otp',
      method: 'POST',
      data: {
        'target': target,
        'type': type,
        'otpCode': otpCode,
        'purpose': purpose,
      },
    );
  }

  Future<R<RegisterResponse>> registerWithOtp({
    required String target,
    required String type,
    required String verificationToken,
    required String username,
    required String password,
    required String confirmPassword,
    required bool agreeToTerms,
  }) async {
    return request<RegisterResponse>(
      '/kawaii-user/auth/register',
      method: 'POST',
      data: {
        'target': target,
        'type': type,
        'verificationToken': verificationToken,
        'username': username,
        'password': password,
        'confirmPassword': confirmPassword,
        'agreeToTerms': agreeToTerms,
      },
      fromJson: (json) => RegisterResponse.fromJson(json),
    );
  }

  Future<R<UserInfoResponse>> getUserInfo() async {
    return request<UserInfoResponse>(
      '/kawaii-user/users/profile',
      fromJson: (json) => UserInfoResponse.fromJson(json),
    );
  }

  Future<R<UserInfoResponse>> updateUserInfo({
    required Map<String, dynamic> userData,
  }) async {
    return request<UserInfoResponse>(
      '/kawaii-user/users/profile',
      method: 'PUT',
      data: userData,
      fromJson: (json) => UserInfoResponse.fromJson(json),
    );
  }

  Future<R<String>> healthCheck() async {
    return request<String>('/kawaii-user/health');
  }

  // 认证相关 API (集成在kawaii-user服务中)
  Future<R<LoginResponse>> login({
    required String identifier,
    required String password,
  }) async {
    return request<LoginResponse>(
      '/kawaii-user/auth/login',
      method: 'POST',
      data: {
        'identifier': identifier,
        'password': password,
      },
      fromJson: (json) => LoginResponse.fromJson(json),
    );
  }

  Future<R<LoginResponse>> loginWithOtp({
    required String phone,
    required String otpCode,
  }) async {
    return request<LoginResponse>(
      '/kawaii-user/auth/login/otp',
      method: 'POST',
      data: {
        'phone': phone,
        'otpCode': otpCode,
      },
      fromJson: (json) => LoginResponse.fromJson(json),
    );
  }

  Future<R<void>> sendLoginOtp({
    required String phone,
  }) async {
    return request<void>(
      '/kawaii-user/auth/send-login-otp',
      method: 'POST',
      data: {
        'target': phone,
        'type': 'phone',
        'purpose': 'login',
      },
    );
  }

  Future<R<LoginResponse>> refreshToken({
    required String refreshToken,
  }) async {
    return request<LoginResponse>(
      '/kawaii-user/auth/refresh',
      method: 'POST',
      data: {
        'refreshToken': refreshToken,
      },
      fromJson: (json) => LoginResponse.fromJson(json),
    );
  }

  Future<R<void>> logout() async {
    return request<void>(
      '/kawaii-user/auth/logout',
      method: 'POST',
    );
  }

  // Token验证 API
  Future<R<Map<String, dynamic>>> validateToken() async {
    return request<Map<String, dynamic>>(
      '/kawaii-user/auth/validate',
      method: 'GET',
    );
  }
}

// API 响应包装类
class R<T> {
  final bool success;
  final String msg;
  final T? data;
  final String? timestamp;
  final String? traceId;

  R({
    required this.success,
    required this.msg,
    this.data,
    this.timestamp,
    this.traceId,
  });

  factory R.fromJson(
    Map<String, dynamic> json, {
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    T? data;

    if (json['data'] != null && fromJson != null) {
      if (json['data'] is Map<String, dynamic>) {
        data = fromJson(json['data']);
      } else {
        data = json['data'];
      }
    } else {
      data = json['data'];
    }

    // 通过code判断是否成功（200表示成功）
    final bool success = (json['code'] == 200);

    return R<T>(
      success: success,
      msg: json['msg'] ?? json['message'] ?? '',
      data: data,
      timestamp: json['timestamp'],
      traceId: json['traceId'],
    );
  }
}

// API 异常类
class ApiException implements Exception {
  final String message;
  final String code;
  final int? statusCode;

  ApiException({
    required this.message,
    required this.code,
    this.statusCode,
  });

  factory ApiException.fromDioError(DioException error) {
    String message = '网络请求失败';
    String code = 'NETWORK_ERROR';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = '连接超时';
        code = 'CONNECTION_TIMEOUT';
        break;
      case DioExceptionType.sendTimeout:
        message = '发送超时';
        code = 'SEND_TIMEOUT';
        break;
      case DioExceptionType.receiveTimeout:
        message = '接收超时';
        code = 'RECEIVE_TIMEOUT';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // 客户端错误
            if (error.response?.data != null && error.response?.data is Map) {
              message = error.response?.data['msg'] ?? error.response?.data['message'] ?? '请求错误';
              code = error.response?.data['code'] ?? 'CLIENT_ERROR';
            } else {
              message = '请求错误';
              code = 'CLIENT_ERROR';
            }
          } else if (statusCode >= 500) {
            // 服务器错误
            message = '服务器错误';
            code = 'SERVER_ERROR';
          }
        }
        break;
      case DioExceptionType.cancel:
        message = '请求已取消';
        code = 'REQUEST_CANCELLED';
        break;
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          message = '网络连接失败';
          code = 'NETWORK_CONNECTION_FAILED';
        } else {
          message = '未知错误';
          code = 'UNKNOWN_ERROR';
        }
        break;
      default:
        message = '网络请求失败';
        code = 'NETWORK_ERROR';
    }

    return ApiException(
      message: message,
      code: code,
      statusCode: error.response?.statusCode,
    );
  }

  @override
  String toString() {
    return 'ApiException: $message (code: $code, statusCode: $statusCode)';
  }
}

// 响应数据模型
class RegisterResponse {
  final int userId;
  final String username;
  final String? phone;  // 可选字段
  final String? email;  // 可选字段
  final String accessToken;
  final String refreshToken;
  final int expiresIn;  // 过期秒数，不是时间戳
  final String tokenType;

  RegisterResponse({
    required this.userId,
    required this.username,
    this.phone,
    this.email,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      userId: (json['userId'] is int) ? json['userId'] : int.parse(json['userId'].toString()),
      username: json['username'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: (json['expiresIn'] is int) ? json['expiresIn'] : int.parse(json['expiresIn'].toString()),
      tokenType: json['tokenType'] as String? ?? 'Bearer',
    );
  }

  // 计算过期时间
  DateTime get expiresAt => DateTime.now().add(Duration(seconds: expiresIn));
}

class UserInfoResponse {
  final int userId;
  final String username;
  final String? phoneNumber;
  final String? email;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final String? status;
  final String? displayName;
  final String? avatarUrl;
  final String? language;
  final String? timezone;
  final String? currency;
  final String kycLevel;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserInfoResponse({
    required this.userId,
    required this.username,
    this.phoneNumber,
    this.email,
    required this.isPhoneVerified,
    required this.isEmailVerified,
    this.status,
    this.displayName,
    this.avatarUrl,
    this.language,
    this.timezone,
    this.currency,
    required this.kycLevel,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) {
    return UserInfoResponse(
      userId: json['userId'],
      username: json['username'],
      phoneNumber: json['phone'],
      email: json['email'],
      isPhoneVerified: json['phoneVerified'] ?? false,
      isEmailVerified: json['emailVerified'] ?? false,
      status: json['status'],
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      language: json['language'],
      timezone: json['timezone'],
      currency: json['currency'],
      kycLevel: json['kycLevel'] ?? 'LEVEL_0',
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
    );
  }
}

class LoginResponse {
  final int userId;
  final String username;
  final String? phone;
  final String? email;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;

  LoginResponse({
    required this.userId,
    required this.username,
    this.phone,
    this.email,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userId: json['userId'],
      username: json['username'],
      phone: json['phone'],
      email: json['email'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      expiresIn: json['expiresIn'],
      tokenType: json['tokenType'] ?? 'Bearer',
    );
  }
}