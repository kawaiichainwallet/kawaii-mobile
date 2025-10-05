import 'package:local_auth/local_auth.dart';

import '../storage/secure_storage_service.dart';
import '../utils/logger.dart';

enum BiometricType {
  none,
  fingerprint,
  face,
  iris,
}

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static final SecureStorageService _secureStorage = SecureStorageService();
  static final AppLogger _logger = AppLogger();

  static BiometricService? _instance;

  static BiometricService get instance {
    _instance ??= BiometricService._internal();
    return _instance!;
  }

  BiometricService._internal();

  /// 检查设备是否支持生物识别
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      _logger.error('检查设备支持失败: $e');
      return false;
    }
  }

  /// 检查是否可以进行生物识别认证
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      _logger.error('检查生物识别可用性失败: $e');
      return false;
    }
  }

  /// 获取可用的生物识别类型列表
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics
          .map((type) => _mapBiometricType(type))
          .toList();
    } catch (e) {
      _logger.error('获取可用生物识别类型失败: $e');
      return [];
    }
  }

  /// 检查是否已启用生物识别登录
  Future<bool> isBiometricLoginEnabled() async {
    return await _secureStorage.isBiometricEnabled();
  }

  /// 启用生物识别登录
  Future<bool> enableBiometricLogin({
    required String credentials, // 加密的登录凭据
  }) async {
    try {
      // 首先验证生物识别
      final isAuthenticated = await authenticate(
        reason: '启用生物识别登录',
      );

      if (!isAuthenticated) {
        return false;
      }

      // 保存加密的凭据
      await _secureStorage.setValue('biometric_credentials', credentials);
      await _secureStorage.setBiometricEnabled(true);

      _logger.info('生物识别登录已启用');
      return true;
    } catch (e) {
      _logger.error('启用生物识别登录失败: $e');
      return false;
    }
  }

  /// 禁用生物识别登录
  Future<void> disableBiometricLogin() async {
    try {
      await _secureStorage.setBiometricEnabled(false);
      await _secureStorage.removeValue('biometric_credentials');
      _logger.info('生物识别登录已禁用');
    } catch (e) {
      _logger.error('禁用生物识别登录失败: $e');
    }
  }

  /// 进行生物识别认证
  Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );

      if (isAuthenticated) {
        _logger.info('生物识别认证成功');
      } else {
        _logger.warning('生物识别认证失败或被取消');
      }

      return isAuthenticated;
    } catch (e) {
      _logger.error('生物识别认证异常: $e');
      return false;
    }
  }

  /// 使用生物识别进行登录
  Future<String?> authenticateForLogin() async {
    try {
      // 检查是否启用了生物识别登录
      if (!await isBiometricLoginEnabled()) {
        _logger.warning('生物识别登录未启用');
        return null;
      }

      // 进行生物识别认证
      final isAuthenticated = await authenticate(
        reason: '使用生物识别登录',
        useErrorDialogs: true,
        stickyAuth: true,
      );

      if (!isAuthenticated) {
        return null;
      }

      // 获取存储的登录凭据
      final credentials = await _secureStorage.getValue('biometric_credentials');
      if (credentials == null) {
        _logger.error('未找到生物识别登录凭据');
        await disableBiometricLogin(); // 清理无效状态
        return null;
      }

      return credentials;
    } catch (e) {
      _logger.error('生物识别登录失败: $e');
      return null;
    }
  }

  /// 检查特定生物识别类型是否可用
  Future<bool> isBiometricTypeAvailable(BiometricType type) async {
    final availableTypes = await getAvailableBiometrics();
    return availableTypes.contains(type);
  }

  /// 获取生物识别状态描述
  Future<String> getBiometricStatusDescription() async {
    try {
      if (!await isDeviceSupported()) {
        return '设备不支持生物识别';
      }

      if (!await canCheckBiometrics()) {
        return '生物识别不可用';
      }

      final availableTypes = await getAvailableBiometrics();
      if (availableTypes.isEmpty) {
        return '未设置生物识别';
      }

      final typeNames = availableTypes.map(_getBiometricTypeName).join('、');
      return '可用: $typeNames';
    } catch (e) {
      return '检查生物识别状态失败';
    }
  }

  /// 映射生物识别类型
  BiometricType _mapBiometricType(dynamic type) {
    if (type.toString().contains('fingerprint')) {
      return BiometricType.fingerprint;
    } else if (type.toString().contains('face')) {
      return BiometricType.face;
    } else if (type.toString().contains('iris')) {
      return BiometricType.iris;
    }
    return BiometricType.none;
  }

  /// 获取生物识别类型名称
  String _getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.fingerprint:
        return '指纹';
      case BiometricType.face:
        return '面部识别';
      case BiometricType.iris:
        return '虹膜';
      case BiometricType.none:
        return '无';
    }
  }

  /// 检查并请求生物识别权限（Android）
  Future<bool> checkAndRequestPermissions() async {
    try {
      final isDeviceSupported = await this.isDeviceSupported();
      if (!isDeviceSupported) {
        return false;
      }

      final canCheck = await canCheckBiometrics();
      return canCheck;
    } catch (e) {
      _logger.error('检查生物识别权限失败: $e');
      return false;
    }
  }

  /// 显示生物识别设置引导
  Future<void> showBiometricSetupGuide() async {
    // 这里可以显示引导用户去设置生物识别的对话框
    // 具体实现可以在UI层处理
    _logger.info('显示生物识别设置引导');
  }
}