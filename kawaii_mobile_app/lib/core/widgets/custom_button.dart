import 'package:flutter/material.dart';

enum ButtonVariant {
  primary,
  secondary,
  outline,
  text,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getButtonHeight(),
      child: _buildButton(context, theme, isEnabled),
    );
  }

  Widget _buildButton(BuildContext context, ThemeData theme, bool isEnabled) {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getPrimaryButtonStyle(theme, isEnabled),
          child: _buildButtonContent(theme, isEnabled),
        );
      case ButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getSecondaryButtonStyle(theme, isEnabled),
          child: _buildButtonContent(theme, isEnabled),
        );
      case ButtonVariant.outline:
        return OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getOutlineButtonStyle(theme, isEnabled),
          child: _buildButtonContent(theme, isEnabled),
        );
      case ButtonVariant.text:
        return TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getTextButtonStyle(theme, isEnabled),
          child: _buildButtonContent(theme, isEnabled),
        );
    }
  }

  Widget _buildButtonContent(ThemeData theme, bool isEnabled) {
    if (isLoading) {
      return SizedBox(
        width: _getLoadingSize(),
        height: _getLoadingSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getLoadingColor(theme, isEnabled),
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: _getIconSize(),
            color: _getContentColor(theme, isEnabled),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: _getTextStyle(theme, isEnabled),
          ),
        ],
      );
    }

    return Text(
      text,
      style: _getTextStyle(theme, isEnabled),
    );
  }

  double _getButtonHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  TextStyle _getTextStyle(ThemeData theme, bool isEnabled) {
    final baseStyle = TextStyle(
      fontSize: _getFontSize(),
      fontWeight: FontWeight.w600,
      color: _getContentColor(theme, isEnabled),
    );

    if (textColor != null && isEnabled) {
      return baseStyle.copyWith(color: textColor);
    }

    return baseStyle;
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
    }
  }

  Color _getContentColor(ThemeData theme, bool isEnabled) {
    if (!isEnabled) {
      return Colors.grey[400]!;
    }

    switch (variant) {
      case ButtonVariant.primary:
        return Colors.white;
      case ButtonVariant.secondary:
        return theme.primaryColor;
      case ButtonVariant.outline:
        return theme.primaryColor;
      case ButtonVariant.text:
        return theme.primaryColor;
    }
  }

  Color _getLoadingColor(ThemeData theme, bool isEnabled) {
    switch (variant) {
      case ButtonVariant.primary:
        return Colors.white;
      case ButtonVariant.secondary:
      case ButtonVariant.outline:
      case ButtonVariant.text:
        return theme.primaryColor;
    }
  }

  ButtonStyle _getPrimaryButtonStyle(ThemeData theme, bool isEnabled) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? (isEnabled ? theme.primaryColor : Colors.grey[300]),
      foregroundColor: Colors.white,
      elevation: isEnabled ? 2 : 0,
      shadowColor: theme.primaryColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
      ),
      padding: _getButtonPadding(),
    );
  }

  ButtonStyle _getSecondaryButtonStyle(ThemeData theme, bool isEnabled) {
    return ElevatedButton.styleFrom(
      backgroundColor: isEnabled ? theme.primaryColor.withOpacity(0.1) : Colors.grey[100],
      foregroundColor: theme.primaryColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
      ),
      padding: _getButtonPadding(),
    );
  }

  ButtonStyle _getOutlineButtonStyle(ThemeData theme, bool isEnabled) {
    return OutlinedButton.styleFrom(
      foregroundColor: theme.primaryColor,
      side: BorderSide(
        color: isEnabled ? theme.primaryColor : Colors.grey[300]!,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
      ),
      padding: _getButtonPadding(),
    );
  }

  ButtonStyle _getTextButtonStyle(ThemeData theme, bool isEnabled) {
    return TextButton.styleFrom(
      foregroundColor: theme.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
      ),
      padding: _getButtonPadding(),
    );
  }

  EdgeInsetsGeometry _getButtonPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }
}