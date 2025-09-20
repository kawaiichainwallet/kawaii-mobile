import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final Color? fillColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.fillColor,
    this.borderColor,
    this.borderRadius = 12,
    this.contentPadding,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          onFieldSubmitted: widget.onSubmitted,
          textCapitalization: widget.textCapitalization,
          textInputAction: widget.textInputAction,
          style: TextStyle(
            fontSize: 16,
            color: widget.enabled ? Colors.black87 : Colors.grey[600],
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            helperText: widget.helperText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused ? theme.primaryColor : Colors.grey[600],
                  )
                : null,
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: widget.fillColor ??
                (widget.enabled
                    ? (_isFocused ? theme.primaryColor.withOpacity(0.05) : Colors.grey[50])
                    : Colors.grey[100]),

            // Label style
            labelStyle: TextStyle(
              color: _isFocused ? theme.primaryColor : Colors.grey[600],
              fontSize: 16,
            ),
            floatingLabelStyle: TextStyle(
              color: theme.primaryColor,
              fontSize: 14,
            ),

            // Hint style
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),

            // Helper style
            helperStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),

            // Error style
            errorStyle: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),

            // Border styles
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: widget.borderColor ?? Colors.grey[300]!,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: widget.borderColor ?? Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: theme.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),

            // Content padding
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

            // Counter style
            counterStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// Specialized text field variants for common use cases
class EmailTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const EmailTextField({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: '邮箱地址',
      hintText: '请输入邮箱地址',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: validator,
      onChanged: onChanged,
    );
  }
}

class PhoneTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PhoneTextField({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: '手机号',
      hintText: '请输入手机号',
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      validator: validator,
      onChanged: onChanged,
    );
  }
}

class PasswordTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PasswordTextField({
    super.key,
    this.controller,
    this.label = '密码',
    this.hintText = '请输入密码',
    this.validator,
    this.onChanged,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      label: widget.label,
      hintText: widget.hintText,
      prefixIcon: Icons.lock_outlined,
      obscureText: _obscureText,
      textInputAction: TextInputAction.done,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey[600],
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
      validator: widget.validator,
      onChanged: widget.onChanged,
    );
  }
}

class OtpTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  const OtpTextField({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: '验证码',
      hintText: '请输入6位验证码',
      prefixIcon: Icons.verified_user_outlined,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      maxLength: 6,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}