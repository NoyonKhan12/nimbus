// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      dialCode: json['dialCode'] as String?,
      photoUrl: json['photoUrl'] as String?,
      nationalId: json['nationalId'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String?,
      homeLocation: json['homeLocation'] == null
          ? null
          : LocationDto.fromJson(json['homeLocation'] as Map<String, dynamic>),
      workLocation: json['workLocation'] == null
          ? null
          : LocationDto.fromJson(json['workLocation'] as Map<String, dynamic>),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'dialCode': instance.dialCode,
      'photoUrl': instance.photoUrl,
      'nationalId': instance.nationalId,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'gender': instance.gender,
      'homeLocation': instance.homeLocation,
      'workLocation': instance.workLocation,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$UpdateUserProfileRequestImpl _$$UpdateUserProfileRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateUserProfileRequestImpl(
      name: json['name'] as String?,
      email: json['email'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String?,
      nationalId: json['nationalId'] as String?,
    );

Map<String, dynamic> _$$UpdateUserProfileRequestImplToJson(
        _$UpdateUserProfileRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'gender': instance.gender,
      'nationalId': instance.nationalId,
    };

_$SavedLocationImpl _$$SavedLocationImplFromJson(Map<String, dynamic> json) =>
    _$SavedLocationImpl(
      id: json['id'] as String,
      label: json['label'] as String,
      address: json['address'] as String,
      location: LocationDto.fromJson(json['location'] as Map<String, dynamic>),
      isFavorite: json['isFavorite'] as bool?,
    );

Map<String, dynamic> _$$SavedLocationImplToJson(_$SavedLocationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'address': instance.address,
      'location': instance.location,
      'isFavorite': instance.isFavorite,
    };

_$SaveLocationRequestImpl _$$SaveLocationRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$SaveLocationRequestImpl(
      label: json['label'] as String,
      address: json['address'] as String,
      location: LocationDto.fromJson(json['location'] as Map<String, dynamic>),
      isFavorite: json['isFavorite'] as bool?,
    );

Map<String, dynamic> _$$SaveLocationRequestImplToJson(
        _$SaveLocationRequestImpl instance) =>
    <String, dynamic>{
      'label': instance.label,
      'address': instance.address,
      'location': instance.location,
      'isFavorite': instance.isFavorite,
    };
