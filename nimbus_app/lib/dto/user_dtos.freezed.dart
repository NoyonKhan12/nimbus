// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  String get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get dialCode => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  String? get nationalId => throw _privateConstructorUsedError;
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  LocationDto? get homeLocation => throw _privateConstructorUsedError;
  LocationDto? get workLocation => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {String id,
      String? name,
      String? email,
      String? phone,
      String? dialCode,
      String? photoUrl,
      String? nationalId,
      DateTime? dateOfBirth,
      String? gender,
      LocationDto? homeLocation,
      LocationDto? workLocation,
      DateTime? createdAt,
      DateTime? updatedAt});

  $LocationDtoCopyWith<$Res>? get homeLocation;
  $LocationDtoCopyWith<$Res>? get workLocation;
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? dialCode = freezed,
    Object? photoUrl = freezed,
    Object? nationalId = freezed,
    Object? dateOfBirth = freezed,
    Object? gender = freezed,
    Object? homeLocation = freezed,
    Object? workLocation = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      dialCode: freezed == dialCode
          ? _value.dialCode
          : dialCode // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      nationalId: freezed == nationalId
          ? _value.nationalId
          : nationalId // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      homeLocation: freezed == homeLocation
          ? _value.homeLocation
          : homeLocation // ignore: cast_nullable_to_non_nullable
              as LocationDto?,
      workLocation: freezed == workLocation
          ? _value.workLocation
          : workLocation // ignore: cast_nullable_to_non_nullable
              as LocationDto?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $LocationDtoCopyWith<$Res>? get homeLocation {
    if (_value.homeLocation == null) {
      return null;
    }

    return $LocationDtoCopyWith<$Res>(_value.homeLocation!, (value) {
      return _then(_value.copyWith(homeLocation: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LocationDtoCopyWith<$Res>? get workLocation {
    if (_value.workLocation == null) {
      return null;
    }

    return $LocationDtoCopyWith<$Res>(_value.workLocation!, (value) {
      return _then(_value.copyWith(workLocation: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? name,
      String? email,
      String? phone,
      String? dialCode,
      String? photoUrl,
      String? nationalId,
      DateTime? dateOfBirth,
      String? gender,
      LocationDto? homeLocation,
      LocationDto? workLocation,
      DateTime? createdAt,
      DateTime? updatedAt});

  @override
  $LocationDtoCopyWith<$Res>? get homeLocation;
  @override
  $LocationDtoCopyWith<$Res>? get workLocation;
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? dialCode = freezed,
    Object? photoUrl = freezed,
    Object? nationalId = freezed,
    Object? dateOfBirth = freezed,
    Object? gender = freezed,
    Object? homeLocation = freezed,
    Object? workLocation = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$UserProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      dialCode: freezed == dialCode
          ? _value.dialCode
          : dialCode // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      nationalId: freezed == nationalId
          ? _value.nationalId
          : nationalId // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      homeLocation: freezed == homeLocation
          ? _value.homeLocation
          : homeLocation // ignore: cast_nullable_to_non_nullable
              as LocationDto?,
      workLocation: freezed == workLocation
          ? _value.workLocation
          : workLocation // ignore: cast_nullable_to_non_nullable
              as LocationDto?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl(
      {required this.id,
      this.name,
      this.email,
      this.phone,
      this.dialCode,
      this.photoUrl,
      this.nationalId,
      this.dateOfBirth,
      this.gender,
      this.homeLocation,
      this.workLocation,
      this.createdAt,
      this.updatedAt});

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String? name;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final String? dialCode;
  @override
  final String? photoUrl;
  @override
  final String? nationalId;
  @override
  final DateTime? dateOfBirth;
  @override
  final String? gender;
  @override
  final LocationDto? homeLocation;
  @override
  final LocationDto? workLocation;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, email: $email, phone: $phone, dialCode: $dialCode, photoUrl: $photoUrl, nationalId: $nationalId, dateOfBirth: $dateOfBirth, gender: $gender, homeLocation: $homeLocation, workLocation: $workLocation, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.dialCode, dialCode) ||
                other.dialCode == dialCode) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.nationalId, nationalId) ||
                other.nationalId == nationalId) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.homeLocation, homeLocation) ||
                other.homeLocation == homeLocation) &&
            (identical(other.workLocation, workLocation) ||
                other.workLocation == workLocation) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      email,
      phone,
      dialCode,
      photoUrl,
      nationalId,
      dateOfBirth,
      gender,
      homeLocation,
      workLocation,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(
      this,
    );
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile(
      {required final String id,
      final String? name,
      final String? email,
      final String? phone,
      final String? dialCode,
      final String? photoUrl,
      final String? nationalId,
      final DateTime? dateOfBirth,
      final String? gender,
      final LocationDto? homeLocation,
      final LocationDto? workLocation,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get id;
  @override
  String? get name;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  String? get dialCode;
  @override
  String? get photoUrl;
  @override
  String? get nationalId;
  @override
  DateTime? get dateOfBirth;
  @override
  String? get gender;
  @override
  LocationDto? get homeLocation;
  @override
  LocationDto? get workLocation;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateUserProfileRequest _$UpdateUserProfileRequestFromJson(
    Map<String, dynamic> json) {
  return _UpdateUserProfileRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateUserProfileRequest {
  String? get name => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String? get nationalId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdateUserProfileRequestCopyWith<UpdateUserProfileRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateUserProfileRequestCopyWith<$Res> {
  factory $UpdateUserProfileRequestCopyWith(UpdateUserProfileRequest value,
          $Res Function(UpdateUserProfileRequest) then) =
      _$UpdateUserProfileRequestCopyWithImpl<$Res, UpdateUserProfileRequest>;
  @useResult
  $Res call(
      {String? name,
      String? email,
      DateTime? dateOfBirth,
      String? gender,
      String? nationalId});
}

/// @nodoc
class _$UpdateUserProfileRequestCopyWithImpl<$Res,
        $Val extends UpdateUserProfileRequest>
    implements $UpdateUserProfileRequestCopyWith<$Res> {
  _$UpdateUserProfileRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? email = freezed,
    Object? dateOfBirth = freezed,
    Object? gender = freezed,
    Object? nationalId = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      nationalId: freezed == nationalId
          ? _value.nationalId
          : nationalId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpdateUserProfileRequestImplCopyWith<$Res>
    implements $UpdateUserProfileRequestCopyWith<$Res> {
  factory _$$UpdateUserProfileRequestImplCopyWith(
          _$UpdateUserProfileRequestImpl value,
          $Res Function(_$UpdateUserProfileRequestImpl) then) =
      __$$UpdateUserProfileRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? name,
      String? email,
      DateTime? dateOfBirth,
      String? gender,
      String? nationalId});
}

/// @nodoc
class __$$UpdateUserProfileRequestImplCopyWithImpl<$Res>
    extends _$UpdateUserProfileRequestCopyWithImpl<$Res,
        _$UpdateUserProfileRequestImpl>
    implements _$$UpdateUserProfileRequestImplCopyWith<$Res> {
  __$$UpdateUserProfileRequestImplCopyWithImpl(
      _$UpdateUserProfileRequestImpl _value,
      $Res Function(_$UpdateUserProfileRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? email = freezed,
    Object? dateOfBirth = freezed,
    Object? gender = freezed,
    Object? nationalId = freezed,
  }) {
    return _then(_$UpdateUserProfileRequestImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      nationalId: freezed == nationalId
          ? _value.nationalId
          : nationalId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateUserProfileRequestImpl implements _UpdateUserProfileRequest {
  const _$UpdateUserProfileRequestImpl(
      {this.name, this.email, this.dateOfBirth, this.gender, this.nationalId});

  factory _$UpdateUserProfileRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateUserProfileRequestImplFromJson(json);

  @override
  final String? name;
  @override
  final String? email;
  @override
  final DateTime? dateOfBirth;
  @override
  final String? gender;
  @override
  final String? nationalId;

  @override
  String toString() {
    return 'UpdateUserProfileRequest(name: $name, email: $email, dateOfBirth: $dateOfBirth, gender: $gender, nationalId: $nationalId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateUserProfileRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.nationalId, nationalId) ||
                other.nationalId == nationalId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, email, dateOfBirth, gender, nationalId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateUserProfileRequestImplCopyWith<_$UpdateUserProfileRequestImpl>
      get copyWith => __$$UpdateUserProfileRequestImplCopyWithImpl<
          _$UpdateUserProfileRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateUserProfileRequestImplToJson(
      this,
    );
  }
}

abstract class _UpdateUserProfileRequest implements UpdateUserProfileRequest {
  const factory _UpdateUserProfileRequest(
      {final String? name,
      final String? email,
      final DateTime? dateOfBirth,
      final String? gender,
      final String? nationalId}) = _$UpdateUserProfileRequestImpl;

  factory _UpdateUserProfileRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateUserProfileRequestImpl.fromJson;

  @override
  String? get name;
  @override
  String? get email;
  @override
  DateTime? get dateOfBirth;
  @override
  String? get gender;
  @override
  String? get nationalId;
  @override
  @JsonKey(ignore: true)
  _$$UpdateUserProfileRequestImplCopyWith<_$UpdateUserProfileRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SavedLocation _$SavedLocationFromJson(Map<String, dynamic> json) {
  return _SavedLocation.fromJson(json);
}

/// @nodoc
mixin _$SavedLocation {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  LocationDto get location => throw _privateConstructorUsedError;
  bool? get isFavorite => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SavedLocationCopyWith<SavedLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavedLocationCopyWith<$Res> {
  factory $SavedLocationCopyWith(
          SavedLocation value, $Res Function(SavedLocation) then) =
      _$SavedLocationCopyWithImpl<$Res, SavedLocation>;
  @useResult
  $Res call(
      {String id,
      String label,
      String address,
      LocationDto location,
      bool? isFavorite});

  $LocationDtoCopyWith<$Res> get location;
}

/// @nodoc
class _$SavedLocationCopyWithImpl<$Res, $Val extends SavedLocation>
    implements $SavedLocationCopyWith<$Res> {
  _$SavedLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? address = null,
    Object? location = null,
    Object? isFavorite = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      isFavorite: freezed == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $LocationDtoCopyWith<$Res> get location {
    return $LocationDtoCopyWith<$Res>(_value.location, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SavedLocationImplCopyWith<$Res>
    implements $SavedLocationCopyWith<$Res> {
  factory _$$SavedLocationImplCopyWith(
          _$SavedLocationImpl value, $Res Function(_$SavedLocationImpl) then) =
      __$$SavedLocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String label,
      String address,
      LocationDto location,
      bool? isFavorite});

  @override
  $LocationDtoCopyWith<$Res> get location;
}

/// @nodoc
class __$$SavedLocationImplCopyWithImpl<$Res>
    extends _$SavedLocationCopyWithImpl<$Res, _$SavedLocationImpl>
    implements _$$SavedLocationImplCopyWith<$Res> {
  __$$SavedLocationImplCopyWithImpl(
      _$SavedLocationImpl _value, $Res Function(_$SavedLocationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? address = null,
    Object? location = null,
    Object? isFavorite = freezed,
  }) {
    return _then(_$SavedLocationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      isFavorite: freezed == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SavedLocationImpl implements _SavedLocation {
  const _$SavedLocationImpl(
      {required this.id,
      required this.label,
      required this.address,
      required this.location,
      this.isFavorite});

  factory _$SavedLocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$SavedLocationImplFromJson(json);

  @override
  final String id;
  @override
  final String label;
  @override
  final String address;
  @override
  final LocationDto location;
  @override
  final bool? isFavorite;

  @override
  String toString() {
    return 'SavedLocation(id: $id, label: $label, address: $address, location: $location, isFavorite: $isFavorite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavedLocationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, label, address, location, isFavorite);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SavedLocationImplCopyWith<_$SavedLocationImpl> get copyWith =>
      __$$SavedLocationImplCopyWithImpl<_$SavedLocationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SavedLocationImplToJson(
      this,
    );
  }
}

abstract class _SavedLocation implements SavedLocation {
  const factory _SavedLocation(
      {required final String id,
      required final String label,
      required final String address,
      required final LocationDto location,
      final bool? isFavorite}) = _$SavedLocationImpl;

  factory _SavedLocation.fromJson(Map<String, dynamic> json) =
      _$SavedLocationImpl.fromJson;

  @override
  String get id;
  @override
  String get label;
  @override
  String get address;
  @override
  LocationDto get location;
  @override
  bool? get isFavorite;
  @override
  @JsonKey(ignore: true)
  _$$SavedLocationImplCopyWith<_$SavedLocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SaveLocationRequest _$SaveLocationRequestFromJson(Map<String, dynamic> json) {
  return _SaveLocationRequest.fromJson(json);
}

/// @nodoc
mixin _$SaveLocationRequest {
  String get label => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  LocationDto get location => throw _privateConstructorUsedError;
  bool? get isFavorite => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SaveLocationRequestCopyWith<SaveLocationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SaveLocationRequestCopyWith<$Res> {
  factory $SaveLocationRequestCopyWith(
          SaveLocationRequest value, $Res Function(SaveLocationRequest) then) =
      _$SaveLocationRequestCopyWithImpl<$Res, SaveLocationRequest>;
  @useResult
  $Res call(
      {String label, String address, LocationDto location, bool? isFavorite});

  $LocationDtoCopyWith<$Res> get location;
}

/// @nodoc
class _$SaveLocationRequestCopyWithImpl<$Res, $Val extends SaveLocationRequest>
    implements $SaveLocationRequestCopyWith<$Res> {
  _$SaveLocationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? address = null,
    Object? location = null,
    Object? isFavorite = freezed,
  }) {
    return _then(_value.copyWith(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      isFavorite: freezed == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $LocationDtoCopyWith<$Res> get location {
    return $LocationDtoCopyWith<$Res>(_value.location, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SaveLocationRequestImplCopyWith<$Res>
    implements $SaveLocationRequestCopyWith<$Res> {
  factory _$$SaveLocationRequestImplCopyWith(_$SaveLocationRequestImpl value,
          $Res Function(_$SaveLocationRequestImpl) then) =
      __$$SaveLocationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String label, String address, LocationDto location, bool? isFavorite});

  @override
  $LocationDtoCopyWith<$Res> get location;
}

/// @nodoc
class __$$SaveLocationRequestImplCopyWithImpl<$Res>
    extends _$SaveLocationRequestCopyWithImpl<$Res, _$SaveLocationRequestImpl>
    implements _$$SaveLocationRequestImplCopyWith<$Res> {
  __$$SaveLocationRequestImplCopyWithImpl(_$SaveLocationRequestImpl _value,
      $Res Function(_$SaveLocationRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? address = null,
    Object? location = null,
    Object? isFavorite = freezed,
  }) {
    return _then(_$SaveLocationRequestImpl(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      isFavorite: freezed == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SaveLocationRequestImpl implements _SaveLocationRequest {
  const _$SaveLocationRequestImpl(
      {required this.label,
      required this.address,
      required this.location,
      this.isFavorite});

  factory _$SaveLocationRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SaveLocationRequestImplFromJson(json);

  @override
  final String label;
  @override
  final String address;
  @override
  final LocationDto location;
  @override
  final bool? isFavorite;

  @override
  String toString() {
    return 'SaveLocationRequest(label: $label, address: $address, location: $location, isFavorite: $isFavorite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaveLocationRequestImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, label, address, location, isFavorite);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SaveLocationRequestImplCopyWith<_$SaveLocationRequestImpl> get copyWith =>
      __$$SaveLocationRequestImplCopyWithImpl<_$SaveLocationRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SaveLocationRequestImplToJson(
      this,
    );
  }
}

abstract class _SaveLocationRequest implements SaveLocationRequest {
  const factory _SaveLocationRequest(
      {required final String label,
      required final String address,
      required final LocationDto location,
      final bool? isFavorite}) = _$SaveLocationRequestImpl;

  factory _SaveLocationRequest.fromJson(Map<String, dynamic> json) =
      _$SaveLocationRequestImpl.fromJson;

  @override
  String get label;
  @override
  String get address;
  @override
  LocationDto get location;
  @override
  bool? get isFavorite;
  @override
  @JsonKey(ignore: true)
  _$$SaveLocationRequestImplCopyWith<_$SaveLocationRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
