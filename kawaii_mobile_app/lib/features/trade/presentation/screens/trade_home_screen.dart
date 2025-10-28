import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/router/app_router.dart';

/// 交易首页Tab
class TradeHomeScreen extends StatelessWidget {
  const TradeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('交易'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        children: [
          // 快捷操作卡片
          AppCard(
            child: Column(
              children: [
                _QuickActionTile(
                  icon: Icons.arrow_upward,
                  title: '转账',
                  subtitle: '发送加密货币到其他地址',
                  onTap: () => context.push(AppRoutes.transfer),
                ),
                const Divider(height: 1),
                _QuickActionTile(
                  icon: Icons.arrow_downward,
                  title: '收款',
                  subtitle: '生成收款二维码',
                  onTap: () => context.push(AppRoutes.receive),
                ),
                const Divider(height: 1),
                _QuickActionTile(
                  icon: Icons.swap_horiz,
                  title: '兑换',
                  subtitle: '币币兑换',
                  onTap: () => context.push(AppRoutes.swap),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // 最近交易记录
          Text(
            '最近交易',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // TODO: 实现交易记录列表
          AppCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Text(
                  '暂无交易记录',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }
}
