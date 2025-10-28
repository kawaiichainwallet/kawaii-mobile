import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 按钮类型
enum ButtonType {
  primary, // 主按钮
  secondary, // 次要按钮
  outlined, // 描边按钮
  text, // 文本按钮
  danger, // 危险按钮
}

/// 按钮尺寸
enum ButtonSize {
  small, // 小按钮 - 高度36
  medium, // 中按钮 - 高度48
  large, // 大按钮 - 高度56
}

/// 通用应用按钮
///
/// 使用示例：
/// ```dart
/// AppButton(
///   onPressed: () {},
///   child: const Text('确认'),
/// )
///
/// AppButton(
///   type: ButtonType.outlined,
///   size: ButtonSize.small,
///   isLoading: true,
///   onPressed: () {},
///   child: const Text('提交'),
/// )
/// ```
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = false,
    this.icon,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = !isDisabled && !isLoading;

    // 按钮高度
    final double height = switch (size) {
      ButtonSize.small => 36,
      ButtonSize.medium => 48,
      ButtonSize.large => 56,
    };

    // 按钮内容
    Widget buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == ButtonType.primary ? Colors.white : AppTheme.primaryColor,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppTheme.spacingSm),
              ],
              child,
            ],
          );

    // 按钮样式
    final ButtonStyle buttonStyle = switch (type) {
      ButtonType.primary => ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.textDisabled,
          disabledForegroundColor: Colors.white,
          minimumSize: Size(fullWidth ? double.infinity : 0, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
      ButtonType.secondary => ElevatedButton.styleFrom(
          backgroundColor: AppTheme.secondaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.textDisabled,
          disabledForegroundColor: Colors.white,
          minimumSize: Size(fullWidth ? double.infinity : 0, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
      ButtonType.danger => ElevatedButton.styleFrom(
          backgroundColor: AppTheme.errorColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.textDisabled,
          disabledForegroundColor: Colors.white,
          minimumSize: Size(fullWidth ? double.infinity : 0, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
      ButtonType.outlined => OutlinedButton.styleFrom(
          side: BorderSide(color: isEnabled ? AppTheme.primaryColor : AppTheme.textDisabled),
          foregroundColor: isEnabled ? AppTheme.primaryColor : AppTheme.textDisabled,
          minimumSize: Size(fullWidth ? double.infinity : 0, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
      ButtonType.text => TextButton.styleFrom(
          foregroundColor: isEnabled ? AppTheme.primaryColor : AppTheme.textDisabled,
          minimumSize: Size(fullWidth ? double.infinity : 0, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
    };

    // 构建按钮
    final Widget button = switch (type) {
      ButtonType.outlined => OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: buttonStyle,
          child: buttonChild,
        ),
      ButtonType.text => TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: buttonStyle,
          child: buttonChild,
        ),
      _ => ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: buttonStyle,
          child: buttonChild,
        ),
    };

    return fullWidth
        ? SizedBox(
            width: double.infinity,
            child: button,
          )
        : button;
  }
}
