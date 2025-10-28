import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';

/// 生活服务首页Tab
class LifeServiceHomeScreen extends StatelessWidget {
  const LifeServiceHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('生活服务'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 搜索功能
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        children: [
          // 余额卡片
          AppCard(
            color: AppTheme.primaryLight.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '生活账户余额',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '¥1,234.56',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: 充值功能
                  },
                  child: const Text('充值'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // 快捷缴费
          Text(
            '快捷缴费',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // 缴费网格
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: AppTheme.spacingMd,
            crossAxisSpacing: AppTheme.spacingMd,
            children: [
              _ServiceCard(
                icon: Icons.water_drop,
                title: '水费',
                onTap: () {
                  // TODO: 水费缴纳
                },
              ),
              _ServiceCard(
                icon: Icons.bolt,
                title: '电费',
                onTap: () {
                  // TODO: 电费缴纳
                },
              ),
              _ServiceCard(
                icon: Icons.local_fire_department,
                title: '燃气费',
                onTap: () {
                  // TODO: 燃气费缴纳
                },
              ),
              _ServiceCard(
                icon: Icons.phone_android,
                title: '话费',
                onTap: () {
                  // TODO: 话费充值
                },
              ),
              _ServiceCard(
                icon: Icons.wifi,
                title: '宽带费',
                onTap: () {
                  // TODO: 宽带缴费
                },
              ),
              _ServiceCard(
                icon: Icons.directions_car,
                title: '违章缴费',
                onTap: () {
                  // TODO: 违章缴费
                },
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // 商户支付
          Text(
            '商户支付',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AppCard(
            onTap: () {
              // TODO: 商户支付
            },
            child: Row(
              children: [
                Icon(Icons.qr_code_scanner, size: 40, color: AppTheme.primaryColor),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('扫码支付', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        '支持加密货币支付的商家',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: AppTheme.primaryColor),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
