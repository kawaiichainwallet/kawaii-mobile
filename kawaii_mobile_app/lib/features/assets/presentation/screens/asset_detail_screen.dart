import 'package:flutter/material.dart';

/// 资产详情页
class AssetDetailScreen extends StatelessWidget {
  const AssetDetailScreen({
    super.key,
    required this.symbol,
  });

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$symbol 详情'),
      ),
      body: Center(
        child: Text('$symbol 资产详情页 - 待实现'),
      ),
    );
  }
}
