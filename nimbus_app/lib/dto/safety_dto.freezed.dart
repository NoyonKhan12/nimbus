// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'safety_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SafetyEvent _$SafetyEventFromJson(Map<String, dynamic> json) {
  return _SafetyEvent.fromJson(json);
}

/// @nodoc
mixin _$SafetyEvent {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get rideId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  List<double>? get location => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  DateTime? get respondedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SafetyEventCopyWith<SafetyEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SafetyEventCopyWith<$Res> {
  factory $SafetyEventCopyWith(
          SafetyEvent value, $Res Function(SafetyEvent) then) =
      _$SafetyEventCopyWithImpl<$Res, SafetyEvent>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String? rideId,
      String type,
      String status,
      List<double>? location,
      String? note,
      DateTime? respondedAt,
      DateTime? createdAt});
}

/// @nodoc
class _$SafetyEventCopyWithImpl<$Res, $Val extends SafetyEvent>
    implements $SafetyEventCopyWith<$Res> {
  _$SafetyEventCopyWithImpl(this._value, this._then);

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
    Object? type = null,
    Object? status = null,
    Object? location = freezed,
    Object? note = freezed,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as List<double>?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
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
abstract class _$$SafetyEventImplCopyWith<$Res>
    implements $SafetyEventCopyWith<$Res> {
  factory _$$SafetyEventImplCopyWith(
          _$SafetyEventImpl value, $Res Function(_$SafetyEventImpl) then) =
      __$$SafetyEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String? rideId,
      String type,
      String status,
      List<double>? location,
      String? note,
      DateTime? respondedAt,
      DateTime? createdAt});
}

