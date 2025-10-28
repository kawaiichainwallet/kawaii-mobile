import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/router/app_router.dart';

/// 注册页面 - 占位符实现
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('注册'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add,
                size: 100,
                color: AppTheme.primaryColor.withOpacity(0.5),
              ),
              const SizedBox(height: AppTheme.spacingXl),
              Text(
                '注册功能开发中',
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
                onPressed: () => context.go(AppRoutes.createWallet),
                child: const Text('跳转到创建钱包'),
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
