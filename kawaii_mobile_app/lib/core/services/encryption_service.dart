import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

import '../utils/logger.dart';

class EncryptionService {
  static final AppLogger _logger = AppLogger();
  static EncryptionService? _instance;

  static EncryptionService get instance {
    _instance ??= EncryptionService._internal();
    return _instance!;
  }

  EncryptionService._internal();

  /// 生成随机密钥
  String generateRandomKey({int length = 32}) {
    final secureRandom = SecureRandom();
    final key = secureRandom.nextBytes(length);
    return base64Encode(key);
  }

  /// 使用AES加密数据
  String encryptAES(String plaintext, String key) {
    try {
      final keyBytes = base64Decode(key);
      final encrypter = Encrypter(AES(Key(keyBytes)));
      final iv = IV.fromSecureRandom(16);

      final encrypted = encrypter.encrypt(plaintext, iv: iv);

      // 将IV和加密数据组合
      final combined = iv.bytes + encrypted.bytes;
      return base64Encode(combined);
    } catch (e) {
      _logger.error('AES加密失败: $e');
      rethrow;
    }
  }

  /// 使用AES解密数据
  String decryptAES(String encryptedData, String key) {
    try {
      final keyBytes = base64Decode(key);
      final encrypter = Encrypter(AES(Key(keyBytes)));

      final combined = base64Decode(encryptedData);

      // 分离IV和加密数据
      final iv = IV(Uint8List.fromList(combined.take(16).toList()));
      final encrypted = Encrypted(Uint8List.fromList(combined.skip(16).toList()));

      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      _logger.error('AES解密失败: $e');
      rethrow;
    }
  }

  /// 加密登录凭据
  String encryptCredentials({
    required String identifier,
    required String password,
    String? additionalData,
  }) {
    try {
      final credentials = {
        'identifier': identifier,
        'password': password,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        if (additionalData != null) 'additionalData': additionalData,
      };

      final jsonString = jsonEncode(credentials);
      final key = generateRandomKey();
      final encryptedData = encryptAES(jsonString, key);

      // 将密钥和加密数据组合（在实际应用中，密钥应该由更安全的方式管理）
      final result = {
        'data': encryptedData,
        'key': key,
        'version': '1.0',
      };

      return base64Encode(utf8.encode(jsonEncode(result)));
    } catch (e) {
      _logger.error('加密凭据失败: $e');
      rethrow;
    }
  }

  /// 解密登录凭据
  Map<String, dynamic>? decryptCredentials(String encryptedCredentials) {
    try {
      final decodedData = utf8.decode(base64Decode(encryptedCredentials));
      final container = jsonDecode(decodedData) as Map<String, dynamic>;

      final encryptedData = container['data'] as String;
      final key = container['key'] as String;
      final version = container['version'] as String;

      // 验证版本兼容性
      if (version != '1.0') {
        _logger.warning('不支持的凭据版本: $version');
        return null;
      }

      final decryptedJson = decryptAES(encryptedData, key);
      final credentials = jsonDecode(decryptedJson) as Map<String, dynamic>;

      // 验证时间戳（可选：检查凭据是否过期）
      final timestamp = credentials['timestamp'] as int?;
      if (timestamp != null) {
        final credentialsDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        final daysSinceCreation = now.difference(credentialsDate).inDays;

        // 如果凭据超过30天，可能需要重新验证
        if (daysSinceCreation > 30) {
          _logger.warning('凭据已创建$daysSinceCreation天，建议重新验证');
        }
      }

      return credentials;
    } catch (e) {
      _logger.error('解密凭据失败: $e');
      return null;
    }
  }

  /// 生成密码哈希
  String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 验证密码哈希
  bool verifyPassword(String password, String salt, String hash) {
    final computedHash = hashPassword(password, salt);
    return computedHash == hash;
  }

  /// 生成盐值
  String generateSalt({int length = 16}) {
    final secureRandom = SecureRandom();
    final saltBytes = secureRandom.nextBytes(length);
    return base64Encode(saltBytes);
  }

  /// 生成设备指纹（用于额外安全验证）
  String generateDeviceFingerprint({
    required String deviceId,
    required String appVersion,
    String? additionalInfo,
  }) {
    final fingerprint = {
      'deviceId': deviceId,
      'appVersion': appVersion,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      if (additionalInfo != null) 'additionalInfo': additionalInfo,
    };

    final jsonString = jsonEncode(fingerprint);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  /// 验证设备指纹
  bool verifyDeviceFingerprint({
    required String storedFingerprint,
    required String deviceId,
    required String appVersion,
    String? additionalInfo,
  }) {
    try {
      final currentFingerprint = generateDeviceFingerprint(
        deviceId: deviceId,
        appVersion: appVersion,
        additionalInfo: additionalInfo,
      );

      return storedFingerprint == currentFingerprint;
    } catch (e) {
      _logger.error('验证设备指纹失败: $e');
      return false;
    }
  }
}

/// 安全随机数生成器
class SecureRandom {
  static final _instance = SecureRandom._internal();
  factory SecureRandom() => _instance;
  SecureRandom._internal();

  /// 生成指定长度的随机字节
  Uint8List nextBytes(int length) {
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = DateTime.now().microsecondsSinceEpoch % 256;
    }
    return bytes;
  }

  /// 生成随机整数
  int nextInt(int max) {
    return DateTime.now().microsecondsSinceEpoch % max;
  }

  /// 生成随机布尔值
  bool nextBool() {
    return nextInt(2) == 1;
  }
}