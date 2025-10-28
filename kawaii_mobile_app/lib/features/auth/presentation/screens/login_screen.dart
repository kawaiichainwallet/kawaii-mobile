import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/router/app_router.dart';

/// 登录页面 - 占位符实现
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle,
                size: 100,
                color: AppTheme.primaryColor.withOpacity(0.5),
              ),
              const SizedBox(height: AppTheme.spacingXl),
              Text(
                '登录功能开发中',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                '此功能正在开发中，敬请期待',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing2xl),
              AppButton(
                fullWidth: true,
                onPressed: () => context.go(AppRoutes.main),
                child: const Text('临时跳转到主界面'),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              AppButton(
                type: ButtonType.text,
                onPressed: () => context.pop(),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
