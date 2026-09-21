// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complaint_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Complaint _$ComplaintFromJson(Map<String, dynamic> json) {
  return _Complaint.fromJson(json);
}

/// @nodoc
mixin _$Complaint {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get rideId => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get response => throw _privateConstructorUsedError;
  DateTime? get respondedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ComplaintCopyWith<Complaint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComplaintCopyWith<$Res> {
  factory $ComplaintCopyWith(Complaint value, $Res Function(Complaint) then) =
      _$ComplaintCopyWithImpl<$Res, Complaint>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String? rideId,
      String subject,
      String description,
      String? status,
      String? response,
      DateTime? respondedAt,
      DateTime? createdAt});
}

/// @nodoc
class _$ComplaintCopyWithImpl<$Res, $Val extends Complaint>
    implements $ComplaintCopyWith<$Res> {
  _$ComplaintCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? rideId = freezed,
    Object? subject = null,
    Object? description = null,
    Object? status = freezed,
    Object? response = freezed,
    Object? respondedAt = freezed,
    Object? createdAt = freezed,
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
      rideId: freezed == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String?,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      response: freezed == response
          ? _value.response
          : response // ignore: cast_nullable_to_non_nullable
              as String?,
      respondedAt: freezed == respondedAt
          ? _value.respondedAt
          : respondedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ComplaintImplCopyWith<$Res>
    implements $ComplaintCopyWith<$Res> {
  factory _$$ComplaintImplCopyWith(
          _$ComplaintImpl value, $Res Function(_$ComplaintImpl) then) =
      __$$ComplaintImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String? rideId,
      String subject,
      String description,
      String? status,
      String? response,
      DateTime? respondedAt,
      DateTime? createdAt});
}

/// @nodoc
class __$$ComplaintImplCopyWithImpl<$Res>
    extends _$ComplaintCopyWithImpl<$Res, _$ComplaintImpl>
    implements _$$ComplaintImplCopyWith<$Res> {
  __$$ComplaintImplCopyWithImpl(
      _$ComplaintImpl _value, $Res Function(_$ComplaintImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? rideId = freezed,
    Object? subject = null,
    Object? description = null,
    Object? status = freezed,
    Object? response = freezed,
    Object? respondedAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$ComplaintImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      rideId: freezed == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String?,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      response: freezed == response
          ? _value.response
          : response // ignore: cast_nullable_to_non_nullable
              as String?,
      respondedAt: freezed == respondedAt
          ? _value.respondedAt
          : respondedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ComplaintImpl implements _Complaint {
  const _$ComplaintImpl(
      {required this.id,
      required this.userId,
      required this.rideId,
      required this.subject,
      required this.description,
      this.status,
      this.response,
      this.respondedAt,
      this.createdAt});

  factory _$ComplaintImpl.fromJson(Map<String, dynamic> json) =>
      _$$ComplaintImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String? rideId;
  @override
  final String subject;
  @override
  final String description;
  @override
  final String? status;
  @override
  final String? response;
  @override
  final DateTime? respondedAt;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Complaint(id: $id, userId: $userId, rideId: $rideId, subject: $subject, description: $description, status: $status, response: $response, respondedAt: $respondedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComplaintImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.response, response) ||
                other.response == response) &&
            (identical(other.respondedAt, respondedAt) ||
                other.respondedAt == respondedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, rideId, subject,
      description, status, response, respondedAt, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ComplaintImplCopyWith<_$ComplaintImpl> get copyWith =>
      __$$ComplaintImplCopyWithImpl<_$ComplaintImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ComplaintImplToJson(
      this,
    );
  }
}

abstract class _Complaint implements Complaint {
  const factory _Complaint(
      {required final String id,
      required final String userId,
      required final String? rideId,
      required final String subject,
      required final String description,
      final String? status,
      final String? response,
      final DateTime? respondedAt,
      final DateTime? createdAt}) = _$ComplaintImpl;

  factory _Complaint.fromJson(Map<String, dynamic> json) =
      _$ComplaintImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String? get rideId;
  @override
  String get subject;
  @override
  String get description;
  @override
  String? get status;
  @override
  String? get response;
  @override
  DateTime? get respondedAt;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$ComplaintImplCopyWith<_$ComplaintImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateComplaintRequest _$CreateComplaintRequestFromJson(
    Map<String, dynamic> json) {
  return _CreateComplaintRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateComplaintRequest {
  String get subject => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get rideId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateComplaintRequestCopyWith<CreateComplaintRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateComplaintRequestCopyWith<$Res> {
  factory $CreateComplaintRequestCopyWith(CreateComplaintRequest value,
          $Res Function(CreateComplaintRequest) then) =
      _$CreateComplaintRequestCopyWithImpl<$Res, CreateComplaintRequest>;
  @useResult
  $Res call({String subject, String description, String? rideId});
}

/// @nodoc
class _$CreateComplaintRequestCopyWithImpl<$Res,
        $Val extends CreateComplaintRequest>
    implements $CreateComplaintRequestCopyWith<$Res> {
  _$CreateComplaintRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject = null,
    Object? description = null,
    Object? rideId = freezed,
  }) {
    return _then(_value.copyWith(
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      rideId: freezed == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateComplaintRequestImplCopyWith<$Res>
    implements $CreateComplaintRequestCopyWith<$Res> {
  factory _$$CreateComplaintRequestImplCopyWith(
          _$CreateComplaintRequestImpl value,
          $Res Function(_$CreateComplaintRequestImpl) then) =
      __$$CreateComplaintRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String subject, String description, String? rideId});
}

/// @nodoc
class __$$CreateComplaintRequestImplCopyWithImpl<$Res>
    extends _$CreateComplaintRequestCopyWithImpl<$Res,
        _$CreateComplaintRequestImpl>
    implements _$$CreateComplaintRequestImplCopyWith<$Res> {
  __$$CreateComplaintRequestImplCopyWithImpl(
      _$CreateComplaintRequestImpl _value,
      $Res Function(_$CreateComplaintRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject = null,
    Object? description = null,
    Object? rideId = freezed,
  }) {
    return _then(_$CreateComplaintRequestImpl(
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      rideId: freezed == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateComplaintRequestImpl implements _CreateComplaintRequest {
  const _$CreateComplaintRequestImpl(
      {required this.subject, required this.description, this.rideId});

  factory _$CreateComplaintRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateComplaintRequestImplFromJson(json);

  @override
  final String subject;
  @override
  final String description;
  @override
  final String? rideId;

  @override
  String toString() {
    return 'CreateComplaintRequest(subject: $subject, description: $description, rideId: $rideId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateComplaintRequestImpl &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.rideId, rideId) || other.rideId == rideId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, subject, description, rideId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateComplaintRequestImplCopyWith<_$CreateComplaintRequestImpl>
      get copyWith => __$$CreateComplaintRequestImplCopyWithImpl<
          _$CreateComplaintRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateComplaintRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateComplaintRequest implements CreateComplaintRequest {
  const factory _CreateComplaintRequest(
      {required final String subject,
      required final String description,
      final String? rideId}) = _$CreateComplaintRequestImpl;

  factory _CreateComplaintRequest.fromJson(Map<String, dynamic> json) =
      _$CreateComplaintRequestImpl.fromJson;

  @override
  String get subject;
  @override
  String get description;
  @override
  String? get rideId;
  @override
  @JsonKey(ignore: true)
  _$$CreateComplaintRequestImplCopyWith<_$CreateComplaintRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
