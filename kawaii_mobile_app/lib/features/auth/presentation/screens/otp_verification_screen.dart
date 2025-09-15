import 'package:flutter/material.dart';

class OTPVerificationScreen extends StatelessWidget {
  final String phoneNumber;
  final String email;
  final String verificationType;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.email,
    required this.verificationType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('验证码验证'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('验证码验证页面 - 开发中'),
            Text('手机号: $phoneNumber'),
            Text('邮箱: $email'),
            Text('验证类型: $verificationType'),
          ],
        ),
      ),
    );
  }
}