/// @nodoc
class __$$SafetyEventImplCopyWithImpl<$Res>
    extends _$SafetyEventCopyWithImpl<$Res, _$SafetyEventImpl>
    implements _$$SafetyEventImplCopyWith<$Res> {
  __$$SafetyEventImplCopyWithImpl(
      _$SafetyEventImpl _value, $Res Function(_$SafetyEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? rideId = freezed,
    Object? type = null,
    Object? status = null,
    Object? location = freezed,
    Object? note = freezed,
    Object? respondedAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$SafetyEventImpl(
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value._location
          : location // ignore: cast_nullable_to_non_nullable
              as List<double>?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
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
class _$SafetyEventImpl implements _SafetyEvent {
  const _$SafetyEventImpl(
      {required this.id,
      required this.userId,
      this.rideId,
      required this.type,
      required this.status,
      final List<double>? location,
      this.note,
      this.respondedAt,
      this.createdAt})
      : _location = location;

  factory _$SafetyEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$SafetyEventImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String? rideId;
  @override
  final String type;
  @override
  final String status;
  final List<double>? _location;
  @override
  List<double>? get location {
    final value = _location;
    if (value == null) return null;
    if (_location is EqualUnmodifiableListView) return _location;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? note;
  @override
  final DateTime? respondedAt;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'SafetyEvent(id: $id, userId: $userId, rideId: $rideId, type: $type, status: $status, location: $location, note: $note, respondedAt: $respondedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SafetyEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._location, _location) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.respondedAt, respondedAt) ||
                other.respondedAt == respondedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      rideId,
      type,
      status,
      const DeepCollectionEquality().hash(_location),
      note,
      respondedAt,
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SafetyEventImplCopyWith<_$SafetyEventImpl> get copyWith =>
      __$$SafetyEventImplCopyWithImpl<_$SafetyEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SafetyEventImplToJson(
      this,
    );
  }
}

abstract class _SafetyEvent implements SafetyEvent {
  const factory _SafetyEvent(
      {required final String id,
      required final String userId,
      final String? rideId,
      required final String type,
      required final String status,
      final List<double>? location,
      final String? note,
      final DateTime? respondedAt,
      final DateTime? createdAt}) = _$SafetyEventImpl;

  factory _SafetyEvent.fromJson(Map<String, dynamic> json) =
      _$SafetyEventImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String? get rideId;
  @override
  String get type;
  @override
  String get status;
  @override
  List<double>? get location;
  @override
  String? get note;
  @override
  DateTime? get respondedAt;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$SafetyEventImplCopyWith<_$SafetyEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SosRequest _$SosRequestFromJson(Map<String, dynamic> json) {
  return _SosRequest.fromJson(json);
}

/// @nodoc
mixin _$SosRequest {
  String get rideId => throw _privateConstructorUsedError;
  List<double>? get location => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SosRequestCopyWith<SosRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SosRequestCopyWith<$Res> {
  factory $SosRequestCopyWith(
          SosRequest value, $Res Function(SosRequest) then) =
      _$SosRequestCopyWithImpl<$Res, SosRequest>;
  @useResult
  $Res call({String rideId, List<double>? location, String? note});
}

/// @nodoc
class _$SosRequestCopyWithImpl<$Res, $Val extends SosRequest>
    implements $SosRequestCopyWith<$Res> {
  _$SosRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
    Object? location = freezed,
    Object? note = freezed,
  }) {
    return _then(_value.copyWith(
      rideId: null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as List<double>?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SosRequestImplCopyWith<$Res>
    implements $SosRequestCopyWith<$Res> {
  factory _$$SosRequestImplCopyWith(
          _$SosRequestImpl value, $Res Function(_$SosRequestImpl) then) =
      __$$SosRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String rideId, List<double>? location, String? note});
}

/// @nodoc
class __$$SosRequestImplCopyWithImpl<$Res>
    extends _$SosRequestCopyWithImpl<$Res, _$SosRequestImpl>
    implements _$$SosRequestImplCopyWith<$Res> {
  __$$SosRequestImplCopyWithImpl(
      _$SosRequestImpl _value, $Res Function(_$SosRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
    Object? location = freezed,
    Object? note = freezed,
  }) {
    return _then(_$SosRequestImpl(
      rideId: null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value._location
          : location // ignore: cast_nullable_to_non_nullable
              as List<double>?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SosRequestImpl implements _SosRequest {
  const _$SosRequestImpl(
      {required this.rideId, final List<double>? location, this.note})
      : _location = location;

  factory _$SosRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SosRequestImplFromJson(json);

  @override
  final String rideId;
  final List<double>? _location;
  @override
  List<double>? get location {
    final value = _location;
    if (value == null) return null;
    if (_location is EqualUnmodifiableListView) return _location;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? note;

  @override
  String toString() {
    return 'SosRequest(rideId: $rideId, location: $location, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SosRequestImpl &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            const DeepCollectionEquality().equals(other._location, _location) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, rideId,
      const DeepCollectionEquality().hash(_location), note);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SosRequestImplCopyWith<_$SosRequestImpl> get copyWith =>
      __$$SosRequestImplCopyWithImpl<_$SosRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SosRequestImplToJson(
      this,
    );
  }
}

abstract class _SosRequest implements SosRequest {
  const factory _SosRequest(
      {required final String rideId,
      final List<double>? location,
      final String? note}) = _$SosRequestImpl;

  factory _SosRequest.fromJson(Map<String, dynamic> json) =
      _$SosRequestImpl.fromJson;

  @override
  String get rideId;
  @override
  List<double>? get location;
  @override
  String? get note;
  @override
  @JsonKey(ignore: true)
  _$$SosRequestImplCopyWith<_$SosRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TripShareResponse _$TripShareResponseFromJson(Map<String, dynamic> json) {
  return _TripShareResponse.fromJson(json);
}

/// @nodoc
mixin _$TripShareResponse {
  bool get shared => throw _privateConstructorUsedError;
  String? get shareUrl => throw _privateConstructorUsedError;
  String? get expiresAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TripShareResponseCopyWith<TripShareResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripShareResponseCopyWith<$Res> {
  factory $TripShareResponseCopyWith(
          TripShareResponse value, $Res Function(TripShareResponse) then) =
      _$TripShareResponseCopyWithImpl<$Res, TripShareResponse>;
  @useResult
  $Res call({bool shared, String? shareUrl, String? expiresAt});
}

/// @nodoc
class _$TripShareResponseCopyWithImpl<$Res, $Val extends TripShareResponse>
    implements $TripShareResponseCopyWith<$Res> {
  _$TripShareResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shared = null,
    Object? shareUrl = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      shared: null == shared
          ? _value.shared
          : shared // ignore: cast_nullable_to_non_nullable
              as bool,
      shareUrl: freezed == shareUrl
          ? _value.shareUrl
          : shareUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TripShareResponseImplCopyWith<$Res>
    implements $TripShareResponseCopyWith<$Res> {
  factory _$$TripShareResponseImplCopyWith(_$TripShareResponseImpl value,
          $Res Function(_$TripShareResponseImpl) then) =
      __$$TripShareResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool shared, String? shareUrl, String? expiresAt});
}

/// @nodoc
class __$$TripShareResponseImplCopyWithImpl<$Res>
    extends _$TripShareResponseCopyWithImpl<$Res, _$TripShareResponseImpl>
    implements _$$TripShareResponseImplCopyWith<$Res> {
  __$$TripShareResponseImplCopyWithImpl(_$TripShareResponseImpl _value,
      $Res Function(_$TripShareResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shared = null,
    Object? shareUrl = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_$TripShareResponseImpl(
      shared: null == shared
          ? _value.shared
          : shared // ignore: cast_nullable_to_non_nullable
              as bool,
      shareUrl: freezed == shareUrl
          ? _value.shareUrl
          : shareUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TripShareResponseImpl implements _TripShareResponse {
  const _$TripShareResponseImpl(
      {required this.shared, this.shareUrl, this.expiresAt});

  factory _$TripShareResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripShareResponseImplFromJson(json);

  @override
  final bool shared;
  @override
  final String? shareUrl;
  @override
  final String? expiresAt;

  @override
  String toString() {
    return 'TripShareResponse(shared: $shared, shareUrl: $shareUrl, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripShareResponseImpl &&
            (identical(other.shared, shared) || other.shared == shared) &&
            (identical(other.shareUrl, shareUrl) ||
                other.shareUrl == shareUrl) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, shared, shareUrl, expiresAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TripShareResponseImplCopyWith<_$TripShareResponseImpl> get copyWith =>
      __$$TripShareResponseImplCopyWithImpl<_$TripShareResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripShareResponseImplToJson(
      this,
    );
  }
}

abstract class _TripShareResponse implements TripShareResponse {
  const factory _TripShareResponse(
      {required final bool shared,
      final String? shareUrl,
      final String? expiresAt}) = _$TripShareResponseImpl;

  factory _TripShareResponse.fromJson(Map<String, dynamic> json) =
      _$TripShareResponseImpl.fromJson;

  @override
  bool get shared;
  @override
  String? get shareUrl;
  @override
  String? get expiresAt;
  @override
  @JsonKey(ignore: true)
  _$$TripShareResponseImplCopyWith<_$TripShareResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TripShareRequest _$TripShareRequestFromJson(Map<String, dynamic> json) {
  return _TripShareRequest.fromJson(json);
}

/// @nodoc
mixin _$TripShareRequest {
  String get rideId => throw _privateConstructorUsedError;
  int? get durationMinutes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TripShareRequestCopyWith<TripShareRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripShareRequestCopyWith<$Res> {
  factory $TripShareRequestCopyWith(
          TripShareRequest value, $Res Function(TripShareRequest) then) =
      _$TripShareRequestCopyWithImpl<$Res, TripShareRequest>;
  @useResult
  $Res call({String rideId, int? durationMinutes});
}

/// @nodoc
class _$TripShareRequestCopyWithImpl<$Res, $Val extends TripShareRequest>
    implements $TripShareRequestCopyWith<$Res> {
  _$TripShareRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
    Object? durationMinutes = freezed,
  }) {
    return _then(_value.copyWith(
      rideId: null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TripShareRequestImplCopyWith<$Res>
    implements $TripShareRequestCopyWith<$Res> {
  factory _$$TripShareRequestImplCopyWith(_$TripShareRequestImpl value,
          $Res Function(_$TripShareRequestImpl) then) =
      __$$TripShareRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String rideId, int? durationMinutes});
}

/// @nodoc
class __$$TripShareRequestImplCopyWithImpl<$Res>
    extends _$TripShareRequestCopyWithImpl<$Res, _$TripShareRequestImpl>
    implements _$$TripShareRequestImplCopyWith<$Res> {
  __$$TripShareRequestImplCopyWithImpl(_$TripShareRequestImpl _value,
      $Res Function(_$TripShareRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
    Object? durationMinutes = freezed,
  }) {
    return _then(_$TripShareRequestImpl(
      rideId: null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TripShareRequestImpl implements _TripShareRequest {
  const _$TripShareRequestImpl({required this.rideId, this.durationMinutes});

  factory _$TripShareRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripShareRequestImplFromJson(json);

  @override
  final String rideId;
  @override
  final int? durationMinutes;

  @override
  String toString() {
    return 'TripShareRequest(rideId: $rideId, durationMinutes: $durationMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripShareRequestImpl &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, rideId, durationMinutes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TripShareRequestImplCopyWith<_$TripShareRequestImpl> get copyWith =>
      __$$TripShareRequestImplCopyWithImpl<_$TripShareRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripShareRequestImplToJson(
      this,
    );
  }
}

abstract class _TripShareRequest implements TripShareRequest {
  const factory _TripShareRequest(
      {required final String rideId,
      final int? durationMinutes}) = _$TripShareRequestImpl;

  factory _TripShareRequest.fromJson(Map<String, dynamic> json) =
      _$TripShareRequestImpl.fromJson;

  @override
  String get rideId;
  @override
  int? get durationMinutes;
  @override
  @JsonKey(ignore: true)
  _$$TripShareRequestImplCopyWith<_$TripShareRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
