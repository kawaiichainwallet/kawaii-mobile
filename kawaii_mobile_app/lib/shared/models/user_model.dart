import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum KYCLevel {
  @JsonValue('level1')
  level1,
  @JsonValue('level2')
  level2,
  @JsonValue('level3')
  level3,
}

enum UserStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('suspended')
  suspended,
  @JsonValue('pending_verification')
  pendingVerification,
}

@JsonSerializable()
class UserModel {
  final int id;
  final String? username;
  final String? phoneNumber;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? avatar;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final KYCLevel kycLevel;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    this.username,
    this.phoneNumber,
    this.email,
    this.firstName,
    this.lastName,
    this.avatar,
    required this.isPhoneVerified,
    required this.isEmailVerified,
    required this.kycLevel,
    this.status = UserStatus.active,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  // JSON serialization
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // Helper getters
  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) {
      return firstName!;
    }
    if (username != null) {
      return username!;
    }
    if (phoneNumber != null) {
      return maskPhoneNumber(phoneNumber!);
    }
    if (email != null) {
      return maskEmail(email!);
    }
    return 'Unknown User';
  }

  String get primaryContact {
    return phoneNumber ?? email ?? '';
  }

  bool get isFullyVerified {
    return isPhoneVerified && isEmailVerified && kycLevel != KYCLevel.level1;
  }

  String get kycLevelDisplayName {
    switch (kycLevel) {
      case KYCLevel.level1:
        return 'L1 基础认证';
      case KYCLevel.level2:
        return 'L2 身份认证';
      case KYCLevel.level3:
        return 'L3 高级认证';
    }
  }

  // Helper methods
  static String maskPhoneNumber(String phone) {
    if (phone.length <= 4) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
  }

  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) return email;
    return '${username.substring(0, 2)}****@$domain';
  }

  // Copy with method
  UserModel copyWith({
    int? id,
    String? username,
    String? phoneNumber,
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
    bool? isPhoneVerified,
    bool? isEmailVerified,
    KYCLevel? kycLevel,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      kycLevel: kycLevel ?? this.kycLevel,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, phoneNumber: $phoneNumber, email: $email, kycLevel: $kycLevel)';
  }
}