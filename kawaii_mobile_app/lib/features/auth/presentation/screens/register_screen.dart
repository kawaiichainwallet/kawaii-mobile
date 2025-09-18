import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../core/utils/validation_utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  RegisterMethod _selectedMethod = RegisterMethod.phone;
  RegisterStep _currentStep = RegisterStep.selectMethod;
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _otpCountdown = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('注册账户'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildStepContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case RegisterStep.selectMethod:
        return _buildMethodSelection();
      case RegisterStep.inputInfo:
        return _buildInfoInput();
      case RegisterStep.verifyOtp:
        return _buildOtpVerification();
      case RegisterStep.setPassword:
        return _buildPasswordSetup();
      case RegisterStep.completed:
        return _buildCompletedStep();
    }
  }

  Widget _buildMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text(
          '选择注册方式',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '请选择您偏好的注册方式',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 40),
        _buildMethodCard(
          icon: Icons.phone_android,
          title: '手机号注册',
          subtitle: '使用手机号接收验证码',
          method: RegisterMethod.phone,
        ),
        const SizedBox(height: 16),
        _buildMethodCard(
          icon: Icons.email,
          title: '邮箱注册',
          subtitle: '使用邮箱接收验证码',
          method: RegisterMethod.email,
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _currentStep = RegisterStep.inputInfo;
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('继续', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodCard(
      {required IconData icon,
      required String title,
      required String subtitle,
      required RegisterMethod method}) {
    final isSelected = _selectedMethod == method;
    return Card(
      elevation: isSelected ? 8 : 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedMethod = method;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoInput() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            _selectedMethod == RegisterMethod.phone ? '输入手机号' : '输入邮箱',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '我们将向您发送验证码进行验证',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 40),
          if (_selectedMethod == RegisterMethod.phone) ...[
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: '手机号',
                hintText: '请输入11位手机号',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) => ValidationUtils.validatePhone(value),
            ),
          ] else ...[
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: '邮箱地址',
                hintText: '请输入邮箱地址',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) => ValidationUtils.validateEmail(value),
            ),
          ],
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep = RegisterStep.selectMethod;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('返回'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _sendOtp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('发送验证码', style: TextStyle(fontSize: 16)),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtpVerification() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text(
          '输入验证码',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '验证码已发送至 ${_selectedMethod == RegisterMethod.phone ? _phoneController.text : _emailController.text}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 40),
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 6,
          decoration: InputDecoration(
            labelText: '验证码',
            hintText: '请输入6位验证码',
            prefixIcon: const Icon(Icons.security),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            counterText: '',
          ),
          style: const TextStyle(fontSize: 18, letterSpacing: 2),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('没有收到验证码？'),
            TextButton(
              onPressed: _otpCountdown > 0 ? null : _resendOtp,
              child: Text(_otpCountdown > 0 ? '重新发送 (${_otpCountdown}s)' : '重新发送'),
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = RegisterStep.inputInfo;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('返回'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _otpController.text.length == 6 ? _verifyOtp : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('验证', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordSetup() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            '设置账户信息',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '请设置您的用户名和登录密码',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 40),
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: '用户名',
              hintText: '请输入用户名',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) => ValidationUtils.validateUsername(value),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: '密码',
              hintText: '请输入密码',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) => ValidationUtils.validatePassword(value),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: '确认密码',
              hintText: '请再次输入密码',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return '两次输入的密码不一致';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _agreeToTerms = !_agreeToTerms;
                    });
                  },
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        const TextSpan(text: '我已阅读并同意'),
                        TextSpan(
                          text: '《用户服务协议》',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: '和'),
                        TextSpan(
                          text: '《隐私政策》',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return ElevatedButton(
                  onPressed: (_agreeToTerms && !authProvider.isLoading) ? _completeRegister : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('完成注册', style: TextStyle(fontSize: 16)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          '注册成功！',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '欢迎加入 KawaiiChain Wallet',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('开始使用', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  void _sendOtp() async {
    if (_formKey.currentState?.validate() ?? false) {
      final target = _selectedMethod == RegisterMethod.phone
          ? _phoneController.text
          : _emailController.text;
      final targetType = _selectedMethod == RegisterMethod.phone ? 'phone' : 'email';

      final success = await context.read<AuthProvider>().sendVerificationCode(
        target: target,
        targetType: targetType,
        purpose: 'register',
      );

      if (success) {
        setState(() {
          _currentStep = RegisterStep.verifyOtp;
          _startOtpCountdown();
        });
      } else {
        if (mounted) {
          final authProvider = context.read<AuthProvider>();
          if (authProvider.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(authProvider.errorMessage!)),
            );
          }
        }
      }
    }
  }

  void _resendOtp() async {
    final target = _selectedMethod == RegisterMethod.phone
        ? _phoneController.text
        : _emailController.text;
    final targetType = _selectedMethod == RegisterMethod.phone ? 'phone' : 'email';

    final success = await context.read<AuthProvider>().sendVerificationCode(
      target: target,
      targetType: targetType,
      purpose: 'register',
    );

    if (success) {
      _startOtpCountdown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('验证码已重新发送')),
        );
      }
    } else {
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        if (authProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.errorMessage!)),
          );
        }
      }
    }
  }

  void _verifyOtp() async {
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请输入6位验证码')),
        );
      }
      return;
    }

    setState(() {
      _currentStep = RegisterStep.setPassword;
    });
  }

  void _completeRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final target = _selectedMethod == RegisterMethod.phone
          ? _phoneController.text
          : _emailController.text;

      late bool success;
      if (_selectedMethod == RegisterMethod.phone) {
        success = await context.read<AuthProvider>().registerWithPhone(
          phoneNumber: target,
          verificationCode: _otpController.text,
          username: _usernameController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          agreeToTerms: _agreeToTerms,
        );
      } else {
        success = await context.read<AuthProvider>().registerWithEmail(
          email: target,
          verificationCode: _otpController.text,
          username: _usernameController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          agreeToTerms: _agreeToTerms,
        );
      }

      if (success) {
        setState(() {
          _currentStep = RegisterStep.completed;
        });
      } else {
        if (mounted) {
          final authProvider = context.read<AuthProvider>();
          if (authProvider.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(authProvider.errorMessage!)),
            );
          }
        }
      }
    }
  }

  void _startOtpCountdown() {
    setState(() {
      _otpCountdown = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _otpCountdown--;
        });
        return _otpCountdown > 0;
      }
      return false;
    });
  }
}