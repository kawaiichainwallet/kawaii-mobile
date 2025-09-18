import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
            _logger.info('Headers: ${options.headers}');
            if (options.data != null) {
              _logger.info('Body: ${options.data}');
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (ApiConfig.enableLogging) {
            _logger.info('Response: ${response.statusCode} ${response.requestOptions.uri}');
            _logger.info('Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          _logger.error('API Error: ${error.message}');

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
        final response = await _dio.post('/auth/refresh', data: {
          'refreshToken': refreshToken,
        });

        if (response.statusCode == 200) {
          final newAccessToken = response.data['data']['accessToken'];
          final newRefreshToken = response.data['data']['refreshToken'];

          await _secureStorage.setAccessToken(newAccessToken);
          await _secureStorage.setRefreshToken(newRefreshToken);
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
  Future<ApiResponse<T>> request<T>(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      late Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(endpoint, queryParameters: queryParameters);
          break;
        case 'POST':
          response = await _dio.post(endpoint, data: data, queryParameters: queryParameters);
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

      return ApiResponse<T>.fromJson(
        response.data,
        fromJson: fromJson,
      );
    } on DioException catch (e) {
      _logger.error('Dio Error: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      _logger.error('Unknown Error: $e');
      throw ApiException(
        message: '网络请求失败',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  // 用户相关 API
  Future<ApiResponse<void>> sendOtp({
    required String target,
    required String type,
    required String purpose,
  }) async {
    return request<void>(
      '/users/register/send-otp',
      method: 'POST',
      data: {
        'target': target,
        'type': type,
        'purpose': purpose,
      },
    );
  }

  Future<ApiResponse<RegisterResponse>> registerWithOtp({
    required String target,
    required String type,
    required String otpCode,
    required String username,
    required String password,
    required String confirmPassword,
    required bool agreeToTerms,
  }) async {
    return request<RegisterResponse>(
      '/users/register/verify-otp',
      method: 'POST',
      data: {
        'target': target,
        'type': type,
        'otpCode': otpCode,
        'username': username,
        'password': password,
        'confirmPassword': confirmPassword,
        'agreeToTerms': agreeToTerms,
      },
      fromJson: (json) => RegisterResponse.fromJson(json),
    );
  }

  Future<ApiResponse<UserInfoResponse>> getUserInfo() async {
    return request<UserInfoResponse>(
      '/users/profile',
      fromJson: (json) => UserInfoResponse.fromJson(json),
    );
  }

  Future<ApiResponse<String>> healthCheck() async {
    return request<String>('/users/health');
  }
}

// API 响应包装类
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? timestamp;
  final String? traceId;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.timestamp,
    this.traceId,
  });

  factory ApiResponse.fromJson(
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

    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
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
              message = error.response?.data['message'] ?? '请求错误';
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
  final String userId;
  final String username;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  RegisterResponse({
    required this.userId,
    required this.username,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      userId: json['userId'],
      username: json['username'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}

class UserInfoResponse {
  final String userId;
  final String username;
  final String? phoneNumber;
  final String? email;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final String kycLevel;
  final DateTime createdAt;

  UserInfoResponse({
    required this.userId,
    required this.username,
    this.phoneNumber,
    this.email,
    required this.isPhoneVerified,
    required this.isEmailVerified,
    required this.kycLevel,
    required this.createdAt,
  });

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) {
    return UserInfoResponse(
      userId: json['userId'],
      username: json['username'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      isEmailVerified: json['isEmailVerified'] ?? false,
      kycLevel: json['kycLevel'] ?? 'LEVEL_1',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}