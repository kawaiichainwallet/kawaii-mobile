// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  username: json['username'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  email: json['email'] as String?,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  avatar: json['avatar'] as String?,
  isPhoneVerified: json['isPhoneVerified'] as bool,
  isEmailVerified: json['isEmailVerified'] as bool,
  kycLevel: $enumDecode(_$KYCLevelEnumMap, json['kycLevel']),
  status:
      $enumDecodeNullable(_$UserStatusEnumMap, json['status']) ??
      UserStatus.active,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'phoneNumber': instance.phoneNumber,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'avatar': instance.avatar,
  'isPhoneVerified': instance.isPhoneVerified,
  'isEmailVerified': instance.isEmailVerified,
  'kycLevel': _$KYCLevelEnumMap[instance.kycLevel]!,
  'status': _$UserStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'metadata': instance.metadata,
};

const _$KYCLevelEnumMap = {
  KYCLevel.level1: 'level1',
  KYCLevel.level2: 'level2',
  KYCLevel.level3: 'level3',
};

const _$UserStatusEnumMap = {
  UserStatus.active: 'active',
  UserStatus.inactive: 'inactive',
  UserStatus.suspended: 'suspended',
  UserStatus.pendingVerification: 'pending_verification',
};
