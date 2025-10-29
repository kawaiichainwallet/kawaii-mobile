import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/auth_api.dart';
import '../../../core/storage/secure_storage_service.dart';

/// 认证状态
class AuthState {
  final bool isAuthenticated;
  final String? accessToken;
  final String? userId;
  final String? username;
  final bool isLoading;

  const AuthState({
    this.isAuthenticated = false,
    this.accessToken,
    this.userId,
    this.username,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? accessToken,
    String? userId,
    String? username,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      accessToken: accessToken ?? this.accessToken,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 认证状态管理器
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthApi _authApi;
  final SecureStorageService _secureStorage;

  AuthStateNotifier({
    AuthApi? authApi,
    SecureStorageService? secureStorage,
  })  : _authApi = authApi ?? AuthApi.instance,
        _secureStorage = secureStorage ?? SecureStorageService(),
        super(const AuthState()) {
    _loadAuthState();
  }

  /// 从本地安全存储加载认证状态
  Future<void> _loadAuthState() async {
    try {
      state = state.copyWith(isLoading: true);

      final accessToken = await _secureStorage.getAccessToken();
      final userId = await _secureStorage.getUserId();
      final username = await _secureStorage.getUsername();

      state = AuthState(
        isAuthenticated: accessToken != null && accessToken.isNotEmpty,
        accessToken: accessToken,
        userId: userId,
        username: username,
        isLoading: false,
      );
    } catch (e) {
      state = const AuthState(isLoading: false);
    }
  }

  /// 登出（使用 AuthApi）
  Future<void> logout() async {
    try {
      // 调用 AuthApi 的登出方法，它会处理服务端登出和本地清理
      await _authApi.logout();

      state = const AuthState(isAuthenticated: false);
    } catch (e) {
      // 即使出错，也要清除本地状态
      state = const AuthState(isAuthenticated: false);
      rethrow;
    }
  }

  /// 刷新认证状态（从本地存储重新加载）
  Future<void> refresh() async {
    await _loadAuthState();
  }

  /// 验证 Token 是否有效
  Future<bool> validateToken() async {
    return await _authApi.validateToken();
  }

  /// 获取当前用户ID
  Future<int?> getCurrentUserId() async {
    return await _authApi.getCurrentUserId();
  }

  /// 获取当前用户名
  Future<String?> getCurrentUsername() async {
    return await _authApi.getCurrentUsername();
  }
}

/// 认证状态 Provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier();
});
