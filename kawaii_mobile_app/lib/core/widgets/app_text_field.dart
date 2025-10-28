import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// 通用文本输入框
///
/// 使用示例：
/// ```dart
/// AppTextField(
///   label: '邮箱地址',
///   hintText: '请输入邮箱',
///   prefixIcon: Icons.email,
///   keyboardType: TextInputType.emailAddress,
/// )
/// ```
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _controller;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: _obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      inputFormatters: widget.inputFormatters,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: _buildSuffixIcon(),
        counterText: '', // 隐藏计数器
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    // 如果是密码输入框，显示显示/隐藏按钮
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    // 如果有自定义后缀图标
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }

    // 如果有内容，显示清除按钮
    if (_controller.text.isNotEmpty && widget.enabled && !widget.readOnly) {
      return IconButton(
        icon: const Icon(Icons.clear, size: 20),
        onPressed: () {
          _controller.clear();
          widget.onChanged?.call('');
        },
      );
    }

    return null;
  }
}

/// 搜索输入框
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hintText = '搜索',
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final String hintText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hintText: hintText,
      prefixIcon: Icons.search,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}

/// PIN码输入框
class AppPinCodeField extends StatefulWidget {
  const AppPinCodeField({
    super.key,
    required this.length,
    required this.onCompleted,
    this.onChanged,
  });

  final int length;
  final void Function(String) onCompleted;
  final void Function(String)? onChanged;

  @override
  State<AppPinCodeField> createState() => _AppPinCodeFieldState();
}

class _AppPinCodeFieldState extends State<AppPinCodeField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _pin => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 50,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            obscureText: true,
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                // 自动跳到下一个输入框
                if (index < widget.length - 1) {
                  _focusNodes[index + 1].requestFocus();
                } else {
                  // 最后一个输入框，完成输入
                  _focusNodes[index].unfocus();
                  widget.onCompleted(_pin);
                }
              }
              widget.onChanged?.call(_pin);
            },
            onTap: () {
              // 点击时清空内容
              _controllers[index].clear();
            },
          ),
        );
      }),
    );
  }
}
