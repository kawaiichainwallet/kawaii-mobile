import 'package:flutter/material.dart';

/// 转账页面
class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('转账'),
      ),
      body: const Center(
        child: Text('转账页面 - 待实现'),
      ),
    );
  }
}
