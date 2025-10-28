import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/router/app_router.dart';

/// 资产首页
class AssetHomeScreen extends StatefulWidget {
  const AssetHomeScreen({super.key});

  @override
  State<AssetHomeScreen> createState() => _AssetHomeScreenState();
}

class _AssetHomeScreenState extends State<AssetHomeScreen> {
  bool _isValueVisible = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('资产'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: 打开通知中心
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: 打开设置
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          children: [
            // 总资产卡片
            AssetSummaryCard(
              totalValue: 12345.67,
              currency: 'USD',
              change24h: 2.34,
              isValueVisible: _isValueVisible,
              onVisibilityToggle: () {
                setState(() {
                  _isValueVisible = !_isValueVisible;
                });
              },
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // 快捷操作按钮
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    type: ButtonType.outlined,
                    icon: Icons.arrow_upward,
                    onPressed: () {
                      context.push(AppRoutes.transfer);
                    },
                    child: const Text('转账'),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: AppButton(
                    type: ButtonType.outlined,
                    icon: Icons.arrow_downward,
                    onPressed: () {
                      context.push(AppRoutes.receive);
                    },
                    child: const Text('收款'),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: AppButton(
                    type: ButtonType.outlined,
                    icon: Icons.swap_horiz,
                    onPressed: () {
                      context.push(AppRoutes.swap);
                    },
                    child: const Text('兑换'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // 我的资产标题
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '我的资产',
                  style: theme.textTheme.titleLarge,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('添加币种'),
                  onPressed: () {
                    // TODO: 添加币种
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // 资产列表
            _buildAssetList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetList() {
    // TODO: 从状态管理中获取真实数据
    final mockAssets = [
      {
        'symbol': 'ETH',
        'name': 'Ethereum',
        'balance': 2.5634,
        'value': 8234.56,
        'change24h': 1.2,
        'icon': Icons.currency_bitcoin, // 临时使用，后续替换为真实图标
      },
      {
        'symbol': 'USDT',
        'name': 'Tether USD',
        'balance': 4000.0,
        'value': 3998.40,
        'change24h': 0.0,
        'icon': Icons.attach_money,
      },
      {
        'symbol': 'BTC',
        'name': 'Bitcoin',
        'balance': 0.0123,
        'value': 856.78,
        'change24h': -0.8,
        'icon': Icons.monetization_on,
      },
    ];

    return Column(
      children: mockAssets.map((asset) {
        return _AssetListItem(
          symbol: asset['symbol'] as String,
          name: asset['name'] as String,
          balance: asset['balance'] as double,
          value: asset['value'] as double,
          change24h: asset['change24h'] as double,
          icon: asset['icon'] as IconData,
          onTap: () {
            context.push(
              AppRoutes.assetDetail,
              extra: {'symbol': asset['symbol']},
            );
          },
        );
      }).toList(),
    );
  }

  Future<void> _handleRefresh() async {
    // TODO: 刷新资产数据
    await Future.delayed(const Duration(seconds: 1));
  }
}

/// 资产列表项
class _AssetListItem extends StatelessWidget {
  const _AssetListItem({
    required this.symbol,
    required this.name,
    required this.balance,
    required this.value,
    required this.change24h,
    required this.icon,
    required this.onTap,
  });

  final String symbol;
  final String name;
  final double balance;
  final double value;
  final double change24h;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = change24h >= 0;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      onTap: onTap,
      child: Row(
        children: [
          // 币种图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: AppTheme.spacingMd),

          // 币种信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '$balance $symbol',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // 价值和涨跌
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${value.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 16,
                    color: isPositive ? AppTheme.priceUp : AppTheme.priceDown,
                  ),
                  Text(
                    '${change24h.abs().toStringAsFixed(2)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isPositive ? AppTheme.priceUp : AppTheme.priceDown,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
