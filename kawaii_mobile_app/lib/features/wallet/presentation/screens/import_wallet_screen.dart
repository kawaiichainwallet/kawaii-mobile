import 'package:flutter/material.dart';

/// 导入钱包页面
class ImportWalletScreen extends StatelessWidget {
  const ImportWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('导入钱包'),
      ),
      body: const Center(
        child: Text('导入钱包 - 待实现'),
      ),
    );
  }
}
