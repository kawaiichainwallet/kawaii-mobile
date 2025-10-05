import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // 根据构建模式和平台自动选择环境
  static String get baseUrl {
    if (kDebugMode) {
      return developmentUrl;
    } else if (kProfileMode) {
      return stagingUrl;
    } else {
      return productionUrl;
    }
  }

  // 开发环境 - 根据平台自动选择正确的URL
  static String get developmentUrl {
    // Android 模拟器使用 10.0.2.2 访问宿主机
    if (Platform.isAndroid) {
      return androidEmulatorUrl;
    }
    // iOS 模拟器可以使用 localhost
    else if (Platform.isIOS) {
      return iOSSimulatorUrl;
    }
    // 其他平台（如 macOS、Windows）使用 localhost
    return localUrl;
  }

  // 本地开发地址
  static const String localUrl = 'http://localhost:8090';

  // Android 模拟器访问宿主机的特殊地址
  static const String androidEmulatorUrl = 'http://10.0.2.2:8090';

  // iOS 模拟器地址
  static const String iOSSimulatorUrl = 'http://127.0.0.1:8090';

  // 测试环境
  static const String stagingUrl = 'https://staging-api.kawaiichainwallet.com';

  // 生产环境
  static const String productionUrl = 'https://api.kawaiichainwallet.com';

  // 连接超时配置
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // 是否启用日志
  static bool get enableLogging => kDebugMode;
}