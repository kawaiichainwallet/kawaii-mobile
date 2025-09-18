/// 验证工具类
class ValidationUtils {
  // 手机号正则表达式（中国大陆）
  static final RegExp _phoneRegExp = RegExp(r'^1[3-9]\d{9}$');

  // 邮箱正则表达式
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  );

  // 用户名正则表达式（3-20位，字母数字下划线）
  static final RegExp _usernameRegExp = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  // 密码强度正则表达式（8-20位，至少包含一个大写字母、一个小写字母、一个数字）
  static final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,20}$'
  );

  /// 验证手机号
  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return '请输入手机号';
    }

    if (!_phoneRegExp.hasMatch(phone)) {
      return '请输入有效的11位手机号';
    }

    return null;
  }

  /// 验证邮箱
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return '请输入邮箱地址';
    }

    if (!_emailRegExp.hasMatch(email)) {
      return '请输入有效的邮箱地址';
    }

    return null;
  }

  /// 验证用户名
  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return '请输入用户名';
    }

    if (username.length < 3 || username.length > 20) {
      return '用户名长度必须在3-20位之间';
    }

    if (!_usernameRegExp.hasMatch(username)) {
      return '用户名只能包含字母、数字和下划线';
    }

    return null;
  }

  /// 验证密码
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return '请输入密码';
    }

    if (password.length < 8 || password.length > 20) {
      return '密码长度必须在8-20位之间';
    }

    if (!_passwordRegExp.hasMatch(password)) {
      return '密码必须包含至少一个大写字母、一个小写字母和一个数字';
    }

    return null;
  }

  /// 验证验证码
  static String? validateOtpCode(String? code) {
    if (code == null || code.isEmpty) {
      return '请输入验证码';
    }

    if (code.length != 6) {
      return '验证码必须是6位数字';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return '验证码格式不正确';
    }

    return null;
  }

  /// 验证是否为空
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName不能为空';
    }
    return null;
  }

  /// 验证字符串长度
  static String? validateLength(
    String? value,
    String fieldName,
    int minLength,
    int maxLength
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName不能为空';
    }

    if (value.length < minLength || value.length > maxLength) {
      return '$fieldName长度必须在$minLength-$maxLength位之间';
    }

    return null;
  }

  /// 验证确认密码
  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return '请确认密码';
    }

    if (password != confirmPassword) {
      return '两次输入的密码不一致';
    }

    return null;
  }

  /// 检查是否是有效的手机号格式
  static bool isValidPhone(String phone) {
    return _phoneRegExp.hasMatch(phone);
  }

  /// 检查是否是有效的邮箱格式
  static bool isValidEmail(String email) {
    return _emailRegExp.hasMatch(email);
  }

  /// 脱敏手机号（保留前3位和后4位）
  static String maskPhone(String phone) {
    if (phone.length != 11) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(7)}';
  }

  /// 脱敏邮箱（保留前2位和@域名）
  static String maskEmail(String email) {
    final atIndex = email.indexOf('@');
    if (atIndex <= 2) return email;

    final prefix = email.substring(0, 2);
    final suffix = email.substring(atIndex);
    return '$prefix****$suffix';
  }
}