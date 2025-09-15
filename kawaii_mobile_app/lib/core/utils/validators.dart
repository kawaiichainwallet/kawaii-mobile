import '../constants/app_constants.dart';

class Validators {
  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号';
    }

    // Remove spaces and special characters
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check if it matches Chinese mobile pattern
    if (!RegExp(AppConstants.phonePattern).hasMatch(cleanPhone)) {
      return '请输入正确的手机号';
    }

    return null;
  }

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱地址';
    }

    if (!RegExp(AppConstants.emailPattern).hasMatch(value)) {
      return '请输入正确的邮箱地址';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return '密码至少需要${AppConstants.minPasswordLength}位';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return '密码不能超过${AppConstants.maxPasswordLength}位';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return '密码必须包含至少一个小写字母';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return '密码必须包含至少一个大写字母';
    }

    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return '密码必须包含至少一个数字';
    }

    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return '密码必须包含至少一个特殊字符';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return '请确认密码';
    }

    if (value != password) {
      return '两次输入的密码不一致';
    }

    return null;
  }

  // OTP validation
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入验证码';
    }

    if (value.length != AppConstants.otpLength) {
      return '验证码应为${AppConstants.otpLength}位数字';
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return '验证码只能包含数字';
    }

    return null;
  }

  // PIN Code validation
  static String? validatePinCode(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入PIN码';
    }

    if (value.length != AppConstants.pinCodeLength) {
      return 'PIN码应为${AppConstants.pinCodeLength}位数字';
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'PIN码只能包含数字';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入姓名';
    }

    if (value.length < 2) {
      return '姓名至少需要2个字符';
    }

    if (value.length > 50) {
      return '姓名不能超过50个字符';
    }

    // Check for valid characters (letters, spaces, Chinese characters)
    if (!RegExp(r'^[a-zA-Z\u4e00-\u9fa5\s]+$').hasMatch(value)) {
      return '姓名只能包含字母、汉字和空格';
    }

    return null;
  }

  // ID Card validation (Chinese)
  static String? validateIdCard(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入身份证号';
    }

    // Remove spaces
    final cleanId = value.replaceAll(' ', '');

    // Check length
    if (cleanId.length != 18) {
      return '身份证号应为18位';
    }

    // Check format
    if (!RegExp(r'^\d{17}[\dXx]$').hasMatch(cleanId)) {
      return '身份证号格式不正确';
    }

    // TODO: Add checksum validation for Chinese ID cards
    return null;
  }

  // Transaction amount validation
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入金额';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return '请输入有效的金额';
    }

    if (amount <= 0) {
      return '金额必须大于0';
    }

    if (amount < AppConstants.minTransactionAmount / 100) {
      return '最小交易金额为 ¥${AppConstants.minTransactionAmount / 100}';
    }

    return null;
  }

  // Generic required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '请输入$fieldName';
    }
    return null;
  }

  // Length validation
  static String? validateLength(String? value, int minLength, int maxLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '请输入$fieldName';
    }

    if (value.length < minLength) {
      return '$fieldName至少需要$minLength个字符';
    }

    if (value.length > maxLength) {
      return '$fieldName不能超过$maxLength个字符';
    }

    return null;
  }

  // Custom regex validation
  static String? validateRegex(String? value, String pattern, String errorMessage) {
    if (value == null || value.isEmpty) {
      return errorMessage;
    }

    if (!RegExp(pattern).hasMatch(value)) {
      return errorMessage;
    }

    return null;
  }
}