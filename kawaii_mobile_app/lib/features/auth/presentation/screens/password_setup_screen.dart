import 'package:flutter/material.dart';

class PasswordSetupScreen extends StatelessWidget {
  final String phoneNumber;
  final String email;

  const PasswordSetupScreen({
    super.key,
    required this.phoneNumber,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置密码'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('密码设置页面 - 开发中'),
            Text('手机号: $phoneNumber'),
            Text('邮箱: $email'),
          ],
        ),
      ),
    );
  }
}