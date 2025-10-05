import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers/auth_provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  late TabController _tabController;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  int _countdown = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '登录',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return LoadingOverlay(
            isLoading: authProvider.isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildWelcomeSection(),
                  const SizedBox(height: 40),
                  _buildTabSection(),
                  const SizedBox(height: 32),
                  _buildLoginForms(),
                  if (authProvider.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorMessage(authProvider.errorMessage!),
                  ],
                  const SizedBox(height: 24),
                  _buildFooterSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '欢迎回来',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '请登录您的账户以继续使用',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTabSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).primaryColor,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: '密码登录'),
          Tab(text: '验证码登录'),
        ],
      ),
    );
  }

  Widget _buildLoginForms() {
    return SizedBox(
      height: 400,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPasswordLoginForm(),
          _buildOtpLoginForm(),
        ],
      ),
    );
  }

  Widget _buildPasswordLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _identifierController,
            label: '用户名/邮箱/手机号',
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入用户名、邮箱或手机号';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            label: '密码',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入密码';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildRememberMeRow(),
          const SizedBox(height: 32),
          CustomButton(
            text: '登录',
            onPressed: _handlePasswordLogin,
            isLoading: context.watch<AuthProvider>().isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildOtpLoginForm() {
    return Column(
      children: [
        CustomTextField(
          controller: _phoneController,
          label: '手机号',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入手机号';
            }
            if (!Validators.isValidPhone(value)) {
              return '请输入正确的手机号格式';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _otpController,
                label: '验证码',
                prefixIcon: Icons.verified_user_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入验证码';
                  }
                  if (value.length != 6) {
                    return '验证码应为6位数字';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: CustomButton(
                text: _countdown > 0 ? '${_countdown}s' : '获取验证码',
                onPressed: _countdown > 0 ? null : _sendOtp,
                variant: ButtonVariant.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: '登录',
          onPressed: _handleOtpLogin,
          isLoading: context.watch<AuthProvider>().isLoading,
        ),
      ],
    );
  }

  Widget _buildRememberMeRow() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
        ),
        const Text('记住我'),
        const Spacer(),
        TextButton(
          onPressed: _navigateToForgotPassword,
          child: Text(
            '忘记密码？',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              context.read<AuthProvider>().clearError();
            },
            color: Colors.red[600],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('还没有账户？'),
            TextButton(
              onPressed: _navigateToRegister,
              child: Text(
                '立即注册',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildBiometricLogin(),
      ],
    );
  }

  Widget _buildBiometricLogin() {
    return FutureBuilder<bool>(
      future: context.read<AuthProvider>().canUseBiometric(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '或',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<bool>(
              future: context.read<AuthProvider>().isBiometricLoginEnabled(),
              builder: (context, enabledSnapshot) {
                final isEnabled = enabledSnapshot.data ?? false;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBiometricButton(
                      icon: Icons.fingerprint,
                      label: '指纹登录',
                      onPressed: isEnabled ? _handleFingerprintLogin : null,
                      isEnabled: isEnabled,
                    ),
                    const SizedBox(width: 32),
                    _buildBiometricButton(
                      icon: Icons.face,
                      label: '面部识别',
                      onPressed: isEnabled ? _handleFaceIdLogin : null,
                      isEnabled: isEnabled,
                    ),
                  ],
                );
              },
            ),
            if (!snapshot.hasData || !(snapshot.data!)) ...[
              const SizedBox(height: 8),
              Text(
                '请先启用生物识别登录',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildBiometricButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isEnabled = true,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isEnabled ? Colors.grey[300]! : Colors.grey[200]!,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isEnabled ? null : Colors.grey[50],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isEnabled
                  ? Theme.of(context).primaryColor
                  : Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isEnabled ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Event handlers
  Future<void> _handlePasswordLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    final success = await authProvider.login(
      identifier: identifier,
      password: password,
      rememberMe: _rememberMe,
    );

    if (success && mounted) {
      // 提示启用生物识别登录
      await _promptBiometricSetupIfNeeded(identifier, password);

      context.go('/home');
    }
  }

  Future<void> _handleOtpLogin() async {
    if (_phoneController.text.isEmpty || _otpController.text.isEmpty) {
      _showSnackBar('请填写完整信息');
      return;
    }

    if (!Validators.isValidPhone(_phoneController.text)) {
      _showSnackBar('请输入正确的手机号格式');
      return;
    }

    if (_otpController.text.length != 6) {
      _showSnackBar('验证码应为6位数字');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.quickLoginWithOTP(
      phoneNumber: _phoneController.text.trim(),
      otp: _otpController.text,
    );

    if (success && mounted) {
      context.go('/home');
    }
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.isEmpty) {
      _showSnackBar('请输入手机号');
      return;
    }

    if (!Validators.isValidPhone(_phoneController.text)) {
      _showSnackBar('请输入正确的手机号格式');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendVerificationCode(
      target: _phoneController.text.trim(),
      targetType: 'phone',
      purpose: 'login',
    );

    if (success) {
      setState(() {
        _countdown = 60;
      });

      _startCountdown();
      _showSnackBar('验证码已发送');
    }
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_countdown > 0 && mounted) {
        setState(() {
          _countdown--;
        });
        _startCountdown();
      }
    });
  }

  void _handleFingerprintLogin() async {
    await _handleBiometricLogin();
  }

  void _handleFaceIdLogin() async {
    await _handleBiometricLogin();
  }

  Future<void> _handleBiometricLogin() async {
    final authProvider = context.read<AuthProvider>();

    // 检查是否支持生物识别
    if (!await authProvider.canUseBiometric()) {
      _showSnackBar('设备不支持生物识别或未设置生物识别');
      return;
    }

    // 检查是否启用了生物识别登录
    if (!await authProvider.isBiometricLoginEnabled()) {
      _showSnackBar('请先在设置中启用生物识别登录');
      return;
    }

    // 进行生物识别登录
    final success = await authProvider.loginWithBiometric();

    if (success && mounted) {
      context.go('/home');
    }
  }

  void _navigateToRegister() {
    context.push('/auth/register');
  }

  void _navigateToForgotPassword() {
    context.push('/auth/forgot-password');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 提示用户启用生物识别登录
  Future<void> _promptBiometricSetupIfNeeded(String identifier, String password) async {
    final authProvider = context.read<AuthProvider>();

    // 检查是否需要提示
    if (!await authProvider.canUseBiometric()) {
      return;
    }

    if (await authProvider.isBiometricLoginEnabled()) {
      return;
    }

    // 显示对话框询问用户是否要启用生物识别
    if (mounted) {
      final shouldEnable = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('启用生物识别登录'),
          content: const Text('您的设备支持生物识别。是否要启用生物识别登录以便下次快速登录？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('稍后'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('启用'),
            ),
          ],
        ),
      );

      if (shouldEnable == true) {
        final success = await authProvider.enableBiometricLogin(
          identifier: identifier,
          password: password,
        );

        if (success) {
          _showSnackBar('生物识别登录已启用');
        } else {
          _showSnackBar('启用生物识别登录失败');
        }
      }
    }
  }
}