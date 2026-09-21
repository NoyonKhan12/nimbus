// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DriverApplicationRequest _$DriverApplicationRequestFromJson(
    Map<String, dynamic> json) {
  return _DriverApplicationRequest.fromJson(json);
}

/// @nodoc
mixin _$DriverApplicationRequest {
  String get licenseNumber => throw _privateConstructorUsedError;
  String get nationalId => throw _privateConstructorUsedError;
  String get vehicleId => throw _privateConstructorUsedError;
  String get drivingLicensePhoto => throw _privateConstructorUsedError;
  String get nationalIdPhoto => throw _privateConstructorUsedError;
  String? get vehicleRegistrationPhoto => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DriverApplicationRequestCopyWith<DriverApplicationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverApplicationRequestCopyWith<$Res> {
  factory $DriverApplicationRequestCopyWith(DriverApplicationRequest value,
          $Res Function(DriverApplicationRequest) then) =
      _$DriverApplicationRequestCopyWithImpl<$Res, DriverApplicationRequest>;
  @useResult
  $Res call(
      {String licenseNumber,
      String nationalId,
      String vehicleId,
      String drivingLicensePhoto,
      String nationalIdPhoto,
      String? vehicleRegistrationPhoto});
}

/// @nodoc
class _$DriverApplicationRequestCopyWithImpl<$Res,
        $Val extends DriverApplicationRequest>
    implements $DriverApplicationRequestCopyWith<$Res> {
  _$DriverApplicationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? licenseNumber = null,
    Object? nationalId = null,
    Object? vehicleId = null,
    Object? drivingLicensePhoto = null,
    Object? nationalIdPhoto = null,
    Object? vehicleRegistrationPhoto = freezed,
  }) {
    return _then(_value.copyWith(
      licenseNumber: null == licenseNumber
          ? _value.licenseNumber
          : licenseNumber // ignore: cast_nullable_to_non_nullable
              as String,
      nationalId: null == nationalId
          ? _value.nationalId
          : nationalId // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleId: null == vehicleId
          ? _value.vehicleId
          : vehicleId // ignore: cast_nullable_to_non_nullable
              as String,
      drivingLicensePhoto: null == drivingLicensePhoto
          ? _value.drivingLicensePhoto
          : drivingLicensePhoto // ignore: cast_nullable_to_non_nullable
              as String,
      nationalIdPhoto: null == nationalIdPhoto
          ? _value.nationalIdPhoto
          : nationalIdPhoto // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleRegistrationPhoto: freezed == vehicleRegistrationPhoto
          ? _value.vehicleRegistrationPhoto
          : vehicleRegistrationPhoto // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DriverApplicationRequestImplCopyWith<$Res>
    implements $DriverApplicationRequestCopyWith<$Res> {
  factory _$$DriverApplicationRequestImplCopyWith(
          _$DriverApplicationRequestImpl value,
          $Res Function(_$DriverApplicationRequestImpl) then) =
      __$$DriverApplicationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String licenseNumber,
      String nationalId,
      String vehicleId,
      String drivingLicensePhoto,
      String nationalIdPhoto,
      String? vehicleRegistrationPhoto});
}

/// @nodoc
class __$$DriverApplicationRequestImplCopyWithImpl<$Res>
    extends _$DriverApplicationRequestCopyWithImpl<$Res,
        _$DriverApplicationRequestImpl>
    implements _$$DriverApplicationRequestImplCopyWith<$Res> {
  __$$DriverApplicationRequestImplCopyWithImpl(
      _$DriverApplicationRequestImpl _value,
      $Res Function(_$DriverApplicationRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? licenseNumber = null,
    Object? nationalId = null,
    Object? vehicleId = null,
    Object? drivingLicensePhoto = null,
    Object? nationalIdPhoto = null,
    Object? vehicleRegistrationPhoto = freezed,
  }) {
    return _then(_$DriverApplicationRequestImpl(
      licenseNumber: null == licenseNumber
          ? _value.licenseNumber
          : licenseNumber // ignore: cast_nullable_to_non_nullable
              as String,
      nationalId: null == nationalId
          ? _value.nationalId
          : nationalId // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleId: null == vehicleId
          ? _value.vehicleId
          : vehicleId // ignore: cast_nullable_to_non_nullable
              as String,
      drivingLicensePhoto: null == drivingLicensePhoto
          ? _value.drivingLicensePhoto
          : drivingLicensePhoto // ignore: cast_nullable_to_non_nullable
              as String,
      nationalIdPhoto: null == nationalIdPhoto
          ? _value.nationalIdPhoto
          : nationalIdPhoto // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleRegistrationPhoto: freezed == vehicleRegistrationPhoto
          ? _value.vehicleRegistrationPhoto
          : vehicleRegistrationPhoto // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverApplicationRequestImpl implements _DriverApplicationRequest {
  const _$DriverApplicationRequestImpl(
      {required this.licenseNumber,
      required this.nationalId,
      required this.vehicleId,
      required this.drivingLicensePhoto,
      required this.nationalIdPhoto,
      this.vehicleRegistrationPhoto});

  factory _$DriverApplicationRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverApplicationRequestImplFromJson(json);

  @override
  final String licenseNumber;
  @override
  final String nationalId;
  @override
  final String vehicleId;
  @override
  final String drivingLicensePhoto;
  @override
  final String nationalIdPhoto;
  @override
  final String? vehicleRegistrationPhoto;

  @override
  String toString() {
    return 'DriverApplicationRequest(licenseNumber: $licenseNumber, nationalId: $nationalId, vehicleId: $vehicleId, drivingLicensePhoto: $drivingLicensePhoto, nationalIdPhoto: $nationalIdPhoto, vehicleRegistrationPhoto: $vehicleRegistrationPhoto)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverApplicationRequestImpl &&
            (identical(other.licenseNumber, licenseNumber) ||
                other.licenseNumber == licenseNumber) &&
            (identical(other.nationalId, nationalId) ||
                other.nationalId == nationalId) &&
            (identical(other.vehicleId, vehicleId) ||
                other.vehicleId == vehicleId) &&
            (identical(other.drivingLicensePhoto, drivingLicensePhoto) ||
                other.drivingLicensePhoto == drivingLicensePhoto) &&
            (identical(other.nationalIdPhoto, nationalIdPhoto) ||
                other.nationalIdPhoto == nationalIdPhoto) &&
            (identical(
                    other.vehicleRegistrationPhoto, vehicleRegistrationPhoto) ||
                other.vehicleRegistrationPhoto == vehicleRegistrationPhoto));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      licenseNumber,
      nationalId,
      vehicleId,
      drivingLicensePhoto,
      nationalIdPhoto,
      vehicleRegistrationPhoto);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverApplicationRequestImplCopyWith<_$DriverApplicationRequestImpl>
      get copyWith => __$$DriverApplicationRequestImplCopyWithImpl<
          _$DriverApplicationRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverApplicationRequestImplToJson(
      this,
    );
  }
}

abstract class _DriverApplicationRequest implements DriverApplicationRequest {
  const factory _DriverApplicationRequest(
      {required final String licenseNumber,
      required final String nationalId,
      required final String vehicleId,
      required final String drivingLicensePhoto,
      required final String nationalIdPhoto,
      final String? vehicleRegistrationPhoto}) = _$DriverApplicationRequestImpl;

  factory _DriverApplicationRequest.fromJson(Map<String, dynamic> json) =
      _$DriverApplicationRequestImpl.fromJson;

  @override
  String get licenseNumber;
  @override
  String get nationalId;
  @override
  String get vehicleId;
  @override
  String get drivingLicensePhoto;
  @override
  String get nationalIdPhoto;
  @override
  String? get vehicleRegistrationPhoto;
  @override
  @JsonKey(ignore: true)
  _$$DriverApplicationRequestImplCopyWith<_$DriverApplicationRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

DriverApplication _$DriverApplicationFromJson(Map<String, dynamic> json) {
  return _DriverApplication.fromJson(json);
}

/// @nodoc
mixin _$DriverApplication {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get submittedAt => throw _privateConstructorUsedError;
  DateTime? get reviewedAt => throw _privateConstructorUsedError;
  String? get reviewedBy => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DriverApplicationCopyWith<DriverApplication> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverApplicationCopyWith<$Res> {
  factory $DriverApplicationCopyWith(
          DriverApplication value, $Res Function(DriverApplication) then) =
      _$DriverApplicationCopyWithImpl<$Res, DriverApplication>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String status,
      DateTime? submittedAt,
      DateTime? reviewedAt,
      String? reviewedBy,
      String? rejectionReason});
}

/// @nodoc
class _$DriverApplicationCopyWithImpl<$Res, $Val extends DriverApplication>
    implements $DriverApplicationCopyWith<$Res> {
  _$DriverApplicationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? status = null,
    Object? submittedAt = freezed,
    Object? reviewedAt = freezed,
    Object? reviewedBy = freezed,
    Object? rejectionReason = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      submittedAt: freezed == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedBy: freezed == reviewedBy
          ? _value.reviewedBy
          : reviewedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DriverApplicationImplCopyWith<$Res>
    implements $DriverApplicationCopyWith<$Res> {
  factory _$$DriverApplicationImplCopyWith(_$DriverApplicationImpl value,
          $Res Function(_$DriverApplicationImpl) then) =
      __$$DriverApplicationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String status,
      DateTime? submittedAt,
      DateTime? reviewedAt,
      String? reviewedBy,
      String? rejectionReason});
}

/// @nodoc
class __$$DriverApplicationImplCopyWithImpl<$Res>
    extends _$DriverApplicationCopyWithImpl<$Res, _$DriverApplicationImpl>
    implements _$$DriverApplicationImplCopyWith<$Res> {
  __$$DriverApplicationImplCopyWithImpl(_$DriverApplicationImpl _value,
      $Res Function(_$DriverApplicationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? status = null,
    Object? submittedAt = freezed,
    Object? reviewedAt = freezed,
    Object? reviewedBy = freezed,
    Object? rejectionReason = freezed,
  }) {
    return _then(_$DriverApplicationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      submittedAt: freezed == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedBy: freezed == reviewedBy
          ? _value.reviewedBy
          : reviewedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverApplicationImpl implements _DriverApplication {
  const _$DriverApplicationImpl(
      {required this.id,
      required this.userId,
      required this.status,
      this.submittedAt,
      this.reviewedAt,
      this.reviewedBy,
      this.rejectionReason});

  factory _$DriverApplicationImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverApplicationImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String status;
  @override
  final DateTime? submittedAt;
  @override
  final DateTime? reviewedAt;
  @override
  final String? reviewedBy;
  @override
  final String? rejectionReason;

  @override
  String toString() {
    return 'DriverApplication(id: $id, userId: $userId, status: $status, submittedAt: $submittedAt, reviewedAt: $reviewedAt, reviewedBy: $reviewedBy, rejectionReason: $rejectionReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverApplicationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.reviewedBy, reviewedBy) ||
                other.reviewedBy == reviewedBy) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, status, submittedAt,
      reviewedAt, reviewedBy, rejectionReason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverApplicationImplCopyWith<_$DriverApplicationImpl> get copyWith =>
      __$$DriverApplicationImplCopyWithImpl<_$DriverApplicationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverApplicationImplToJson(
      this,
    );
  }
}

abstract class _DriverApplication implements DriverApplication {
  const factory _DriverApplication(
      {required final String id,
      required final String userId,
      required final String status,
      final DateTime? submittedAt,
      final DateTime? reviewedAt,
      final String? reviewedBy,
      final String? rejectionReason}) = _$DriverApplicationImpl;

  factory _DriverApplication.fromJson(Map<String, dynamic> json) =
      _$DriverApplicationImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get status;
  @override
  DateTime? get submittedAt;
  @override
  DateTime? get reviewedAt;
  @override
  String? get reviewedBy;
  @override
  String? get rejectionReason;
  @override
  @JsonKey(ignore: true)
  _$$DriverApplicationImplCopyWith<_$DriverApplicationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DriverProfile _$DriverProfileFromJson(Map<String, dynamic> json) {
  return _DriverProfile.fromJson(json);
}

/// @nodoc
mixin _$DriverProfile {
  String get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  int? get totalRides => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DriverProfileCopyWith<DriverProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverProfileCopyWith<$Res> {
  factory $DriverProfileCopyWith(
          DriverProfile value, $Res Function(DriverProfile) then) =
      _$DriverProfileCopyWithImpl<$Res, DriverProfile>;
  @useResult
  $Res call(
      {String id,
      String? name,
      String? phone,
      double? rating,
      int? totalRides,
      bool? isActive,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$DriverProfileCopyWithImpl<$Res, $Val extends DriverProfile>
    implements $DriverProfileCopyWith<$Res> {
  _$DriverProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? phone = freezed,
    Object? rating = freezed,
    Object? totalRides = freezed,
    Object? isActive = freezed,
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
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      totalRides: freezed == totalRides
          ? _value.totalRides
          : totalRides // ignore: cast_nullable_to_non_nullable
              as int?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
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
}

/// @nodoc
abstract class _$$DriverProfileImplCopyWith<$Res>
    implements $DriverProfileCopyWith<$Res> {
  factory _$$DriverProfileImplCopyWith(
          _$DriverProfileImpl value, $Res Function(_$DriverProfileImpl) then) =
      __$$DriverProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? name,
      String? phone,
      double? rating,
      int? totalRides,
      bool? isActive,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$DriverProfileImplCopyWithImpl<$Res>
    extends _$DriverProfileCopyWithImpl<$Res, _$DriverProfileImpl>
    implements _$$DriverProfileImplCopyWith<$Res> {
  __$$DriverProfileImplCopyWithImpl(
      _$DriverProfileImpl _value, $Res Function(_$DriverProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? phone = freezed,
    Object? rating = freezed,
    Object? totalRides = freezed,
    Object? isActive = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$DriverProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      totalRides: freezed == totalRides
          ? _value.totalRides
          : totalRides // ignore: cast_nullable_to_non_nullable
              as int?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
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
class _$DriverProfileImpl implements _DriverProfile {
  const _$DriverProfileImpl(
      {required this.id,
      this.name,
      this.phone,
      this.rating,
      this.totalRides,
      this.isActive,
      this.createdAt,
      this.updatedAt});

  factory _$DriverProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String? name;
  @override
  final String? phone;
  @override
  final double? rating;
  @override
  final int? totalRides;
  @override
  final bool? isActive;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'DriverProfile(id: $id, name: $name, phone: $phone, rating: $rating, totalRides: $totalRides, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.totalRides, totalRides) ||
                other.totalRides == totalRides) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, phone, rating,
      totalRides, isActive, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverProfileImplCopyWith<_$DriverProfileImpl> get copyWith =>
      __$$DriverProfileImplCopyWithImpl<_$DriverProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverProfileImplToJson(
      this,
    );
  }
}

abstract class _DriverProfile implements DriverProfile {
  const factory _DriverProfile(
      {required final String id,
      final String? name,
      final String? phone,
      final double? rating,
      final int? totalRides,
      final bool? isActive,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$DriverProfileImpl;

  factory _DriverProfile.fromJson(Map<String, dynamic> json) =
      _$DriverProfileImpl.fromJson;

  @override
  String get id;
  @override
  String? get name;
  @override
  String? get phone;
  @override
  double? get rating;
  @override
  int? get totalRides;
  @override
  bool? get isActive;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$DriverProfileImplCopyWith<_$DriverProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DriverEligibility _$DriverEligibilityFromJson(Map<String, dynamic> json) {
  return _DriverEligibility.fromJson(json);
}

/// @nodoc
mixin _$DriverEligibility {
  bool get eligible => throw _privateConstructorUsedError;
  List<String> get missingRequirements => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DriverEligibilityCopyWith<DriverEligibility> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverEligibilityCopyWith<$Res> {
  factory $DriverEligibilityCopyWith(
          DriverEligibility value, $Res Function(DriverEligibility) then) =
      _$DriverEligibilityCopyWithImpl<$Res, DriverEligibility>;
  @useResult
  $Res call({bool eligible, List<String> missingRequirements, String? reason});
}

/// @nodoc
class _$DriverEligibilityCopyWithImpl<$Res, $Val extends DriverEligibility>
    implements $DriverEligibilityCopyWith<$Res> {
  _$DriverEligibilityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eligible = null,
    Object? missingRequirements = null,
    Object? reason = freezed,
  }) {
    return _then(_value.copyWith(
      eligible: null == eligible
          ? _value.eligible
          : eligible // ignore: cast_nullable_to_non_nullable
              as bool,
      missingRequirements: null == missingRequirements
          ? _value.missingRequirements
          : missingRequirements // ignore: cast_nullable_to_non_nullable
              as List<String>,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DriverEligibilityImplCopyWith<$Res>
    implements $DriverEligibilityCopyWith<$Res> {
  factory _$$DriverEligibilityImplCopyWith(_$DriverEligibilityImpl value,
          $Res Function(_$DriverEligibilityImpl) then) =
      __$$DriverEligibilityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool eligible, List<String> missingRequirements, String? reason});
}

/// @nodoc
class __$$DriverEligibilityImplCopyWithImpl<$Res>
    extends _$DriverEligibilityCopyWithImpl<$Res, _$DriverEligibilityImpl>
    implements _$$DriverEligibilityImplCopyWith<$Res> {
  __$$DriverEligibilityImplCopyWithImpl(_$DriverEligibilityImpl _value,
      $Res Function(_$DriverEligibilityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eligible = null,
    Object? missingRequirements = null,
    Object? reason = freezed,
  }) {
    return _then(_$DriverEligibilityImpl(
      eligible: null == eligible
          ? _value.eligible
          : eligible // ignore: cast_nullable_to_non_nullable
              as bool,
      missingRequirements: null == missingRequirements
          ? _value._missingRequirements
          : missingRequirements // ignore: cast_nullable_to_non_nullable
              as List<String>,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverEligibilityImpl implements _DriverEligibility {
  const _$DriverEligibilityImpl(
      {required this.eligible,
      required final List<String> missingRequirements,
      this.reason})
      : _missingRequirements = missingRequirements;

  factory _$DriverEligibilityImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverEligibilityImplFromJson(json);

  @override
  final bool eligible;
  final List<String> _missingRequirements;
  @override
  List<String> get missingRequirements {
    if (_missingRequirements is EqualUnmodifiableListView)
      return _missingRequirements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_missingRequirements);
  }

  @override
  final String? reason;

  @override
  String toString() {
    return 'DriverEligibility(eligible: $eligible, missingRequirements: $missingRequirements, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverEligibilityImpl &&
            (identical(other.eligible, eligible) ||
                other.eligible == eligible) &&
            const DeepCollectionEquality()
                .equals(other._missingRequirements, _missingRequirements) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, eligible,
      const DeepCollectionEquality().hash(_missingRequirements), reason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverEligibilityImplCopyWith<_$DriverEligibilityImpl> get copyWith =>
      __$$DriverEligibilityImplCopyWithImpl<_$DriverEligibilityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverEligibilityImplToJson(
      this,
    );
  }
}

abstract class _DriverEligibility implements DriverEligibility {
  const factory _DriverEligibility(
      {required final bool eligible,
      required final List<String> missingRequirements,
      final String? reason}) = _$DriverEligibilityImpl;

  factory _DriverEligibility.fromJson(Map<String, dynamic> json) =
      _$DriverEligibilityImpl.fromJson;

  @override
  bool get eligible;
  @override
  List<String> get missingRequirements;
  @override
  String? get reason;
  @override
  @JsonKey(ignore: true)
  _$$DriverEligibilityImplCopyWith<_$DriverEligibilityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DriverDocument _$DriverDocumentFromJson(Map<String, dynamic> json) {
  return _DriverDocument.fromJson(json);
}

/// @nodoc
mixin _$DriverDocument {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get number => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  DateTime? get uploadedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DriverDocumentCopyWith<DriverDocument> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverDocumentCopyWith<$Res> {
  factory $DriverDocumentCopyWith(
          DriverDocument value, $Res Function(DriverDocument) then) =
      _$DriverDocumentCopyWithImpl<$Res, DriverDocument>;
  @useResult
  $Res call(
      {String id,
      String type,
      String number,
      String status,
      DateTime? expiresAt,
      String? photoUrl,
      DateTime? uploadedAt});
}

/// @nodoc
class _$DriverDocumentCopyWithImpl<$Res, $Val extends DriverDocument>
    implements $DriverDocumentCopyWith<$Res> {
  _$DriverDocumentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? number = null,
    Object? status = null,
    Object? expiresAt = freezed,
    Object? photoUrl = freezed,
    Object? uploadedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      uploadedAt: freezed == uploadedAt
          ? _value.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DriverDocumentImplCopyWith<$Res>
    implements $DriverDocumentCopyWith<$Res> {
  factory _$$DriverDocumentImplCopyWith(_$DriverDocumentImpl value,
          $Res Function(_$DriverDocumentImpl) then) =
      __$$DriverDocumentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      String number,
      String status,
      DateTime? expiresAt,
      String? photoUrl,
      DateTime? uploadedAt});
}

/// @nodoc
class __$$DriverDocumentImplCopyWithImpl<$Res>
    extends _$DriverDocumentCopyWithImpl<$Res, _$DriverDocumentImpl>
    implements _$$DriverDocumentImplCopyWith<$Res> {
  __$$DriverDocumentImplCopyWithImpl(
      _$DriverDocumentImpl _value, $Res Function(_$DriverDocumentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? number = null,
    Object? status = null,
    Object? expiresAt = freezed,
    Object? photoUrl = freezed,
    Object? uploadedAt = freezed,
  }) {
    return _then(_$DriverDocumentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      uploadedAt: freezed == uploadedAt
          ? _value.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverDocumentImpl implements _DriverDocument {
  const _$DriverDocumentImpl(
      {required this.id,
      required this.type,
      required this.number,
      required this.status,
      this.expiresAt,
      this.photoUrl,
      this.uploadedAt});

  factory _$DriverDocumentImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverDocumentImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final String number;
  @override
  final String status;
  @override
  final DateTime? expiresAt;
  @override
  final String? photoUrl;
  @override
  final DateTime? uploadedAt;

  @override
  String toString() {
    return 'DriverDocument(id: $id, type: $type, number: $number, status: $status, expiresAt: $expiresAt, photoUrl: $photoUrl, uploadedAt: $uploadedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverDocumentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, type, number, status, expiresAt, photoUrl, uploadedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverDocumentImplCopyWith<_$DriverDocumentImpl> get copyWith =>
      __$$DriverDocumentImplCopyWithImpl<_$DriverDocumentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverDocumentImplToJson(
      this,
    );
  }
}

abstract class _DriverDocument implements DriverDocument {
  const factory _DriverDocument(
      {required final String id,
      required final String type,
      required final String number,
      required final String status,
      final DateTime? expiresAt,
      final String? photoUrl,
      final DateTime? uploadedAt}) = _$DriverDocumentImpl;

  factory _DriverDocument.fromJson(Map<String, dynamic> json) =
      _$DriverDocumentImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  String get number;
  @override
  String get status;
  @override
  DateTime? get expiresAt;
  @override
  String? get photoUrl;
  @override
  DateTime? get uploadedAt;
  @override
  @JsonKey(ignore: true)
  _$$DriverDocumentImplCopyWith<_$DriverDocumentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DriverDocumentRequest _$DriverDocumentRequestFromJson(
    Map<String, dynamic> json) {
  return _DriverDocumentRequest.fromJson(json);
}

/// @nodoc
mixin _$DriverDocumentRequest {
  String get type => throw _privateConstructorUsedError;
  String get number => throw _privateConstructorUsedError;
  String get photoUrl => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DriverDocumentRequestCopyWith<DriverDocumentRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverDocumentRequestCopyWith<$Res> {
  factory $DriverDocumentRequestCopyWith(DriverDocumentRequest value,
          $Res Function(DriverDocumentRequest) then) =
      _$DriverDocumentRequestCopyWithImpl<$Res, DriverDocumentRequest>;
  @useResult
  $Res call({String type, String number, String photoUrl, DateTime? expiresAt});
}

/// @nodoc
class _$DriverDocumentRequestCopyWithImpl<$Res,
        $Val extends DriverDocumentRequest>
    implements $DriverDocumentRequestCopyWith<$Res> {
  _$DriverDocumentRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? number = null,
    Object? photoUrl = null,
    Object? expiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: null == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DriverDocumentRequestImplCopyWith<$Res>
    implements $DriverDocumentRequestCopyWith<$Res> {
  factory _$$DriverDocumentRequestImplCopyWith(
          _$DriverDocumentRequestImpl value,
          $Res Function(_$DriverDocumentRequestImpl) then) =
      __$$DriverDocumentRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String type, String number, String photoUrl, DateTime? expiresAt});
}

/// @nodoc
class __$$DriverDocumentRequestImplCopyWithImpl<$Res>
    extends _$DriverDocumentRequestCopyWithImpl<$Res,
        _$DriverDocumentRequestImpl>
    implements _$$DriverDocumentRequestImplCopyWith<$Res> {
  __$$DriverDocumentRequestImplCopyWithImpl(_$DriverDocumentRequestImpl _value,
      $Res Function(_$DriverDocumentRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? number = null,
    Object? photoUrl = null,
    Object? expiresAt = freezed,
  }) {
    return _then(_$DriverDocumentRequestImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: null == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverDocumentRequestImpl implements _DriverDocumentRequest {
  const _$DriverDocumentRequestImpl(
      {required this.type,
      required this.number,
      required this.photoUrl,
      this.expiresAt});

  factory _$DriverDocumentRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverDocumentRequestImplFromJson(json);

  @override
  final String type;
  @override
  final String number;
  @override
  final String photoUrl;
  @override
  final DateTime? expiresAt;

  @override
  String toString() {
    return 'DriverDocumentRequest(type: $type, number: $number, photoUrl: $photoUrl, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverDocumentRequestImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, number, photoUrl, expiresAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverDocumentRequestImplCopyWith<_$DriverDocumentRequestImpl>
      get copyWith => __$$DriverDocumentRequestImplCopyWithImpl<
          _$DriverDocumentRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverDocumentRequestImplToJson(
      this,
    );
  }
}

abstract class _DriverDocumentRequest implements DriverDocumentRequest {
  const factory _DriverDocumentRequest(
      {required final String type,
      required final String number,
      required final String photoUrl,
      final DateTime? expiresAt}) = _$DriverDocumentRequestImpl;

  factory _DriverDocumentRequest.fromJson(Map<String, dynamic> json) =
      _$DriverDocumentRequestImpl.fromJson;

  @override
  String get type;
  @override
  String get number;
  @override
  String get photoUrl;
  @override
  DateTime? get expiresAt;
  @override
  @JsonKey(ignore: true)
  _$$DriverDocumentRequestImplCopyWith<_$DriverDocumentRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

DriverEarnings _$DriverEarningsFromJson(Map<String, dynamic> json) {
  return _DriverEarnings.fromJson(json);
}

/// @nodoc
mixin _$DriverEarnings {
  double get totalEarnings => throw _privateConstructorUsedError;
  double get pendingSettlement => throw _privateConstructorUsedError;
  double get availableBalance => throw _privateConstructorUsedError;
  DateTime? get periodStart => throw _privateConstructorUsedError;
  DateTime? get periodEnd => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DriverEarningsCopyWith<DriverEarnings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverEarningsCopyWith<$Res> {
  factory $DriverEarningsCopyWith(
          DriverEarnings value, $Res Function(DriverEarnings) then) =
      _$DriverEarningsCopyWithImpl<$Res, DriverEarnings>;
  @useResult
  $Res call(
      {double totalEarnings,
      double pendingSettlement,
      double availableBalance,
      DateTime? periodStart,
      DateTime? periodEnd});
}

/// @nodoc
class _$DriverEarningsCopyWithImpl<$Res, $Val extends DriverEarnings>
    implements $DriverEarningsCopyWith<$Res> {
  _$DriverEarningsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalEarnings = null,
    Object? pendingSettlement = null,
    Object? availableBalance = null,
    Object? periodStart = freezed,
    Object? periodEnd = freezed,
  }) {
    return _then(_value.copyWith(
      totalEarnings: null == totalEarnings
          ? _value.totalEarnings
          : totalEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      pendingSettlement: null == pendingSettlement
          ? _value.pendingSettlement
          : pendingSettlement // ignore: cast_nullable_to_non_nullable
              as double,
      availableBalance: null == availableBalance
          ? _value.availableBalance
          : availableBalance // ignore: cast_nullable_to_non_nullable
              as double,
      periodStart: freezed == periodStart
          ? _value.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      periodEnd: freezed == periodEnd
          ? _value.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DriverEarningsImplCopyWith<$Res>
    implements $DriverEarningsCopyWith<$Res> {
  factory _$$DriverEarningsImplCopyWith(_$DriverEarningsImpl value,
          $Res Function(_$DriverEarningsImpl) then) =
      __$$DriverEarningsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double totalEarnings,
      double pendingSettlement,
      double availableBalance,
      DateTime? periodStart,
      DateTime? periodEnd});
}

/// @nodoc
class __$$DriverEarningsImplCopyWithImpl<$Res>
    extends _$DriverEarningsCopyWithImpl<$Res, _$DriverEarningsImpl>
    implements _$$DriverEarningsImplCopyWith<$Res> {
  __$$DriverEarningsImplCopyWithImpl(
      _$DriverEarningsImpl _value, $Res Function(_$DriverEarningsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalEarnings = null,
    Object? pendingSettlement = null,
    Object? availableBalance = null,
    Object? periodStart = freezed,
    Object? periodEnd = freezed,
  }) {
    return _then(_$DriverEarningsImpl(
      totalEarnings: null == totalEarnings
          ? _value.totalEarnings
          : totalEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      pendingSettlement: null == pendingSettlement
          ? _value.pendingSettlement
          : pendingSettlement // ignore: cast_nullable_to_non_nullable
              as double,
      availableBalance: null == availableBalance
          ? _value.availableBalance
          : availableBalance // ignore: cast_nullable_to_non_nullable
              as double,
      periodStart: freezed == periodStart
          ? _value.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      periodEnd: freezed == periodEnd
          ? _value.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverEarningsImpl implements _DriverEarnings {
  const _$DriverEarningsImpl(
      {required this.totalEarnings,
      required this.pendingSettlement,
      required this.availableBalance,
      this.periodStart,
      this.periodEnd});

  factory _$DriverEarningsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverEarningsImplFromJson(json);

  @override
  final double totalEarnings;
  @override
  final double pendingSettlement;
  @override
  final double availableBalance;
  @override
  final DateTime? periodStart;
  @override
  final DateTime? periodEnd;

  @override
  String toString() {
    return 'DriverEarnings(totalEarnings: $totalEarnings, pendingSettlement: $pendingSettlement, availableBalance: $availableBalance, periodStart: $periodStart, periodEnd: $periodEnd)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverEarningsImpl &&
            (identical(other.totalEarnings, totalEarnings) ||
                other.totalEarnings == totalEarnings) &&
            (identical(other.pendingSettlement, pendingSettlement) ||
                other.pendingSettlement == pendingSettlement) &&
            (identical(other.availableBalance, availableBalance) ||
                other.availableBalance == availableBalance) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, totalEarnings, pendingSettlement,
      availableBalance, periodStart, periodEnd);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverEarningsImplCopyWith<_$DriverEarningsImpl> get copyWith =>
      __$$DriverEarningsImplCopyWithImpl<_$DriverEarningsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverEarningsImplToJson(
      this,
    );
  }
}

abstract class _DriverEarnings implements DriverEarnings {
  const factory _DriverEarnings(
      {required final double totalEarnings,
      required final double pendingSettlement,
      required final double availableBalance,
      final DateTime? periodStart,
      final DateTime? periodEnd}) = _$DriverEarningsImpl;

  factory _DriverEarnings.fromJson(Map<String, dynamic> json) =
      _$DriverEarningsImpl.fromJson;

  @override
  double get totalEarnings;
  @override
  double get pendingSettlement;
  @override
  double get availableBalance;
  @override
  DateTime? get periodStart;
  @override
  DateTime? get periodEnd;
  @override
  @JsonKey(ignore: true)
  _$$DriverEarningsImplCopyWith<_$DriverEarningsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Settlement _$SettlementFromJson(Map<String, dynamic> json) {
  return _Settlement.fromJson(json);
}

/// @nodoc
mixin _$Settlement {
  String get id => throw _privateConstructorUsedError;
  String get driverId => throw _privateConstructorUsedError;
  double get grossAmount => throw _privateConstructorUsedError;
  double get commission => throw _privateConstructorUsedError;
  double get adjustments => throw _privateConstructorUsedError;
  double get payable => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get periodStart => throw _privateConstructorUsedError;
  DateTime? get periodEnd => throw _privateConstructorUsedError;
  DateTime? get processedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SettlementCopyWith<Settlement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettlementCopyWith<$Res> {
  factory $SettlementCopyWith(
          Settlement value, $Res Function(Settlement) then) =
      _$SettlementCopyWithImpl<$Res, Settlement>;
  @useResult
  $Res call(
      {String id,
      String driverId,
      double grossAmount,
      double commission,
      double adjustments,
      double payable,
      String status,
      DateTime? periodStart,
      DateTime? periodEnd,
      DateTime? processedAt});
}

/// @nodoc
class _$SettlementCopyWithImpl<$Res, $Val extends Settlement>
    implements $SettlementCopyWith<$Res> {
  _$SettlementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driverId = null,
    Object? grossAmount = null,
    Object? commission = null,
    Object? adjustments = null,
    Object? payable = null,
    Object? status = null,
    Object? periodStart = freezed,
    Object? periodEnd = freezed,
    Object? processedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      grossAmount: null == grossAmount
          ? _value.grossAmount
          : grossAmount // ignore: cast_nullable_to_non_nullable
              as double,
      commission: null == commission
          ? _value.commission
          : commission // ignore: cast_nullable_to_non_nullable
              as double,
      adjustments: null == adjustments
          ? _value.adjustments
          : adjustments // ignore: cast_nullable_to_non_nullable
              as double,
      payable: null == payable
          ? _value.payable
          : payable // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      periodStart: freezed == periodStart
          ? _value.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      periodEnd: freezed == periodEnd
          ? _value.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      processedAt: freezed == processedAt
          ? _value.processedAt
          : processedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SettlementImplCopyWith<$Res>
    implements $SettlementCopyWith<$Res> {
  factory _$$SettlementImplCopyWith(
          _$SettlementImpl value, $Res Function(_$SettlementImpl) then) =
      __$$SettlementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String driverId,
      double grossAmount,
      double commission,
      double adjustments,
      double payable,
      String status,
      DateTime? periodStart,
      DateTime? periodEnd,
      DateTime? processedAt});
}

/// @nodoc
class __$$SettlementImplCopyWithImpl<$Res>
    extends _$SettlementCopyWithImpl<$Res, _$SettlementImpl>
    implements _$$SettlementImplCopyWith<$Res> {
  __$$SettlementImplCopyWithImpl(
      _$SettlementImpl _value, $Res Function(_$SettlementImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driverId = null,
    Object? grossAmount = null,
    Object? commission = null,
    Object? adjustments = null,
    Object? payable = null,
    Object? status = null,
    Object? periodStart = freezed,
    Object? periodEnd = freezed,
    Object? processedAt = freezed,
  }) {
    return _then(_$SettlementImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      grossAmount: null == grossAmount
          ? _value.grossAmount
          : grossAmount // ignore: cast_nullable_to_non_nullable
              as double,
      commission: null == commission
          ? _value.commission
          : commission // ignore: cast_nullable_to_non_nullable
              as double,
      adjustments: null == adjustments
          ? _value.adjustments
          : adjustments // ignore: cast_nullable_to_non_nullable
              as double,
      payable: null == payable
          ? _value.payable
          : payable // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      periodStart: freezed == periodStart
          ? _value.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      periodEnd: freezed == periodEnd
          ? _value.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      processedAt: freezed == processedAt
          ? _value.processedAt
          : processedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SettlementImpl implements _Settlement {
  const _$SettlementImpl(
      {required this.id,
      required this.driverId,
      required this.grossAmount,
      required this.commission,
      required this.adjustments,
      required this.payable,
      required this.status,
      this.periodStart,
      this.periodEnd,
      this.processedAt});

  factory _$SettlementImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettlementImplFromJson(json);

  @override
  final String id;
  @override
  final String driverId;
  @override
  final double grossAmount;
  @override
  final double commission;
  @override
  final double adjustments;
  @override
  final double payable;
  @override
  final String status;
  @override
  final DateTime? periodStart;
  @override
  final DateTime? periodEnd;
  @override
  final DateTime? processedAt;

  @override
  String toString() {
    return 'Settlement(id: $id, driverId: $driverId, grossAmount: $grossAmount, commission: $commission, adjustments: $adjustments, payable: $payable, status: $status, periodStart: $periodStart, periodEnd: $periodEnd, processedAt: $processedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettlementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.grossAmount, grossAmount) ||
                other.grossAmount == grossAmount) &&
            (identical(other.commission, commission) ||
                other.commission == commission) &&
            (identical(other.adjustments, adjustments) ||
                other.adjustments == adjustments) &&
            (identical(other.payable, payable) || other.payable == payable) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd) &&
            (identical(other.processedAt, processedAt) ||
                other.processedAt == processedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      driverId,
      grossAmount,
      commission,
      adjustments,
      payable,
      status,
      periodStart,
      periodEnd,
      processedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SettlementImplCopyWith<_$SettlementImpl> get copyWith =>
      __$$SettlementImplCopyWithImpl<_$SettlementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SettlementImplToJson(
      this,
    );
  }
}

abstract class _Settlement implements Settlement {
  const factory _Settlement(
      {required final String id,
      required final String driverId,
      required final double grossAmount,
      required final double commission,
      required final double adjustments,
      required final double payable,
      required final String status,
      final DateTime? periodStart,
      final DateTime? periodEnd,
      final DateTime? processedAt}) = _$SettlementImpl;

  factory _Settlement.fromJson(Map<String, dynamic> json) =
      _$SettlementImpl.fromJson;

  @override
  String get id;
  @override
  String get driverId;
  @override
  double get grossAmount;
  @override
  double get commission;
  @override
  double get adjustments;
  @override
  double get payable;
  @override
  String get status;
  @override
  DateTime? get periodStart;
  @override
  DateTime? get periodEnd;
  @override
  DateTime? get processedAt;
  @override
  @JsonKey(ignore: true)
  _$$SettlementImplCopyWith<_$SettlementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SettlementActionRequest _$SettlementActionRequestFromJson(
    Map<String, dynamic> json) {
  return _SettlementActionRequest.fromJson(json);
}

/// @nodoc
mixin _$SettlementActionRequest {
  String get action =>
      throw _privateConstructorUsedError; // pay_out, hold, release
  String? get reason => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SettlementActionRequestCopyWith<SettlementActionRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettlementActionRequestCopyWith<$Res> {
  factory $SettlementActionRequestCopyWith(SettlementActionRequest value,
          $Res Function(SettlementActionRequest) then) =
      _$SettlementActionRequestCopyWithImpl<$Res, SettlementActionRequest>;
  @useResult
  $Res call({String action, String? reason});
}

/// @nodoc
class _$SettlementActionRequestCopyWithImpl<$Res,
        $Val extends SettlementActionRequest>
    implements $SettlementActionRequestCopyWith<$Res> {
  _$SettlementActionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? action = null,
    Object? reason = freezed,
  }) {
    return _then(_value.copyWith(
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SettlementActionRequestImplCopyWith<$Res>
    implements $SettlementActionRequestCopyWith<$Res> {
  factory _$$SettlementActionRequestImplCopyWith(
          _$SettlementActionRequestImpl value,
          $Res Function(_$SettlementActionRequestImpl) then) =
      __$$SettlementActionRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String action, String? reason});
}

/// @nodoc
class __$$SettlementActionRequestImplCopyWithImpl<$Res>
    extends _$SettlementActionRequestCopyWithImpl<$Res,
        _$SettlementActionRequestImpl>
    implements _$$SettlementActionRequestImplCopyWith<$Res> {
  __$$SettlementActionRequestImplCopyWithImpl(
      _$SettlementActionRequestImpl _value,
      $Res Function(_$SettlementActionRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? action = null,
    Object? reason = freezed,
  }) {
    return _then(_$SettlementActionRequestImpl(
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SettlementActionRequestImpl implements _SettlementActionRequest {
  const _$SettlementActionRequestImpl({required this.action, this.reason});

  factory _$SettlementActionRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettlementActionRequestImplFromJson(json);

  @override
  final String action;
// pay_out, hold, release
  @override
  final String? reason;

  @override
  String toString() {
    return 'SettlementActionRequest(action: $action, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettlementActionRequestImpl &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, action, reason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SettlementActionRequestImplCopyWith<_$SettlementActionRequestImpl>
      get copyWith => __$$SettlementActionRequestImplCopyWithImpl<
          _$SettlementActionRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SettlementActionRequestImplToJson(
      this,
    );
  }
}

abstract class _SettlementActionRequest implements SettlementActionRequest {
  const factory _SettlementActionRequest(
      {required final String action,
      final String? reason}) = _$SettlementActionRequestImpl;

  factory _SettlementActionRequest.fromJson(Map<String, dynamic> json) =
      _$SettlementActionRequestImpl.fromJson;

  @override
  String get action;
  @override // pay_out, hold, release
  String? get reason;
  @override
  @JsonKey(ignore: true)
  _$$SettlementActionRequestImplCopyWith<_$SettlementActionRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

Vehicle _$VehicleFromJson(Map<String, dynamic> json) {
  return _Vehicle.fromJson(json);
}

/// @nodoc
mixin _$Vehicle {
  String get id => throw _privateConstructorUsedError;
  String get make => throw _privateConstructorUsedError;
  String get model => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  String get licensePlate => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VehicleCopyWith<Vehicle> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VehicleCopyWith<$Res> {
  factory $VehicleCopyWith(Vehicle value, $Res Function(Vehicle) then) =
      _$VehicleCopyWithImpl<$Res, Vehicle>;
  @useResult
  $Res call(
      {String id,
      String make,
      String model,
      int year,
      String color,
      String licensePlate,
      String? photoUrl,
      bool? isActive,
      DateTime? createdAt});
}

/// @nodoc
class _$VehicleCopyWithImpl<$Res, $Val extends Vehicle>
    implements $VehicleCopyWith<$Res> {
  _$VehicleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? make = null,
    Object? model = null,
    Object? year = null,
    Object? color = null,
    Object? licensePlate = null,
    Object? photoUrl = freezed,
    Object? isActive = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      make: null == make
          ? _value.make
          : make // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      licensePlate: null == licensePlate
          ? _value.licensePlate
          : licensePlate // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VehicleImplCopyWith<$Res> implements $VehicleCopyWith<$Res> {
  factory _$$VehicleImplCopyWith(
          _$VehicleImpl value, $Res Function(_$VehicleImpl) then) =
      __$$VehicleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String make,
      String model,
      int year,
      String color,
      String licensePlate,
      String? photoUrl,
      bool? isActive,
      DateTime? createdAt});
}

/// @nodoc
class __$$VehicleImplCopyWithImpl<$Res>
    extends _$VehicleCopyWithImpl<$Res, _$VehicleImpl>
    implements _$$VehicleImplCopyWith<$Res> {
  __$$VehicleImplCopyWithImpl(
      _$VehicleImpl _value, $Res Function(_$VehicleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? make = null,
    Object? model = null,
    Object? year = null,
    Object? color = null,
    Object? licensePlate = null,
    Object? photoUrl = freezed,
    Object? isActive = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$VehicleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      make: null == make
          ? _value.make
          : make // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      licensePlate: null == licensePlate
          ? _value.licensePlate
          : licensePlate // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VehicleImpl implements _Vehicle {
  const _$VehicleImpl(
      {required this.id,
      required this.make,
      required this.model,
      required this.year,
      required this.color,
      required this.licensePlate,
      this.photoUrl,
      this.isActive,
      this.createdAt});

  factory _$VehicleImpl.fromJson(Map<String, dynamic> json) =>
      _$$VehicleImplFromJson(json);

  @override
  final String id;
  @override
  final String make;
  @override
  final String model;
  @override
  final int year;
  @override
  final String color;
  @override
  final String licensePlate;
  @override
  final String? photoUrl;
  @override
  final bool? isActive;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Vehicle(id: $id, make: $make, model: $model, year: $year, color: $color, licensePlate: $licensePlate, photoUrl: $photoUrl, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VehicleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.make, make) || other.make == make) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.licensePlate, licensePlate) ||
                other.licensePlate == licensePlate) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, make, model, year, color,
      licensePlate, photoUrl, isActive, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VehicleImplCopyWith<_$VehicleImpl> get copyWith =>
      __$$VehicleImplCopyWithImpl<_$VehicleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VehicleImplToJson(
      this,
    );
  }
}

abstract class _Vehicle implements Vehicle {
  const factory _Vehicle(
      {required final String id,
      required final String make,
      required final String model,
      required final int year,
      required final String color,
      required final String licensePlate,
      final String? photoUrl,
      final bool? isActive,
      final DateTime? createdAt}) = _$VehicleImpl;

  factory _Vehicle.fromJson(Map<String, dynamic> json) = _$VehicleImpl.fromJson;

  @override
  String get id;
  @override
  String get make;
  @override
  String get model;
  @override
  int get year;
  @override
  String get color;
  @override
  String get licensePlate;
  @override
  String? get photoUrl;
  @override
  bool? get isActive;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$VehicleImplCopyWith<_$VehicleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateVehicleRequest _$CreateVehicleRequestFromJson(Map<String, dynamic> json) {
  return _CreateVehicleRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateVehicleRequest {
  String get make => throw _privateConstructorUsedError;
  String get model => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  String get licensePlate => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateVehicleRequestCopyWith<CreateVehicleRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateVehicleRequestCopyWith<$Res> {
  factory $CreateVehicleRequestCopyWith(CreateVehicleRequest value,
          $Res Function(CreateVehicleRequest) then) =
      _$CreateVehicleRequestCopyWithImpl<$Res, CreateVehicleRequest>;
  @useResult
  $Res call(
      {String make,
      String model,
      int year,
      String color,
      String licensePlate,
      String? photoUrl});
}

/// @nodoc
class _$CreateVehicleRequestCopyWithImpl<$Res,
        $Val extends CreateVehicleRequest>
    implements $CreateVehicleRequestCopyWith<$Res> {
  _$CreateVehicleRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? make = null,
    Object? model = null,
    Object? year = null,
    Object? color = null,
    Object? licensePlate = null,
    Object? photoUrl = freezed,
  }) {
    return _then(_value.copyWith(
      make: null == make
          ? _value.make
          : make // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      licensePlate: null == licensePlate
          ? _value.licensePlate
          : licensePlate // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateVehicleRequestImplCopyWith<$Res>
    implements $CreateVehicleRequestCopyWith<$Res> {
  factory _$$CreateVehicleRequestImplCopyWith(_$CreateVehicleRequestImpl value,
          $Res Function(_$CreateVehicleRequestImpl) then) =
      __$$CreateVehicleRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String make,
      String model,
      int year,
      String color,
      String licensePlate,
      String? photoUrl});
}

/// @nodoc
class __$$CreateVehicleRequestImplCopyWithImpl<$Res>
    extends _$CreateVehicleRequestCopyWithImpl<$Res, _$CreateVehicleRequestImpl>
    implements _$$CreateVehicleRequestImplCopyWith<$Res> {
  __$$CreateVehicleRequestImplCopyWithImpl(_$CreateVehicleRequestImpl _value,
      $Res Function(_$CreateVehicleRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? make = null,
    Object? model = null,
    Object? year = null,
    Object? color = null,
    Object? licensePlate = null,
    Object? photoUrl = freezed,
  }) {
    return _then(_$CreateVehicleRequestImpl(
      make: null == make
          ? _value.make
          : make // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      licensePlate: null == licensePlate
          ? _value.licensePlate
          : licensePlate // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateVehicleRequestImpl implements _CreateVehicleRequest {
  const _$CreateVehicleRequestImpl(
      {required this.make,
      required this.model,
      required this.year,
      required this.color,
      required this.licensePlate,
      this.photoUrl});

  factory _$CreateVehicleRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateVehicleRequestImplFromJson(json);

  @override
  final String make;
  @override
  final String model;
  @override
  final int year;
  @override
  final String color;
  @override
  final String licensePlate;
  @override
  final String? photoUrl;

  @override
  String toString() {
    return 'CreateVehicleRequest(make: $make, model: $model, year: $year, color: $color, licensePlate: $licensePlate, photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateVehicleRequestImpl &&
            (identical(other.make, make) || other.make == make) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.licensePlate, licensePlate) ||
                other.licensePlate == licensePlate) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, make, model, year, color, licensePlate, photoUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateVehicleRequestImplCopyWith<_$CreateVehicleRequestImpl>
      get copyWith =>
          __$$CreateVehicleRequestImplCopyWithImpl<_$CreateVehicleRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateVehicleRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateVehicleRequest implements CreateVehicleRequest {
  const factory _CreateVehicleRequest(
      {required final String make,
      required final String model,
      required final int year,
      required final String color,
      required final String licensePlate,
      final String? photoUrl}) = _$CreateVehicleRequestImpl;

  factory _CreateVehicleRequest.fromJson(Map<String, dynamic> json) =
      _$CreateVehicleRequestImpl.fromJson;

  @override
  String get make;
  @override
  String get model;
  @override
  int get year;
  @override
  String get color;
  @override
  String get licensePlate;
  @override
  String? get photoUrl;
  @override
  @JsonKey(ignore: true)
  _$$CreateVehicleRequestImplCopyWith<_$CreateVehicleRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

UpdateVehicleRequest _$UpdateVehicleRequestFromJson(Map<String, dynamic> json) {
  return _UpdateVehicleRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateVehicleRequest {
  String? get make => throw _privateConstructorUsedError;
  String? get model => throw _privateConstructorUsedError;
  int? get year => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  String? get licensePlate => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdateVehicleRequestCopyWith<UpdateVehicleRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateVehicleRequestCopyWith<$Res> {
  factory $UpdateVehicleRequestCopyWith(UpdateVehicleRequest value,
          $Res Function(UpdateVehicleRequest) then) =
      _$UpdateVehicleRequestCopyWithImpl<$Res, UpdateVehicleRequest>;
  @useResult
  $Res call(
      {String? make,
      String? model,
      int? year,
      String? color,
      String? licensePlate,
      String? photoUrl,
      bool? isActive});
}

/// @nodoc
class _$UpdateVehicleRequestCopyWithImpl<$Res,
        $Val extends UpdateVehicleRequest>
    implements $UpdateVehicleRequestCopyWith<$Res> {
  _$UpdateVehicleRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? make = freezed,
    Object? model = freezed,
    Object? year = freezed,
    Object? color = freezed,
    Object? licensePlate = freezed,
    Object? photoUrl = freezed,
    Object? isActive = freezed,
  }) {
    return _then(_value.copyWith(
      make: freezed == make
          ? _value.make
          : make // ignore: cast_nullable_to_non_nullable
              as String?,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      year: freezed == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      licensePlate: freezed == licensePlate
          ? _value.licensePlate
          : licensePlate // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpdateVehicleRequestImplCopyWith<$Res>
    implements $UpdateVehicleRequestCopyWith<$Res> {
  factory _$$UpdateVehicleRequestImplCopyWith(_$UpdateVehicleRequestImpl value,
          $Res Function(_$UpdateVehicleRequestImpl) then) =
      __$$UpdateVehicleRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? make,
      String? model,
      int? year,
      String? color,
      String? licensePlate,
      String? photoUrl,
      bool? isActive});
}

/// @nodoc
class __$$UpdateVehicleRequestImplCopyWithImpl<$Res>
    extends _$UpdateVehicleRequestCopyWithImpl<$Res, _$UpdateVehicleRequestImpl>
    implements _$$UpdateVehicleRequestImplCopyWith<$Res> {
  __$$UpdateVehicleRequestImplCopyWithImpl(_$UpdateVehicleRequestImpl _value,
      $Res Function(_$UpdateVehicleRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? make = freezed,
    Object? model = freezed,
    Object? year = freezed,
    Object? color = freezed,
    Object? licensePlate = freezed,
    Object? photoUrl = freezed,
    Object? isActive = freezed,
  }) {
    return _then(_$UpdateVehicleRequestImpl(
      make: freezed == make
          ? _value.make
          : make // ignore: cast_nullable_to_non_nullable
              as String?,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      year: freezed == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      licensePlate: freezed == licensePlate
          ? _value.licensePlate
          : licensePlate // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateVehicleRequestImpl implements _UpdateVehicleRequest {
  const _$UpdateVehicleRequestImpl(
      {this.make,
      this.model,
      this.year,
      this.color,
      this.licensePlate,
      this.photoUrl,
      this.isActive});

  factory _$UpdateVehicleRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateVehicleRequestImplFromJson(json);

  @override
  final String? make;
  @override
  final String? model;
  @override
  final int? year;
  @override
  final String? color;
  @override
  final String? licensePlate;
  @override
  final String? photoUrl;
  @override
  final bool? isActive;

  @override
  String toString() {
    return 'UpdateVehicleRequest(make: $make, model: $model, year: $year, color: $color, licensePlate: $licensePlate, photoUrl: $photoUrl, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateVehicleRequestImpl &&
            (identical(other.make, make) || other.make == make) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.licensePlate, licensePlate) ||
                other.licensePlate == licensePlate) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, make, model, year, color, licensePlate, photoUrl, isActive);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateVehicleRequestImplCopyWith<_$UpdateVehicleRequestImpl>
      get copyWith =>
          __$$UpdateVehicleRequestImplCopyWithImpl<_$UpdateVehicleRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateVehicleRequestImplToJson(
      this,
    );
  }
}

abstract class _UpdateVehicleRequest implements UpdateVehicleRequest {
  const factory _UpdateVehicleRequest(
      {final String? make,
      final String? model,
      final int? year,
      final String? color,
      final String? licensePlate,
      final String? photoUrl,
      final bool? isActive}) = _$UpdateVehicleRequestImpl;

  factory _UpdateVehicleRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateVehicleRequestImpl.fromJson;

  @override
  String? get make;
  @override
  String? get model;
  @override
  int? get year;
  @override
  String? get color;
  @override
  String? get licensePlate;
  @override
  String? get photoUrl;
  @override
  bool? get isActive;
  @override
  @JsonKey(ignore: true)
  _$$UpdateVehicleRequestImplCopyWith<_$UpdateVehicleRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

DriverLocationUpdate _$DriverLocationUpdateFromJson(Map<String, dynamic> json) {
  return _DriverLocationUpdate.fromJson(json);
}

/// @nodoc
mixin _$DriverLocationUpdate {
  String get rideId => throw _privateConstructorUsedError;
  LocationDto get location => throw _privateConstructorUsedError;
  double? get heading => throw _privateConstructorUsedError;
  double? get speed => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DriverLocationUpdateCopyWith<DriverLocationUpdate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverLocationUpdateCopyWith<$Res> {
  factory $DriverLocationUpdateCopyWith(DriverLocationUpdate value,
          $Res Function(DriverLocationUpdate) then) =
      _$DriverLocationUpdateCopyWithImpl<$Res, DriverLocationUpdate>;
  @useResult
  $Res call(
      {String rideId, LocationDto location, double? heading, double? speed});

  $LocationDtoCopyWith<$Res> get location;
}

/// @nodoc
class _$DriverLocationUpdateCopyWithImpl<$Res,
        $Val extends DriverLocationUpdate>
    implements $DriverLocationUpdateCopyWith<$Res> {
  _$DriverLocationUpdateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
    Object? location = null,
    Object? heading = freezed,
    Object? speed = freezed,
  }) {
    return _then(_value.copyWith(
      rideId: null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      heading: freezed == heading
          ? _value.heading
          : heading // ignore: cast_nullable_to_non_nullable
              as double?,
      speed: freezed == speed
          ? _value.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as double?,
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
abstract class _$$DriverLocationUpdateImplCopyWith<$Res>
    implements $DriverLocationUpdateCopyWith<$Res> {
  factory _$$DriverLocationUpdateImplCopyWith(_$DriverLocationUpdateImpl value,
          $Res Function(_$DriverLocationUpdateImpl) then) =
      __$$DriverLocationUpdateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String rideId, LocationDto location, double? heading, double? speed});

  @override
  $LocationDtoCopyWith<$Res> get location;
}

/// @nodoc
class __$$DriverLocationUpdateImplCopyWithImpl<$Res>
    extends _$DriverLocationUpdateCopyWithImpl<$Res, _$DriverLocationUpdateImpl>
    implements _$$DriverLocationUpdateImplCopyWith<$Res> {
  __$$DriverLocationUpdateImplCopyWithImpl(_$DriverLocationUpdateImpl _value,
      $Res Function(_$DriverLocationUpdateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
    Object? location = null,
    Object? heading = freezed,
    Object? speed = freezed,
  }) {
    return _then(_$DriverLocationUpdateImpl(
      rideId: null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      heading: freezed == heading
          ? _value.heading
          : heading // ignore: cast_nullable_to_non_nullable
              as double?,
      speed: freezed == speed
          ? _value.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverLocationUpdateImpl implements _DriverLocationUpdate {
  const _$DriverLocationUpdateImpl(
      {required this.rideId, required this.location, this.heading, this.speed});

  factory _$DriverLocationUpdateImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverLocationUpdateImplFromJson(json);

  @override
  final String rideId;
  @override
  final LocationDto location;
  @override
  final double? heading;
  @override
  final double? speed;

  @override
  String toString() {
    return 'DriverLocationUpdate(rideId: $rideId, location: $location, heading: $heading, speed: $speed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverLocationUpdateImpl &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.heading, heading) || other.heading == heading) &&
            (identical(other.speed, speed) || other.speed == speed));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, rideId, location, heading, speed);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverLocationUpdateImplCopyWith<_$DriverLocationUpdateImpl>
      get copyWith =>
          __$$DriverLocationUpdateImplCopyWithImpl<_$DriverLocationUpdateImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverLocationUpdateImplToJson(
      this,
    );
  }
}

abstract class _DriverLocationUpdate implements DriverLocationUpdate {
  const factory _DriverLocationUpdate(
      {required final String rideId,
      required final LocationDto location,
      final double? heading,
      final double? speed}) = _$DriverLocationUpdateImpl;

  factory _DriverLocationUpdate.fromJson(Map<String, dynamic> json) =
      _$DriverLocationUpdateImpl.fromJson;

  @override
  String get rideId;
  @override
  LocationDto get location;
  @override
  double? get heading;
  @override
  double? get speed;
  @override
  @JsonKey(ignore: true)
  _$$DriverLocationUpdateImplCopyWith<_$DriverLocationUpdateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
