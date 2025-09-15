import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/logger.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _pinCodeKey = 'pin_code';
  static const String _privateKeyKey = 'private_key';

  final AppLogger _logger = AppLogger();

  // Token management
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      _logger.error('Failed to get access token: $e');
      return null;
    }
  }

  Future<void> setAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
    } catch (e) {
      _logger.error('Failed to set access token: $e');
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      _logger.error('Failed to get refresh token: $e');
      return null;
    }
  }

  Future<void> setRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      _logger.error('Failed to set refresh token: $e');
    }
  }

  // User data
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      _logger.error('Failed to get user ID: $e');
      return null;
    }
  }

  Future<void> setUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
    } catch (e) {
      _logger.error('Failed to set user ID: $e');
    }
  }

  // Biometric settings
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _storage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      _logger.error('Failed to check biometric status: $e');
      return false;
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
    } catch (e) {
      _logger.error('Failed to set biometric status: $e');
    }
  }

  // PIN Code
  Future<String?> getPinCode() async {
    try {
      return await _storage.read(key: _pinCodeKey);
    } catch (e) {
      _logger.error('Failed to get PIN code: $e');
      return null;
    }
  }

  Future<void> setPinCode(String pinCode) async {
    try {
      // In a real app, you should hash the PIN before storing
      await _storage.write(key: _pinCodeKey, value: pinCode);
    } catch (e) {
      _logger.error('Failed to set PIN code: $e');
    }
  }

  // Private Key (for wallet operations)
  Future<String?> getPrivateKey() async {
    try {
      return await _storage.read(key: _privateKeyKey);
    } catch (e) {
      _logger.error('Failed to get private key: $e');
      return null;
    }
  }

  Future<void> setPrivateKey(String privateKey) async {
    try {
      await _storage.write(key: _privateKeyKey, value: privateKey);
    } catch (e) {
      _logger.error('Failed to set private key: $e');
    }
  }

  // Generic storage methods
  Future<String?> getValue(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      _logger.error('Failed to get value for key $key: $e');
      return null;
    }
  }

  Future<void> setValue(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      _logger.error('Failed to set value for key $key: $e');
    }
  }

  Future<void> removeValue(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      _logger.error('Failed to remove value for key $key: $e');
    }
  }

  // Clear all stored data
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      _logger.info('All secure storage cleared');
    } catch (e) {
      _logger.error('Failed to clear secure storage: $e');
    }
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      _logger.error('Failed to check key existence: $e');
      return false;
    }
  }

  // Get all keys
  Future<Map<String, String>> getAllValues() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      _logger.error('Failed to get all values: $e');
      return {};
    }
  }
}