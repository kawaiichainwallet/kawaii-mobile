import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/auth_selection_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/providers/auth_state_provider.dart';
import '../../features/wallet/presentation/screens/create_wallet_flow_screen.dart';
import '../../features/wallet/presentation/screens/import_wallet_screen.dart';
import '../../features/home/presentation/screens/main_screen.dart';
import '../../features/assets/presentation/screens/asset_detail_screen.dart';
import '../../features/trade/presentation/screens/transfer_screen.dart';
import '../../features/trade/presentation/screens/receive_screen.dart';
import '../../features/trade/presentation/screens/swap_screen.dart';

/// 路由名称常量
class AppRoutes {
  // 启动与引导
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const authSelection = '/auth-selection';

  // 认证相关
  static const register = '/register';
  static const login = '/login';
  static const otpVerification = '/otp-verification';

  // 钱包创建/导入
  static const createWallet = '/create-wallet';
  static const importWallet = '/import-wallet';

  // 主界面
  static const main = '/main';

  // 资产相关
  static const assetHome = '/main/assets';
  static const assetDetail = '/main/assets/detail';
  static const transactionHistory = '/main/assets/transactions';
  static const transactionDetail = '/main/assets/transaction-detail';

  // 交易相关
  static const transfer = '/main/trade/transfer';
  static const transferConfirm = '/main/trade/transfer/confirm';
  static const receive = '/main/trade/receive';
  static const swap = '/main/trade/swap';

  // 生活服务
  static const lifeService = '/main/life';
  static const billPayment = '/main/life/bill-payment';
  static const merchantPayment = '/main/life/merchant-payment';

  // 我的
  static const profile = '/main/profile';
  static const walletManagement = '/main/profile/wallets';
  static const addressBook = '/main/profile/address-book';
  static const security = '/main/profile/security';
  static const settings = '/main/profile/settings';

  /// 不需要登录的公开路由
  static const List<String> publicRoutes = [
    splash,
    onboarding,
    authSelection,
    register,
    login,
    otpVerification,
  ];

  /// 需要登录的受保护路由（主要是以 /main 开头的路由）
  static bool isProtectedRoute(String location) {
    return location.startsWith('/main') ||
           location.startsWith('/create-wallet') ||
           location.startsWith('/import-wallet');
  }

  /// 认证相关路由（已登录用户不应访问）
  static bool isAuthRoute(String location) {
    return location == authSelection ||
           location == login ||
           location == register ||
           location == otpVerification;
  }
}

/// 路由刷新通知器
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) {
      notifyListeners();
    });
  }
}

/// 路由配置 Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  // 创建路由刷新监听器
  final notifier = _RouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: notifier,

    // 路由守卫：根据认证状态重定向
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final location = state.matchedLocation;

      // 如果正在加载认证状态，保持当前页面
      if (authState.isLoading) {
        return null;
      }

      final isAuthenticated = authState.isAuthenticated;

      // 情况1：未登录用户尝试访问需要登录的页面 → 重定向到登录选择页
      if (!isAuthenticated && AppRoutes.isProtectedRoute(location)) {
        return AppRoutes.authSelection;
      }

      // 情况2：已登录用户访问认证相关页面 → 重定向到主页
      if (isAuthenticated && AppRoutes.isAuthRoute(location)) {
        return AppRoutes.main;
      }

      // 情况3：公开路由，允许访问
      return null;
    },

    routes: [
      // ==================== 启动与引导流程 ====================
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      GoRoute(
        path: AppRoutes.authSelection,
        name: 'auth-selection',
        builder: (context, state) => const AuthSelectionScreen(),
      ),

      // ==================== 认证流程 ====================
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: AppRoutes.otpVerification,
        name: 'otp-verification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OTPVerificationScreen(
            phoneNumber: extra?['phoneNumber'] as String? ?? '',
            email: extra?['email'] as String? ?? '',
            verificationType: extra?['verificationType'] as String? ?? 'register',
          );
        },
      ),

      // ==================== 钱包创建/导入 ====================
      GoRoute(
        path: AppRoutes.createWallet,
        name: 'create-wallet',
        builder: (context, state) => const CreateWalletFlowScreen(),
      ),

      GoRoute(
        path: AppRoutes.importWallet,
        name: 'import-wallet',
        builder: (context, state) => const ImportWalletScreen(),
      ),

      // ==================== 主界面 (带 Bottom Navigation) ====================
      GoRoute(
        path: AppRoutes.main,
        name: 'main',
        builder: (context, state) => const MainScreen(),
        routes: [
          // 资产相关子路由
          GoRoute(
            path: 'assets/detail',
            name: 'asset-detail',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return AssetDetailScreen(
                symbol: extra?['symbol'] as String? ?? 'ETH',
              );
            },
          ),

          // 交易相关子路由
          GoRoute(
            path: 'trade/transfer',
            name: 'transfer',
            builder: (context, state) => const TransferScreen(),
          ),

          GoRoute(
            path: 'trade/receive',
            name: 'receive',
            builder: (context, state) => const ReceiveScreen(),
          ),

          GoRoute(
            path: 'trade/swap',
            name: 'swap',
            builder: (context, state) => const SwapScreen(),
          ),

          // 个人中心子路由
          GoRoute(
            path: 'profile/wallets',
            name: 'wallet-management',
            builder: (context, state) => const Placeholder(), // TODO: 实现钱包管理页面
          ),

          GoRoute(
            path: 'profile/address-book',
            name: 'address-book',
            builder: (context, state) => const Placeholder(), // TODO: 实现地址簿页面
          ),

          GoRoute(
            path: 'profile/security',
            name: 'security',
            builder: (context, state) => const Placeholder(), // TODO: 实现安全中心页面
          ),
        ],
      ),
    ],

    // 错误页面
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('页面不存在: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.main),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
  );
});
