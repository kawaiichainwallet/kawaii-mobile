import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';

/// 个人中心Tab
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 设置页面
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: 通知中心
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        children: [
          // 用户信息卡片
          AppCard(
            child: Row(
              children: [
                // 头像
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.primaryLight.withOpacity(0.2),
                  child: const Icon(Icons.person, size: 32, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                // 用户信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '用户名',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: 123456789',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '已完成 KYC Lv.2',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // 资产管理
          _SectionHeader(title: '资产管理'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _MenuItem(
                  icon: Icons.account_balance_wallet,
                  title: '我的钱包',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.vpn_key,
                  title: '私钥管理',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.book,
                  title: '助记词备份',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.contacts,
                  title: '地址簿',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // 安全设置
          _SectionHeader(title: '安全设置'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _MenuItem(
                  icon: Icons.lock,
                  title: '修改密码',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.phone_android,
                  title: '双因素认证(2FA)',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.fingerprint,
                  title: '生物识别',
                  onTap: () {},
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                  ),
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.link,
                  title: '授权管理',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // 应用设置
          _SectionHeader(title: '应用设置'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _MenuItem(
                  icon: Icons.language,
                  title: '语言',
                  subtitle: '中文',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.attach_money,
                  title: '默认货币',
                  subtitle: 'USD',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.dark_mode,
                  title: '深色模式',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {},
                  ),
                  onTap: null,
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.notifications,
                  title: '通知设置',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // 帮助与支持
          _SectionHeader(title: '帮助与支持'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _MenuItem(
                  icon: Icons.help_outline,
                  title: '使用指南',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.question_answer,
                  title: '常见问题',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.chat,
                  title: '联系客服',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.feedback,
                  title: '反馈建议',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // 关于
          _SectionHeader(title: '关于'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _MenuItem(
                  icon: Icons.info_outline,
                  title: '关于我们',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.description,
                  title: '使用协议',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.privacy_tip,
                  title: '隐私政策',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.new_releases,
                  title: '版本更新',
                  subtitle: 'v0.1.0',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing2xl),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppTheme.spacingSm,
        bottom: AppTheme.spacingMd,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }
}
