import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 通用卡片组件
///
/// 使用示例：
/// ```dart
/// AppCard(
///   child: Text('卡片内容'),
/// )
///
/// AppCard(
///   elevation: 2,
///   onTap: () {},
///   child: ListTile(title: Text('可点击卡片')),
/// )
/// ```
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation = 0,
    this.borderRadius,
    this.border,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double elevation;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingMd),
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusMd),
        border: border ??
            Border.all(
              color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
              width: 1,
            ),
        boxShadow: elevation > 0 ? AppTheme.shadowMd : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusMd),
        child: card,
      );
    }

    return card;
  }
}

/// 资产卡片（显示总资产）
class AssetSummaryCard extends StatelessWidget {
  const AssetSummaryCard({
    super.key,
    required this.totalValue,
    required this.currency,
    required this.change24h,
    this.isValueVisible = true,
    this.onVisibilityToggle,
  });

  final double totalValue;
  final String currency;
  final double change24h;
  final bool isValueVisible;
  final VoidCallback? onVisibilityToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = change24h >= 0;

    return AppCard(
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题与可见性切换
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '总资产 ($currency)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              if (onVisibilityToggle != null)
                IconButton(
                  icon: Icon(
                    isValueVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: onVisibilityToggle,
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),

          // 总资产数值
          Text(
            isValueVisible
                ? '\$${totalValue.toStringAsFixed(2)}'
                : '****.**',
            style: theme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),

          // 24h涨跌
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${isPositive ? '+' : ''}${change24h.toStringAsFixed(2)}% (24h)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 钱包卡片
class WalletCard extends StatelessWidget {
  const WalletCard({
    super.key,
    required this.walletName,
    required this.address,
    required this.totalValue,
    this.isDefault = false,
    this.onTap,
  });

  final String walletName;
  final String address;
  final double totalValue;
  final bool isDefault;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          // 钱包图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),

          // 钱包信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      walletName,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '默认',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatAddress(address),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${totalValue.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 箭头
          const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
        ],
      ),
    );
  }

  String _formatAddress(String address) {
    if (address.length <= 13) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}
