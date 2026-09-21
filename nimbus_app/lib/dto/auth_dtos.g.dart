// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SendOtpRequestImpl _$$SendOtpRequestImplFromJson(Map<String, dynamic> json) =>
    _$SendOtpRequestImpl(
      phone: json['phone'] as String,
      dialCode: json['dialCode'] as String,
    );

Map<String, dynamic> _$$SendOtpRequestImplToJson(
        _$SendOtpRequestImpl instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'dialCode': instance.dialCode,
    };

_$VerifyOtpRequestImpl _$$VerifyOtpRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$VerifyOtpRequestImpl(
      phone: json['phone'] as String,
      dialCode: json['dialCode'] as String,
      code: json['code'] as String,
      termsAccepted: json['termsAccepted'] as bool?,
    );

Map<String, dynamic> _$$VerifyOtpRequestImplToJson(
        _$VerifyOtpRequestImpl instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'dialCode': instance.dialCode,
      'code': instance.code,
      'termsAccepted': instance.termsAccepted,
    };

_$AuthTokensImpl _$$AuthTokensImplFromJson(Map<String, dynamic> json) =>
    _$AuthTokensImpl(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      accessTokenExpiresAt:
          DateTime.parse(json['accessTokenExpiresAt'] as String),
      refreshTokenExpiresAt:
          DateTime.parse(json['refreshTokenExpiresAt'] as String),
      sessionId: json['sessionId'] as String?,
    );

Map<String, dynamic> _$$AuthTokensImplToJson(_$AuthTokensImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'accessTokenExpiresAt': instance.accessTokenExpiresAt.toIso8601String(),
      'refreshTokenExpiresAt': instance.refreshTokenExpiresAt.toIso8601String(),
      'sessionId': instance.sessionId,
    };

_$RefreshTokenResponseImpl _$$RefreshTokenResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$RefreshTokenResponseImpl(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      accessTokenExpiresAt:
          DateTime.parse(json['accessTokenExpiresAt'] as String),
      refreshTokenExpiresAt:
          DateTime.parse(json['refreshTokenExpiresAt'] as String),
      sessionId: json['sessionId'] as String?,
    );

Map<String, dynamic> _$$RefreshTokenResponseImplToJson(
        _$RefreshTokenResponseImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'accessTokenExpiresAt': instance.accessTokenExpiresAt.toIso8601String(),
      'refreshTokenExpiresAt': instance.refreshTokenExpiresAt.toIso8601String(),
      'sessionId': instance.sessionId,
    };

_$UserSessionImpl _$$UserSessionImplFromJson(Map<String, dynamic> json) =>
    _$UserSessionImpl(
      sessionId: json['sessionId'] as String,
      deviceInfo: json['deviceInfo'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: json['lastUsedAt'] == null
          ? null
          : DateTime.parse(json['lastUsedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$$UserSessionImplToJson(_$UserSessionImpl instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'deviceInfo': instance.deviceInfo,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastUsedAt': instance.lastUsedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };
