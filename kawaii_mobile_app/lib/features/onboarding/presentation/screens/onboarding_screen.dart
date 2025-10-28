import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_button.dart';

/// 欢迎引导页数据模型
class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// 欢迎引导页面
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      title: '安全存储你的数字资产',
      subtitle: '银行级安全保障',
      description: '采用AES-256加密技术，私钥本地存储\n永远不会上传到服务器',
      icon: Icons.security,
      color: AppTheme.primaryColor,
    ),
    OnboardingPage(
      title: '随时随地快速转账',
      subtitle: '秒级到账',
      description: '支持ETH、BTC、USDT等主流数字货币\n转账收款只需几秒钟',
      icon: Icons.swap_horiz,
      color: AppTheme.secondaryColor,
    ),
    OnboardingPage(
      title: '生活缴费，加密货币也能用',
      subtitle: '一站式生活服务',
      description: '水电燃气、话费充值、信用卡还款\n数字货币直接支付日常账单',
      icon: Icons.payment,
      color: AppTheme.accentColor,
    ),
    OnboardingPage(
      title: '开始你的 Web3 之旅',
      subtitle: '简单易用',
      description: '专为新手设计的友好界面\n5分钟即可上手使用',
      icon: Icons.rocket_launch,
      color: AppTheme.primaryColor,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToAuthSelection();
    }
  }

  void _skipToAuthSelection() {
    _goToAuthSelection();
  }

  void _goToAuthSelection() {
    context.go(AppRoutes.authSelection);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipToAuthSelection,
                  child: const Text('跳过'),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: page.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Icon(
                            page.icon,
                            size: 70,
                            color: page.color,
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacing2xl),

                        // Title
                        Text(
                          page.title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: page.color,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppTheme.spacingMd),

                        // Subtitle
                        Text(
                          page.subtitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppTheme.spacingLg),

                        // Description
                        Text(
                          page.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Section
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _pages[_currentPage].color
                              : AppTheme.textDisabled,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingXl),

                  // Next/Get Started Button
                  AppButton(
                    fullWidth: true,
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == _pages.length - 1 ? '立即开始' : '下一步',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
