// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_booking_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Ride _$RideFromJson(Map<String, dynamic> json) {
  return _Ride.fromJson(json);
}

/// @nodoc
mixin _$Ride {
  String get id => throw _privateConstructorUsedError;
  String? get driverId => throw _privateConstructorUsedError;
  String? get creatorId => throw _privateConstructorUsedError;
  String? get vehicleId => throw _privateConstructorUsedError;
  RideType get rideType => throw _privateConstructorUsedError;
  RideStatus get status => throw _privateConstructorUsedError;
  DateTime? get scheduledAt => throw _privateConstructorUsedError;
  LocationDto get origin => throw _privateConstructorUsedError;
  LocationDto get destination => throw _privateConstructorUsedError;
  int get totalSeats => throw _privateConstructorUsedError;
  int get availableSeats => throw _privateConstructorUsedError;
  int? get maxDetourMeters => throw _privateConstructorUsedError;
  int? get maxWaitSeconds => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get routeVersion => throw _privateConstructorUsedError;
  String? get fareRuleVersion => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RideCopyWith<Ride> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RideCopyWith<$Res> {
  factory $RideCopyWith(Ride value, $Res Function(Ride) then) =
      _$RideCopyWithImpl<$Res, Ride>;
  @useResult
  $Res call(
      {String id,
      String? driverId,
      String? creatorId,
      String? vehicleId,
      RideType rideType,
      RideStatus status,
      DateTime? scheduledAt,
      LocationDto origin,
      LocationDto destination,
      int totalSeats,
      int availableSeats,
      int? maxDetourMeters,
      int? maxWaitSeconds,
      String? notes,
      String? routeVersion,
      String? fareRuleVersion,
      DateTime? createdAt,
      DateTime? updatedAt});

  $LocationDtoCopyWith<$Res> get origin;
  $LocationDtoCopyWith<$Res> get destination;
}

/// @nodoc
class _$RideCopyWithImpl<$Res, $Val extends Ride>
    implements $RideCopyWith<$Res> {
  _$RideCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driverId = freezed,
    Object? creatorId = freezed,
    Object? vehicleId = freezed,
    Object? rideType = null,
    Object? status = null,
    Object? scheduledAt = freezed,
    Object? origin = null,
    Object? destination = null,
    Object? totalSeats = null,
    Object? availableSeats = null,
    Object? maxDetourMeters = freezed,
    Object? maxWaitSeconds = freezed,
    Object? notes = freezed,
    Object? routeVersion = freezed,
    Object? fareRuleVersion = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: freezed == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorId: freezed == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleId: freezed == vehicleId
          ? _value.vehicleId
          : vehicleId // ignore: cast_nullable_to_non_nullable
              as String?,
      rideType: null == rideType
          ? _value.rideType
          : rideType // ignore: cast_nullable_to_non_nullable
              as RideType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RideStatus,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      origin: null == origin
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      totalSeats: null == totalSeats
          ? _value.totalSeats
          : totalSeats // ignore: cast_nullable_to_non_nullable
              as int,
      availableSeats: null == availableSeats
          ? _value.availableSeats
          : availableSeats // ignore: cast_nullable_to_non_nullable
              as int,
      maxDetourMeters: freezed == maxDetourMeters
          ? _value.maxDetourMeters
          : maxDetourMeters // ignore: cast_nullable_to_non_nullable
              as int?,
      maxWaitSeconds: freezed == maxWaitSeconds
          ? _value.maxWaitSeconds
          : maxWaitSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      routeVersion: freezed == routeVersion
          ? _value.routeVersion
          : routeVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      fareRuleVersion: freezed == fareRuleVersion
          ? _value.fareRuleVersion
          : fareRuleVersion // ignore: cast_nullable_to_non_nullable
              as String?,
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
  $LocationDtoCopyWith<$Res> get origin {
    return $LocationDtoCopyWith<$Res>(_value.origin, (value) {
      return _then(_value.copyWith(origin: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LocationDtoCopyWith<$Res> get destination {
    return $LocationDtoCopyWith<$Res>(_value.destination, (value) {
      return _then(_value.copyWith(destination: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RideImplCopyWith<$Res> implements $RideCopyWith<$Res> {
  factory _$$RideImplCopyWith(
          _$RideImpl value, $Res Function(_$RideImpl) then) =
      __$$RideImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? driverId,
      String? creatorId,
      String? vehicleId,
      RideType rideType,
      RideStatus status,
      DateTime? scheduledAt,
      LocationDto origin,
      LocationDto destination,
      int totalSeats,
      int availableSeats,
      int? maxDetourMeters,
      int? maxWaitSeconds,
      String? notes,
      String? routeVersion,
      String? fareRuleVersion,
      DateTime? createdAt,
      DateTime? updatedAt});

  @override
  $LocationDtoCopyWith<$Res> get origin;
  @override
  $LocationDtoCopyWith<$Res> get destination;
}

/// @nodoc
class __$$RideImplCopyWithImpl<$Res>
    extends _$RideCopyWithImpl<$Res, _$RideImpl>
    implements _$$RideImplCopyWith<$Res> {
  __$$RideImplCopyWithImpl(_$RideImpl _value, $Res Function(_$RideImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driverId = freezed,
    Object? creatorId = freezed,
    Object? vehicleId = freezed,
    Object? rideType = null,
    Object? status = null,
    Object? scheduledAt = freezed,
    Object? origin = null,
    Object? destination = null,
    Object? totalSeats = null,
    Object? availableSeats = null,
    Object? maxDetourMeters = freezed,
    Object? maxWaitSeconds = freezed,
    Object? notes = freezed,
    Object? routeVersion = freezed,
    Object? fareRuleVersion = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$RideImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: freezed == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorId: freezed == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleId: freezed == vehicleId
          ? _value.vehicleId
          : vehicleId // ignore: cast_nullable_to_non_nullable
              as String?,
      rideType: null == rideType
          ? _value.rideType
          : rideType // ignore: cast_nullable_to_non_nullable
              as RideType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RideStatus,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      origin: null == origin
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      totalSeats: null == totalSeats
          ? _value.totalSeats
          : totalSeats // ignore: cast_nullable_to_non_nullable
              as int,
      availableSeats: null == availableSeats
          ? _value.availableSeats
          : availableSeats // ignore: cast_nullable_to_non_nullable
              as int,
      maxDetourMeters: freezed == maxDetourMeters
          ? _value.maxDetourMeters
          : maxDetourMeters // ignore: cast_nullable_to_non_nullable
              as int?,
      maxWaitSeconds: freezed == maxWaitSeconds
          ? _value.maxWaitSeconds
          : maxWaitSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      routeVersion: freezed == routeVersion
          ? _value.routeVersion
          : routeVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      fareRuleVersion: freezed == fareRuleVersion
          ? _value.fareRuleVersion
          : fareRuleVersion // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _$RideImpl implements _Ride {
  const _$RideImpl(
      {required this.id,
      this.driverId,
      this.creatorId,
      this.vehicleId,
      required this.rideType,
      required this.status,
      this.scheduledAt,
      required this.origin,
      required this.destination,
      required this.totalSeats,
      required this.availableSeats,
      this.maxDetourMeters,
      this.maxWaitSeconds,
      this.notes,
      this.routeVersion,
      this.fareRuleVersion,
      this.createdAt,
      this.updatedAt});

  factory _$RideImpl.fromJson(Map<String, dynamic> json) =>
      _$$RideImplFromJson(json);

  @override
  final String id;
  @override
  final String? driverId;
  @override
  final String? creatorId;
  @override
  final String? vehicleId;
  @override
  final RideType rideType;
  @override
  final RideStatus status;
  @override
  final DateTime? scheduledAt;
  @override
  final LocationDto origin;
  @override
  final LocationDto destination;
  @override
  final int totalSeats;
  @override
  final int availableSeats;
  @override
  final int? maxDetourMeters;
  @override
  final int? maxWaitSeconds;
  @override
  final String? notes;
  @override
  final String? routeVersion;
  @override
  final String? fareRuleVersion;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Ride(id: $id, driverId: $driverId, creatorId: $creatorId, vehicleId: $vehicleId, rideType: $rideType, status: $status, scheduledAt: $scheduledAt, origin: $origin, destination: $destination, totalSeats: $totalSeats, availableSeats: $availableSeats, maxDetourMeters: $maxDetourMeters, maxWaitSeconds: $maxWaitSeconds, notes: $notes, routeVersion: $routeVersion, fareRuleVersion: $fareRuleVersion, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RideImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.vehicleId, vehicleId) ||
                other.vehicleId == vehicleId) &&
            (identical(other.rideType, rideType) ||
                other.rideType == rideType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.origin, origin) || other.origin == origin) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.totalSeats, totalSeats) ||
                other.totalSeats == totalSeats) &&
            (identical(other.availableSeats, availableSeats) ||
                other.availableSeats == availableSeats) &&
            (identical(other.maxDetourMeters, maxDetourMeters) ||
                other.maxDetourMeters == maxDetourMeters) &&
            (identical(other.maxWaitSeconds, maxWaitSeconds) ||
                other.maxWaitSeconds == maxWaitSeconds) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.routeVersion, routeVersion) ||
                other.routeVersion == routeVersion) &&
            (identical(other.fareRuleVersion, fareRuleVersion) ||
                other.fareRuleVersion == fareRuleVersion) &&
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
      driverId,
      creatorId,
      vehicleId,
      rideType,
      status,
      scheduledAt,
      origin,
      destination,
      totalSeats,
      availableSeats,
      maxDetourMeters,
      maxWaitSeconds,
      notes,
      routeVersion,
      fareRuleVersion,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RideImplCopyWith<_$RideImpl> get copyWith =>
      __$$RideImplCopyWithImpl<_$RideImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RideImplToJson(
      this,
    );
  }
}

abstract class _Ride implements Ride {
  const factory _Ride(
      {required final String id,
      final String? driverId,
      final String? creatorId,
      final String? vehicleId,
      required final RideType rideType,
      required final RideStatus status,
      final DateTime? scheduledAt,
      required final LocationDto origin,
      required final LocationDto destination,
      required final int totalSeats,
      required final int availableSeats,
      final int? maxDetourMeters,
      final int? maxWaitSeconds,
      final String? notes,
      final String? routeVersion,
      final String? fareRuleVersion,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$RideImpl;

  factory _Ride.fromJson(Map<String, dynamic> json) = _$RideImpl.fromJson;

  @override
  String get id;
  @override
  String? get driverId;
  @override
  String? get creatorId;
  @override
  String? get vehicleId;
  @override
  RideType get rideType;
  @override
  RideStatus get status;
  @override
  DateTime? get scheduledAt;
  @override
  LocationDto get origin;
  @override
  LocationDto get destination;
  @override
  int get totalSeats;
  @override
  int get availableSeats;
  @override
  int? get maxDetourMeters;
  @override
  int? get maxWaitSeconds;
  @override
  String? get notes;
  @override
  String? get routeVersion;
  @override
  String? get fareRuleVersion;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$RideImplCopyWith<_$RideImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateRideRequest _$UpdateRideRequestFromJson(Map<String, dynamic> json) {
  return _UpdateRideRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateRideRequest {
  DateTime? get scheduledAt => throw _privateConstructorUsedError;
  LocationDto? get origin => throw _privateConstructorUsedError;
  LocationDto? get destination => throw _privateConstructorUsedError;
  int? get availableSeats => throw _privateConstructorUsedError;
  int? get maxDetourMeters => throw _privateConstructorUsedError;
  int? get maxWaitSeconds => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdateRideRequestCopyWith<UpdateRideRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateRideRequestCopyWith<$Res> {
  factory $UpdateRideRequestCopyWith(
          UpdateRideRequest value, $Res Function(UpdateRideRequest) then) =
      _$UpdateRideRequestCopyWithImpl<$Res, UpdateRideRequest>;
  @useResult
  $Res call(
      {DateTime? scheduledAt,
      LocationDto? origin,
      LocationDto? destination,
      int? availableSeats,
      int? maxDetourMeters,
      int? maxWaitSeconds,
      String? notes});

  $LocationDtoCopyWith<$Res>? get origin;
  $LocationDtoCopyWith<$Res>? get destination;
}

/// @nodoc
class _$UpdateRideRequestCopyWithImpl<$Res, $Val extends UpdateRideRequest>
    implements $UpdateRideRequestCopyWith<$Res> {
  _$UpdateRideRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scheduledAt = freezed,
    Object? origin = freezed,
    Object? destination = freezed,
    Object? availableSeats = freezed,
    Object? maxDetourMeters = freezed,
    Object? maxWaitSeconds = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      origin: freezed == origin
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as LocationDto?,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as LocationDto?,
      availableSeats: freezed == availableSeats
          ? _value.availableSeats
          : availableSeats // ignore: cast_nullable_to_non_nullable
              as int?,
      maxDetourMeters: freezed == maxDetourMeters
          ? _value.maxDetourMeters
          : maxDetourMeters // ignore: cast_nullable_to_non_nullable
              as int?,
      maxWaitSeconds: freezed == maxWaitSeconds
          ? _value.maxWaitSeconds
          : maxWaitSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $LocationDtoCopyWith<$Res>? get origin {
    if (_value.origin == null) {
      return null;
    }

    return $LocationDtoCopyWith<$Res>(_value.origin!, (value) {
      return _then(_value.copyWith(origin: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LocationDtoCopyWith<$Res>? get destination {
    if (_value.destination == null) {
      return null;
    }

    return $LocationDtoCopyWith<$Res>(_value.destination!, (value) {
      return _then(_value.copyWith(destination: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UpdateRideRequestImplCopyWith<$Res>
    implements $UpdateRideRequestCopyWith<$Res> {
  factory _$$UpdateRideRequestImplCopyWith(_$UpdateRideRequestImpl value,
          $Res Function(_$UpdateRideRequestImpl) then) =
      __$$UpdateRideRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime? scheduledAt,
      LocationDto? origin,
      LocationDto? destination,
      int? availableSeats,
      int? maxDetourMeters,
      int? maxWaitSeconds,
      String? notes});

  @override
  $LocationDtoCopyWith<$Res>? get origin;
  @override
  $LocationDtoCopyWith<$Res>? get destination;
}

/// @nodoc
class __$$UpdateRideRequestImplCopyWithImpl<$Res>
    extends _$UpdateRideRequestCopyWithImpl<$Res, _$UpdateRideRequestImpl>
    implements _$$UpdateRideRequestImplCopyWith<$Res> {
  __$$UpdateRideRequestImplCopyWithImpl(_$UpdateRideRequestImpl _value,
      $Res Function(_$UpdateRideRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scheduledAt = freezed,
    Object? origin = freezed,
    Object? destination = freezed,
    Object? availableSeats = freezed,
    Object? maxDetourMeters = freezed,
    Object? maxWaitSeconds = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$UpdateRideRequestImpl(
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      origin: freezed == origin
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as LocationDto?,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as LocationDto?,
      availableSeats: freezed == availableSeats
          ? _value.availableSeats
          : availableSeats // ignore: cast_nullable_to_non_nullable
              as int?,
      maxDetourMeters: freezed == maxDetourMeters
          ? _value.maxDetourMeters
          : maxDetourMeters // ignore: cast_nullable_to_non_nullable
              as int?,
      maxWaitSeconds: freezed == maxWaitSeconds
          ? _value.maxWaitSeconds
          : maxWaitSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateRideRequestImpl implements _UpdateRideRequest {
  const _$UpdateRideRequestImpl(
      {this.scheduledAt,
      this.origin,
      this.destination,
      this.availableSeats,
      this.maxDetourMeters,
      this.maxWaitSeconds,
      this.notes});

  factory _$UpdateRideRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateRideRequestImplFromJson(json);

  @override
  final DateTime? scheduledAt;
  @override
  final LocationDto? origin;
  @override
  final LocationDto? destination;
  @override
  final int? availableSeats;
  @override
  final int? maxDetourMeters;
  @override
  final int? maxWaitSeconds;
  @override
  final String? notes;

  @override
  String toString() {
    return 'UpdateRideRequest(scheduledAt: $scheduledAt, origin: $origin, destination: $destination, availableSeats: $availableSeats, maxDetourMeters: $maxDetourMeters, maxWaitSeconds: $maxWaitSeconds, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateRideRequestImpl &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.origin, origin) || other.origin == origin) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.availableSeats, availableSeats) ||
                other.availableSeats == availableSeats) &&
            (identical(other.maxDetourMeters, maxDetourMeters) ||
                other.maxDetourMeters == maxDetourMeters) &&
            (identical(other.maxWaitSeconds, maxWaitSeconds) ||
                other.maxWaitSeconds == maxWaitSeconds) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, scheduledAt, origin, destination,
      availableSeats, maxDetourMeters, maxWaitSeconds, notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateRideRequestImplCopyWith<_$UpdateRideRequestImpl> get copyWith =>
      __$$UpdateRideRequestImplCopyWithImpl<_$UpdateRideRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateRideRequestImplToJson(
      this,
    );
  }
}

abstract class _UpdateRideRequest implements UpdateRideRequest {
  const factory _UpdateRideRequest(
      {final DateTime? scheduledAt,
      final LocationDto? origin,
      final LocationDto? destination,
      final int? availableSeats,
      final int? maxDetourMeters,
      final int? maxWaitSeconds,
      final String? notes}) = _$UpdateRideRequestImpl;

  factory _UpdateRideRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateRideRequestImpl.fromJson;

  @override
  DateTime? get scheduledAt;
  @override
  LocationDto? get origin;
  @override
  LocationDto? get destination;
  @override
  int? get availableSeats;
  @override
  int? get maxDetourMeters;
  @override
  int? get maxWaitSeconds;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$UpdateRideRequestImplCopyWith<_$UpdateRideRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CancelRideRequest _$CancelRideRequestFromJson(Map<String, dynamic> json) {
  return _CancelRideRequest.fromJson(json);
}

/// @nodoc
mixin _$CancelRideRequest {
  String? get reason => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CancelRideRequestCopyWith<CancelRideRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CancelRideRequestCopyWith<$Res> {
  factory $CancelRideRequestCopyWith(
          CancelRideRequest value, $Res Function(CancelRideRequest) then) =
      _$CancelRideRequestCopyWithImpl<$Res, CancelRideRequest>;
  @useResult
  $Res call({String? reason});
}

/// @nodoc
class _$CancelRideRequestCopyWithImpl<$Res, $Val extends CancelRideRequest>
    implements $CancelRideRequestCopyWith<$Res> {
  _$CancelRideRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reason = freezed,
  }) {
    return _then(_value.copyWith(
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CancelRideRequestImplCopyWith<$Res>
    implements $CancelRideRequestCopyWith<$Res> {
  factory _$$CancelRideRequestImplCopyWith(_$CancelRideRequestImpl value,
          $Res Function(_$CancelRideRequestImpl) then) =
      __$$CancelRideRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? reason});
}

/// @nodoc
class __$$CancelRideRequestImplCopyWithImpl<$Res>
    extends _$CancelRideRequestCopyWithImpl<$Res, _$CancelRideRequestImpl>
    implements _$$CancelRideRequestImplCopyWith<$Res> {
  __$$CancelRideRequestImplCopyWithImpl(_$CancelRideRequestImpl _value,
      $Res Function(_$CancelRideRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reason = freezed,
  }) {
    return _then(_$CancelRideRequestImpl(
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CancelRideRequestImpl implements _CancelRideRequest {
  const _$CancelRideRequestImpl({this.reason});

  factory _$CancelRideRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CancelRideRequestImplFromJson(json);

  @override
  final String? reason;

  @override
  String toString() {
    return 'CancelRideRequest(reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CancelRideRequestImpl &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, reason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CancelRideRequestImplCopyWith<_$CancelRideRequestImpl> get copyWith =>
      __$$CancelRideRequestImplCopyWithImpl<_$CancelRideRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CancelRideRequestImplToJson(
      this,
    );
  }
}

abstract class _CancelRideRequest implements CancelRideRequest {
  const factory _CancelRideRequest({final String? reason}) =
      _$CancelRideRequestImpl;

  factory _CancelRideRequest.fromJson(Map<String, dynamic> json) =
      _$CancelRideRequestImpl.fromJson;

  @override
  String? get reason;
  @override
  @JsonKey(ignore: true)
  _$$CancelRideRequestImplCopyWith<_$CancelRideRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EtaResponse _$EtaResponseFromJson(Map<String, dynamic> json) {
  return _EtaResponse.fromJson(json);
}

/// @nodoc
mixin _$EtaResponse {
  int get durationSeconds => throw _privateConstructorUsedError;
  int get distanceMeters => throw _privateConstructorUsedError;
  String? get polyline => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EtaResponseCopyWith<EtaResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EtaResponseCopyWith<$Res> {
  factory $EtaResponseCopyWith(
          EtaResponse value, $Res Function(EtaResponse) then) =
      _$EtaResponseCopyWithImpl<$Res, EtaResponse>;
  @useResult
  $Res call({int durationSeconds, int distanceMeters, String? polyline});
}

/// @nodoc
class _$EtaResponseCopyWithImpl<$Res, $Val extends EtaResponse>
    implements $EtaResponseCopyWith<$Res> {
  _$EtaResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? durationSeconds = null,
    Object? distanceMeters = null,
    Object? polyline = freezed,
  }) {
    return _then(_value.copyWith(
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      distanceMeters: null == distanceMeters
          ? _value.distanceMeters
          : distanceMeters // ignore: cast_nullable_to_non_nullable
              as int,
      polyline: freezed == polyline
          ? _value.polyline
          : polyline // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EtaResponseImplCopyWith<$Res>
    implements $EtaResponseCopyWith<$Res> {
  factory _$$EtaResponseImplCopyWith(
          _$EtaResponseImpl value, $Res Function(_$EtaResponseImpl) then) =
      __$$EtaResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int durationSeconds, int distanceMeters, String? polyline});
}

/// @nodoc
class __$$EtaResponseImplCopyWithImpl<$Res>
    extends _$EtaResponseCopyWithImpl<$Res, _$EtaResponseImpl>
    implements _$$EtaResponseImplCopyWith<$Res> {
  __$$EtaResponseImplCopyWithImpl(
      _$EtaResponseImpl _value, $Res Function(_$EtaResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? durationSeconds = null,
    Object? distanceMeters = null,
    Object? polyline = freezed,
  }) {
    return _then(_$EtaResponseImpl(
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      distanceMeters: null == distanceMeters
          ? _value.distanceMeters
          : distanceMeters // ignore: cast_nullable_to_non_nullable
              as int,
      polyline: freezed == polyline
          ? _value.polyline
          : polyline // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EtaResponseImpl implements _EtaResponse {
  const _$EtaResponseImpl(
      {required this.durationSeconds,
      required this.distanceMeters,
      this.polyline});

  factory _$EtaResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$EtaResponseImplFromJson(json);

  @override
  final int durationSeconds;
  @override
  final int distanceMeters;
  @override
  final String? polyline;

  @override
  String toString() {
    return 'EtaResponse(durationSeconds: $durationSeconds, distanceMeters: $distanceMeters, polyline: $polyline)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EtaResponseImpl &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.distanceMeters, distanceMeters) ||
                other.distanceMeters == distanceMeters) &&
            (identical(other.polyline, polyline) ||
                other.polyline == polyline));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, durationSeconds, distanceMeters, polyline);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EtaResponseImplCopyWith<_$EtaResponseImpl> get copyWith =>
      __$$EtaResponseImplCopyWithImpl<_$EtaResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EtaResponseImplToJson(
      this,
    );
  }
}

abstract class _EtaResponse implements EtaResponse {
  const factory _EtaResponse(
      {required final int durationSeconds,
      required final int distanceMeters,
      final String? polyline}) = _$EtaResponseImpl;

  factory _EtaResponse.fromJson(Map<String, dynamic> json) =
      _$EtaResponseImpl.fromJson;

  @override
  int get durationSeconds;
  @override
  int get distanceMeters;
  @override
  String? get polyline;
  @override
  @JsonKey(ignore: true)
  _$$EtaResponseImplCopyWith<_$EtaResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Booking _$BookingFromJson(Map<String, dynamic> json) {
  return _Booking.fromJson(json);
}

/// @nodoc
mixin _$Booking {
  String get id => throw _privateConstructorUsedError;
  String get rideId => throw _privateConstructorUsedError;
  String get passengerId => throw _privateConstructorUsedError;
  int get seats => throw _privateConstructorUsedError;
  FareQuoteDto? get fareQuote => throw _privateConstructorUsedError;
  LocationDto get pickupLocation => throw _privateConstructorUsedError;
  LocationDto get dropoffLocation => throw _privateConstructorUsedError;
  String? get pickupAddress => throw _privateConstructorUsedError;
  String? get dropoffAddress => throw _privateConstructorUsedError;
  BookingStatus get status => throw _privateConstructorUsedError;
  int? get pickupStopSequence => throw _privateConstructorUsedError;
  int? get dropoffStopSequence => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookingCopyWith<Booking> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingCopyWith<$Res> {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) then) =
      _$BookingCopyWithImpl<$Res, Booking>;
  @useResult
  $Res call(
      {String id,
      String rideId,
      String passengerId,
      int seats,
      FareQuoteDto? fareQuote,
      LocationDto pickupLocation,
      LocationDto dropoffLocation,
      String? pickupAddress,
      String? dropoffAddress,
      BookingStatus status,
      int? pickupStopSequence,
      int? dropoffStopSequence,
      DateTime? createdAt,
      DateTime? updatedAt});

  $FareQuoteDtoCopyWith<$Res>? get fareQuote;
  $LocationDtoCopyWith<$Res> get pickupLocation;
  $LocationDtoCopyWith<$Res> get dropoffLocation;
}

/// @nodoc
class _$BookingCopyWithImpl<$Res, $Val extends Booking>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rideId = null,
    Object? passengerId = null,
    Object? seats = null,
    Object? fareQuote = freezed,
    Object? pickupLocation = null,
    Object? dropoffLocation = null,
    Object? pickupAddress = freezed,
    Object? dropoffAddress = freezed,
    Object? status = null,
    Object? pickupStopSequence = freezed,
    Object? dropoffStopSequence = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rideId: null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
      passengerId: null == passengerId
          ? _value.passengerId
          : passengerId // ignore: cast_nullable_to_non_nullable
              as String,
      seats: null == seats
          ? _value.seats
          : seats // ignore: cast_nullable_to_non_nullable
              as int,
      fareQuote: freezed == fareQuote
          ? _value.fareQuote
          : fareQuote // ignore: cast_nullable_to_non_nullable
              as FareQuoteDto?,
      pickupLocation: null == pickupLocation
          ? _value.pickupLocation
          : pickupLocation // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      dropoffLocation: null == dropoffLocation
          ? _value.dropoffLocation
          : dropoffLocation // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      pickupAddress: freezed == pickupAddress
          ? _value.pickupAddress
          : pickupAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      dropoffAddress: freezed == dropoffAddress
          ? _value.dropoffAddress
          : dropoffAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
      pickupStopSequence: freezed == pickupStopSequence
          ? _value.pickupStopSequence
          : pickupStopSequence // ignore: cast_nullable_to_non_nullable
              as int?,
      dropoffStopSequence: freezed == dropoffStopSequence
          ? _value.dropoffStopSequence
          : dropoffStopSequence // ignore: cast_nullable_to_non_nullable
              as int?,
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
  $FareQuoteDtoCopyWith<$Res>? get fareQuote {
    if (_value.fareQuote == null) {
      return null;
    }

    return $FareQuoteDtoCopyWith<$Res>(_value.fareQuote!, (value) {
      return _then(_value.copyWith(fareQuote: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LocationDtoCopyWith<$Res> get pickupLocation {
    return $LocationDtoCopyWith<$Res>(_value.pickupLocation, (value) {
      return _then(_value.copyWith(pickupLocation: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LocationDtoCopyWith<$Res> get dropoffLocation {
    return $LocationDtoCopyWith<$Res>(_value.dropoffLocation, (value) {
      return _then(_value.copyWith(dropoffLocation: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BookingImplCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$$BookingImplCopyWith(
          _$BookingImpl value, $Res Function(_$BookingImpl) then) =
      __$$BookingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String rideId,
      String passengerId,
      int seats,
      FareQuoteDto? fareQuote,
      LocationDto pickupLocation,
      LocationDto dropoffLocation,
      String? pickupAddress,
      String? dropoffAddress,
      BookingStatus status,
      int? pickupStopSequence,
      int? dropoffStopSequence,
      DateTime? createdAt,
      DateTime? updatedAt});

  @override
  $FareQuoteDtoCopyWith<$Res>? get fareQuote;
  @override
  $LocationDtoCopyWith<$Res> get pickupLocation;
  @override
  $LocationDtoCopyWith<$Res> get dropoffLocation;
}

/// @nodoc
class __$$BookingImplCopyWithImpl<$Res>
    extends _$BookingCopyWithImpl<$Res, _$BookingImpl>
    implements _$$BookingImplCopyWith<$Res> {
  __$$BookingImplCopyWithImpl(
      _$BookingImpl _value, $Res Function(_$BookingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rideId = null,
    Object? passengerId = null,
    Object? seats = null,
    Object? fareQuote = freezed,
    Object? pickupLocation = null,
    Object? dropoffLocation = null,
    Object? pickupAddress = freezed,
    Object? dropoffAddress = freezed,
    Object? status = null,
    Object? pickupStopSequence = freezed,
    Object? dropoffStopSequence = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$BookingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rideId: null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
      passengerId: null == passengerId
          ? _value.passengerId
          : passengerId // ignore: cast_nullable_to_non_nullable
              as String,
      seats: null == seats
          ? _value.seats
          : seats // ignore: cast_nullable_to_non_nullable
              as int,
      fareQuote: freezed == fareQuote
          ? _value.fareQuote
          : fareQuote // ignore: cast_nullable_to_non_nullable
              as FareQuoteDto?,
      pickupLocation: null == pickupLocation
          ? _value.pickupLocation
          : pickupLocation // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      dropoffLocation: null == dropoffLocation
          ? _value.dropoffLocation
          : dropoffLocation // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      pickupAddress: freezed == pickupAddress
          ? _value.pickupAddress
          : pickupAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      dropoffAddress: freezed == dropoffAddress
          ? _value.dropoffAddress
          : dropoffAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
      pickupStopSequence: freezed == pickupStopSequence
          ? _value.pickupStopSequence
          : pickupStopSequence // ignore: cast_nullable_to_non_nullable
              as int?,
      dropoffStopSequence: freezed == dropoffStopSequence
          ? _value.dropoffStopSequence
          : dropoffStopSequence // ignore: cast_nullable_to_non_nullable
              as int?,
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
class _$BookingImpl implements _Booking {
  const _$BookingImpl(
      {required this.id,
      required this.rideId,
      required this.passengerId,
      required this.seats,
      required this.fareQuote,
      required this.pickupLocation,
      required this.dropoffLocation,
      this.pickupAddress,
      this.dropoffAddress,
      required this.status,
      this.pickupStopSequence,
      this.dropoffStopSequence,
      this.createdAt,
      this.updatedAt});

  factory _$BookingImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingImplFromJson(json);

  @override
  final String id;
  @override
  final String rideId;
  @override
  final String passengerId;
  @override
  final int seats;
  @override
  final FareQuoteDto? fareQuote;
  @override
  final LocationDto pickupLocation;
  @override
  final LocationDto dropoffLocation;
  @override
  final String? pickupAddress;
  @override
  final String? dropoffAddress;
  @override
  final BookingStatus status;
  @override
  final int? pickupStopSequence;
  @override
  final int? dropoffStopSequence;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Booking(id: $id, rideId: $rideId, passengerId: $passengerId, seats: $seats, fareQuote: $fareQuote, pickupLocation: $pickupLocation, dropoffLocation: $dropoffLocation, pickupAddress: $pickupAddress, dropoffAddress: $dropoffAddress, status: $status, pickupStopSequence: $pickupStopSequence, dropoffStopSequence: $dropoffStopSequence, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.passengerId, passengerId) ||
                other.passengerId == passengerId) &&
            (identical(other.seats, seats) || other.seats == seats) &&
            (identical(other.fareQuote, fareQuote) ||
                other.fareQuote == fareQuote) &&
            (identical(other.pickupLocation, pickupLocation) ||
                other.pickupLocation == pickupLocation) &&
            (identical(other.dropoffLocation, dropoffLocation) ||
                other.dropoffLocation == dropoffLocation) &&
            (identical(other.pickupAddress, pickupAddress) ||
                other.pickupAddress == pickupAddress) &&
            (identical(other.dropoffAddress, dropoffAddress) ||
                other.dropoffAddress == dropoffAddress) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.pickupStopSequence, pickupStopSequence) ||
                other.pickupStopSequence == pickupStopSequence) &&
            (identical(other.dropoffStopSequence, dropoffStopSequence) ||
                other.dropoffStopSequence == dropoffStopSequence) &&
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
      rideId,
      passengerId,
      seats,
      fareQuote,
      pickupLocation,
      dropoffLocation,
      pickupAddress,
      dropoffAddress,
      status,
      pickupStopSequence,
      dropoffStopSequence,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingImplCopyWith<_$BookingImpl> get copyWith =>
      __$$BookingImplCopyWithImpl<_$BookingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingImplToJson(
      this,
    );
  }
}

abstract class _Booking implements Booking {
  const factory _Booking(
      {required final String id,
      required final String rideId,
      required final String passengerId,
      required final int seats,
      required final FareQuoteDto? fareQuote,
      required final LocationDto pickupLocation,
      required final LocationDto dropoffLocation,
      final String? pickupAddress,
      final String? dropoffAddress,
      required final BookingStatus status,
      final int? pickupStopSequence,
      final int? dropoffStopSequence,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$BookingImpl;

  factory _Booking.fromJson(Map<String, dynamic> json) = _$BookingImpl.fromJson;

  @override
  String get id;
  @override
  String get rideId;
  @override
  String get passengerId;
  @override
  int get seats;
  @override
  FareQuoteDto? get fareQuote;
  @override
  LocationDto get pickupLocation;
  @override
  LocationDto get dropoffLocation;
  @override
  String? get pickupAddress;
  @override
  String? get dropoffAddress;
  @override
  BookingStatus get status;
  @override
  int? get pickupStopSequence;
  @override
  int? get dropoffStopSequence;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$BookingImplCopyWith<_$BookingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CancelBookingRequest _$CancelBookingRequestFromJson(Map<String, dynamic> json) {
  return _CancelBookingRequest.fromJson(json);
}

/// @nodoc
mixin _$CancelBookingRequest {
  String? get reason => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CancelBookingRequestCopyWith<CancelBookingRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CancelBookingRequestCopyWith<$Res> {
  factory $CancelBookingRequestCopyWith(CancelBookingRequest value,
          $Res Function(CancelBookingRequest) then) =
      _$CancelBookingRequestCopyWithImpl<$Res, CancelBookingRequest>;
  @useResult
  $Res call({String? reason});
}

/// @nodoc
class _$CancelBookingRequestCopyWithImpl<$Res,
        $Val extends CancelBookingRequest>
    implements $CancelBookingRequestCopyWith<$Res> {
  _$CancelBookingRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reason = freezed,
  }) {
    return _then(_value.copyWith(
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CancelBookingRequestImplCopyWith<$Res>
    implements $CancelBookingRequestCopyWith<$Res> {
  factory _$$CancelBookingRequestImplCopyWith(_$CancelBookingRequestImpl value,
          $Res Function(_$CancelBookingRequestImpl) then) =
      __$$CancelBookingRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? reason});
}

/// @nodoc
class __$$CancelBookingRequestImplCopyWithImpl<$Res>
    extends _$CancelBookingRequestCopyWithImpl<$Res, _$CancelBookingRequestImpl>
    implements _$$CancelBookingRequestImplCopyWith<$Res> {
  __$$CancelBookingRequestImplCopyWithImpl(_$CancelBookingRequestImpl _value,
      $Res Function(_$CancelBookingRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reason = freezed,
  }) {
    return _then(_$CancelBookingRequestImpl(
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CancelBookingRequestImpl implements _CancelBookingRequest {
  const _$CancelBookingRequestImpl({this.reason});

  factory _$CancelBookingRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CancelBookingRequestImplFromJson(json);

  @override
  final String? reason;

  @override
  String toString() {
    return 'CancelBookingRequest(reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CancelBookingRequestImpl &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, reason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CancelBookingRequestImplCopyWith<_$CancelBookingRequestImpl>
      get copyWith =>
          __$$CancelBookingRequestImplCopyWithImpl<_$CancelBookingRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CancelBookingRequestImplToJson(
      this,
    );
  }
}

abstract class _CancelBookingRequest implements CancelBookingRequest {
  const factory _CancelBookingRequest({final String? reason}) =
      _$CancelBookingRequestImpl;

  factory _CancelBookingRequest.fromJson(Map<String, dynamic> json) =
      _$CancelBookingRequestImpl.fromJson;

  @override
  String? get reason;
  @override
  @JsonKey(ignore: true)
  _$$CancelBookingRequestImplCopyWith<_$CancelBookingRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

FareQuoteRequest _$FareQuoteRequestFromJson(Map<String, dynamic> json) {
  return _FareQuoteRequest.fromJson(json);
}

/// @nodoc
mixin _$FareQuoteRequest {
  String get rideId => throw _privateConstructorUsedError;
  LocationDto get pickup => throw _privateConstructorUsedError;
  LocationDto get dropoff => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FareQuoteRequestCopyWith<FareQuoteRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FareQuoteRequestCopyWith<$Res> {
  factory $FareQuoteRequestCopyWith(
          FareQuoteRequest value, $Res Function(FareQuoteRequest) then) =
      _$FareQuoteRequestCopyWithImpl<$Res, FareQuoteRequest>;
  @useResult
  $Res call({String rideId, LocationDto pickup, LocationDto dropoff});

  $LocationDtoCopyWith<$Res> get pickup;
  $LocationDtoCopyWith<$Res> get dropoff;
}

/// @nodoc
class _$FareQuoteRequestCopyWithImpl<$Res, $Val extends FareQuoteRequest>
    implements $FareQuoteRequestCopyWith<$Res> {
  _$FareQuoteRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
    Object? pickup = null,
    Object? dropoff = null,
  }) {
    return _then(_value.copyWith(
      rideId: null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
      pickup: null == pickup
          ? _value.pickup
          : pickup // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      dropoff: null == dropoff
          ? _value.dropoff
          : dropoff // ignore: cast_nullable_to_non_nullable
              as LocationDto,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $LocationDtoCopyWith<$Res> get pickup {
    return $LocationDtoCopyWith<$Res>(_value.pickup, (value) {
      return _then(_value.copyWith(pickup: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LocationDtoCopyWith<$Res> get dropoff {
    return $LocationDtoCopyWith<$Res>(_value.dropoff, (value) {
      return _then(_value.copyWith(dropoff: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FareQuoteRequestImplCopyWith<$Res>
    implements $FareQuoteRequestCopyWith<$Res> {
  factory _$$FareQuoteRequestImplCopyWith(_$FareQuoteRequestImpl value,
          $Res Function(_$FareQuoteRequestImpl) then) =
      __$$FareQuoteRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String rideId, LocationDto pickup, LocationDto dropoff});

  @override
  $LocationDtoCopyWith<$Res> get pickup;
  @override
  $LocationDtoCopyWith<$Res> get dropoff;
}

/// @nodoc
class __$$FareQuoteRequestImplCopyWithImpl<$Res>
    extends _$FareQuoteRequestCopyWithImpl<$Res, _$FareQuoteRequestImpl>
    implements _$$FareQuoteRequestImplCopyWith<$Res> {
  __$$FareQuoteRequestImplCopyWithImpl(_$FareQuoteRequestImpl _value,
      $Res Function(_$FareQuoteRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
    Object? pickup = null,
    Object? dropoff = null,
  }) {
    return _then(_$FareQuoteRequestImpl(
      rideId: null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
      pickup: null == pickup
          ? _value.pickup
          : pickup // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      dropoff: null == dropoff
          ? _value.dropoff
          : dropoff // ignore: cast_nullable_to_non_nullable
              as LocationDto,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FareQuoteRequestImpl implements _FareQuoteRequest {
  const _$FareQuoteRequestImpl(
      {required this.rideId, required this.pickup, required this.dropoff});

  factory _$FareQuoteRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$FareQuoteRequestImplFromJson(json);

  @override
  final String rideId;
  @override
  final LocationDto pickup;
  @override
  final LocationDto dropoff;

  @override
  String toString() {
    return 'FareQuoteRequest(rideId: $rideId, pickup: $pickup, dropoff: $dropoff)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FareQuoteRequestImpl &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.pickup, pickup) || other.pickup == pickup) &&
            (identical(other.dropoff, dropoff) || other.dropoff == dropoff));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, rideId, pickup, dropoff);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FareQuoteRequestImplCopyWith<_$FareQuoteRequestImpl> get copyWith =>
      __$$FareQuoteRequestImplCopyWithImpl<_$FareQuoteRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FareQuoteRequestImplToJson(
      this,
    );
  }
}

abstract class _FareQuoteRequest implements FareQuoteRequest {
  const factory _FareQuoteRequest(
      {required final String rideId,
      required final LocationDto pickup,
      required final LocationDto dropoff}) = _$FareQuoteRequestImpl;

  factory _FareQuoteRequest.fromJson(Map<String, dynamic> json) =
      _$FareQuoteRequestImpl.fromJson;

  @override
  String get rideId;
  @override
  LocationDto get pickup;
  @override
  LocationDto get dropoff;
  @override
  @JsonKey(ignore: true)
  _$$FareQuoteRequestImplCopyWith<_$FareQuoteRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RideHistoryItem _$RideHistoryItemFromJson(Map<String, dynamic> json) {
  return _RideHistoryItem.fromJson(json);
}

/// @nodoc
mixin _$RideHistoryItem {
  String get id => throw _privateConstructorUsedError;
  String get driverName => throw _privateConstructorUsedError;
  LocationDto get origin => throw _privateConstructorUsedError;
  LocationDto get destination => throw _privateConstructorUsedError;
  double get fare => throw _privateConstructorUsedError;
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RideHistoryItemCopyWith<RideHistoryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RideHistoryItemCopyWith<$Res> {
  factory $RideHistoryItemCopyWith(
          RideHistoryItem value, $Res Function(RideHistoryItem) then) =
      _$RideHistoryItemCopyWithImpl<$Res, RideHistoryItem>;
  @useResult
  $Res call(
      {String id,
      String driverName,
      LocationDto origin,
      LocationDto destination,
      double fare,
      DateTime scheduledAt,
      String? status});

  $LocationDtoCopyWith<$Res> get origin;
  $LocationDtoCopyWith<$Res> get destination;
}

/// @nodoc
class _$RideHistoryItemCopyWithImpl<$Res, $Val extends RideHistoryItem>
    implements $RideHistoryItemCopyWith<$Res> {
  _$RideHistoryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driverName = null,
    Object? origin = null,
    Object? destination = null,
    Object? fare = null,
    Object? scheduledAt = null,
    Object? status = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driverName: null == driverName
          ? _value.driverName
          : driverName // ignore: cast_nullable_to_non_nullable
              as String,
      origin: null == origin
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      fare: null == fare
          ? _value.fare
          : fare // ignore: cast_nullable_to_non_nullable
              as double,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $LocationDtoCopyWith<$Res> get origin {
    return $LocationDtoCopyWith<$Res>(_value.origin, (value) {
      return _then(_value.copyWith(origin: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LocationDtoCopyWith<$Res> get destination {
    return $LocationDtoCopyWith<$Res>(_value.destination, (value) {
      return _then(_value.copyWith(destination: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RideHistoryItemImplCopyWith<$Res>
    implements $RideHistoryItemCopyWith<$Res> {
  factory _$$RideHistoryItemImplCopyWith(_$RideHistoryItemImpl value,
          $Res Function(_$RideHistoryItemImpl) then) =
      __$$RideHistoryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String driverName,
      LocationDto origin,
      LocationDto destination,
      double fare,
      DateTime scheduledAt,
      String? status});

  @override
  $LocationDtoCopyWith<$Res> get origin;
  @override
  $LocationDtoCopyWith<$Res> get destination;
}

/// @nodoc
class __$$RideHistoryItemImplCopyWithImpl<$Res>
    extends _$RideHistoryItemCopyWithImpl<$Res, _$RideHistoryItemImpl>
    implements _$$RideHistoryItemImplCopyWith<$Res> {
  __$$RideHistoryItemImplCopyWithImpl(
      _$RideHistoryItemImpl _value, $Res Function(_$RideHistoryItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driverName = null,
    Object? origin = null,
    Object? destination = null,
    Object? fare = null,
    Object? scheduledAt = null,
    Object? status = freezed,
  }) {
    return _then(_$RideHistoryItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driverName: null == driverName
          ? _value.driverName
          : driverName // ignore: cast_nullable_to_non_nullable
              as String,
      origin: null == origin
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      fare: null == fare
          ? _value.fare
          : fare // ignore: cast_nullable_to_non_nullable
              as double,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RideHistoryItemImpl implements _RideHistoryItem {
  const _$RideHistoryItemImpl(
      {required this.id,
      required this.driverName,
      required this.origin,
      required this.destination,
      required this.fare,
      required this.scheduledAt,
      this.status});

  factory _$RideHistoryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$RideHistoryItemImplFromJson(json);

  @override
  final String id;
  @override
  final String driverName;
  @override
  final LocationDto origin;
  @override
  final LocationDto destination;
  @override
  final double fare;
  @override
  final DateTime scheduledAt;
  @override
  final String? status;

  @override
  String toString() {
    return 'RideHistoryItem(id: $id, driverName: $driverName, origin: $origin, destination: $destination, fare: $fare, scheduledAt: $scheduledAt, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RideHistoryItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.driverName, driverName) ||
                other.driverName == driverName) &&
            (identical(other.origin, origin) || other.origin == origin) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.fare, fare) || other.fare == fare) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, driverName, origin,
      destination, fare, scheduledAt, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RideHistoryItemImplCopyWith<_$RideHistoryItemImpl> get copyWith =>
      __$$RideHistoryItemImplCopyWithImpl<_$RideHistoryItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RideHistoryItemImplToJson(
      this,
    );
  }
}

abstract class _RideHistoryItem implements RideHistoryItem {
  const factory _RideHistoryItem(
      {required final String id,
      required final String driverName,
      required final LocationDto origin,
      required final LocationDto destination,
      required final double fare,
      required final DateTime scheduledAt,
      final String? status}) = _$RideHistoryItemImpl;

  factory _RideHistoryItem.fromJson(Map<String, dynamic> json) =
      _$RideHistoryItemImpl.fromJson;

  @override
  String get id;
  @override
  String get driverName;
  @override
  LocationDto get origin;
  @override
  LocationDto get destination;
  @override
  double get fare;
  @override
  DateTime get scheduledAt;
  @override
  String? get status;
  @override
  @JsonKey(ignore: true)
  _$$RideHistoryItemImplCopyWith<_$RideHistoryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
