import 'package:flutter/material.dart';
import '../../../assets/presentation/screens/asset_home_screen.dart';
import '../../../trade/presentation/screens/trade_home_screen.dart';
import '../../../life/presentation/screens/life_service_home_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

/// 主屏幕 - 带底部导航栏
///
/// 包含4个Tab:
/// - 资产
/// - 交易
/// - 生活
/// - 我的
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AssetHomeScreen(),
    TradeHomeScreen(),
    LifeServiceHomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: '资产',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_outlined),
            activeIcon: Icon(Icons.swap_horiz),
            label: '交易',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store),
            label: '生活',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
