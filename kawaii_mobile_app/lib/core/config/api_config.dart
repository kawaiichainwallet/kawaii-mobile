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

  // 开发环境 - 通过API网关访问 (8090端口)
  static const String developmentUrl = 'http://localhost:8090';

  // 测试环境
  static const String stagingUrl = 'https://staging-api.kawaiichainwallet.com';

  // 生产环境
  static const String productionUrl = 'https://api.kawaiichainwallet.com';

  // Android 模拟器的特殊配置（如果需要）
  static const String androidEmulatorUrl = 'http://10.0.2.2:8090';

  // iOS 模拟器的特殊配置（如果需要）
  static const String iOSSimulatorUrl = 'http://127.0.0.1:8090';

  // 连接超时配置
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // 是否启用日志
  static bool get enableLogging => kDebugMode;
}