import 'package:flutter/foundation.dart';

class ApiConfig {
  // 根据构建模式自动选择环境
  static String get baseUrl {
    if (kDebugMode) {
      return developmentUrl;
    } else if (kProfileMode) {
      return stagingUrl;
    } else {
      return productionUrl;
    }
  }

  // 开发环境 - 本地服务
  static const String developmentUrl = 'http://localhost:8090/api/v1';

  // 测试环境
  static const String stagingUrl = 'https://staging-api.kawaiichainwallet.com/api/v1';

  // 生产环境
  static const String productionUrl = 'https://api.kawaiichainwallet.com/api/v1';

  // Android 模拟器的特殊配置（如果需要）
  static const String androidEmulatorUrl = 'http://10.0.2.2:8080/api/v1';

  // iOS 模拟器的特殊配置（如果需要）
  static const String iOSSimulatorUrl = 'http://127.0.0.1:8080/api/v1';

  // 连接超时配置
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // 是否启用日志
  static bool get enableLogging => kDebugMode;
}