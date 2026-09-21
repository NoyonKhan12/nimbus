// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_ride_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreateRideRequest _$CreateRideRequestFromJson(Map<String, dynamic> json) {
  return _CreateRideRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateRideRequest {
  String get rideType =>
      throw _privateConstructorUsedError; // SCHEDULED, INSTANT
  DateTime? get scheduledAt => throw _privateConstructorUsedError;
  String get vehicleId => throw _privateConstructorUsedError;
  LocationDto get origin => throw _privateConstructorUsedError;
  LocationDto get destination => throw _privateConstructorUsedError;
  int get availableSeats => throw _privateConstructorUsedError;
  int? get maxDetourMeters => throw _privateConstructorUsedError;
  int? get maxWaitSeconds => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateRideRequestCopyWith<CreateRideRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateRideRequestCopyWith<$Res> {
  factory $CreateRideRequestCopyWith(
          CreateRideRequest value, $Res Function(CreateRideRequest) then) =
      _$CreateRideRequestCopyWithImpl<$Res, CreateRideRequest>;
  @useResult
  $Res call(
      {String rideType,
      DateTime? scheduledAt,
      String vehicleId,
      LocationDto origin,
      LocationDto destination,
      int availableSeats,
      int? maxDetourMeters,
      int? maxWaitSeconds,
      String? notes});

  $LocationDtoCopyWith<$Res> get origin;
  $LocationDtoCopyWith<$Res> get destination;
}

/// @nodoc
class _$CreateRideRequestCopyWithImpl<$Res, $Val extends CreateRideRequest>
    implements $CreateRideRequestCopyWith<$Res> {
  _$CreateRideRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideType = null,
    Object? scheduledAt = freezed,
    Object? vehicleId = null,
    Object? origin = null,
    Object? destination = null,
    Object? availableSeats = null,
    Object? maxDetourMeters = freezed,
    Object? maxWaitSeconds = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      rideType: null == rideType
          ? _value.rideType
          : rideType // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      vehicleId: null == vehicleId
          ? _value.vehicleId
          : vehicleId // ignore: cast_nullable_to_non_nullable
              as String,
      origin: null == origin
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as LocationDto,
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
abstract class _$$CreateRideRequestImplCopyWith<$Res>
    implements $CreateRideRequestCopyWith<$Res> {
  factory _$$CreateRideRequestImplCopyWith(_$CreateRideRequestImpl value,
          $Res Function(_$CreateRideRequestImpl) then) =
      __$$CreateRideRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String rideType,
      DateTime? scheduledAt,
      String vehicleId,
      LocationDto origin,
      LocationDto destination,
      int availableSeats,
      int? maxDetourMeters,
      int? maxWaitSeconds,
      String? notes});

  @override
  $LocationDtoCopyWith<$Res> get origin;
  @override
  $LocationDtoCopyWith<$Res> get destination;
}

/// @nodoc
class __$$CreateRideRequestImplCopyWithImpl<$Res>
    extends _$CreateRideRequestCopyWithImpl<$Res, _$CreateRideRequestImpl>
    implements _$$CreateRideRequestImplCopyWith<$Res> {
  __$$CreateRideRequestImplCopyWithImpl(_$CreateRideRequestImpl _value,
      $Res Function(_$CreateRideRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideType = null,
    Object? scheduledAt = freezed,
    Object? vehicleId = null,
    Object? origin = null,
    Object? destination = null,
    Object? availableSeats = null,
    Object? maxDetourMeters = freezed,
    Object? maxWaitSeconds = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$CreateRideRequestImpl(
      rideType: null == rideType
          ? _value.rideType
          : rideType // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      vehicleId: null == vehicleId
          ? _value.vehicleId
          : vehicleId // ignore: cast_nullable_to_non_nullable
              as String,
      origin: null == origin
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as LocationDto,
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateRideRequestImpl implements _CreateRideRequest {
  const _$CreateRideRequestImpl(
      {required this.rideType,
      this.scheduledAt,
      required this.vehicleId,
      required this.origin,
      required this.destination,
      required this.availableSeats,
      this.maxDetourMeters,
      this.maxWaitSeconds,
      this.notes});

  factory _$CreateRideRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateRideRequestImplFromJson(json);

  @override
  final String rideType;
// SCHEDULED, INSTANT
  @override
  final DateTime? scheduledAt;
  @override
  final String vehicleId;
  @override
  final LocationDto origin;
  @override
  final LocationDto destination;
  @override
  final int availableSeats;
  @override
  final int? maxDetourMeters;
  @override
  final int? maxWaitSeconds;
  @override
  final String? notes;

  @override
  String toString() {
    return 'CreateRideRequest(rideType: $rideType, scheduledAt: $scheduledAt, vehicleId: $vehicleId, origin: $origin, destination: $destination, availableSeats: $availableSeats, maxDetourMeters: $maxDetourMeters, maxWaitSeconds: $maxWaitSeconds, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateRideRequestImpl &&
            (identical(other.rideType, rideType) ||
                other.rideType == rideType) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.vehicleId, vehicleId) ||
                other.vehicleId == vehicleId) &&
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
  int get hashCode => Object.hash(
      runtimeType,
      rideType,
      scheduledAt,
      vehicleId,
      origin,
      destination,
      availableSeats,
      maxDetourMeters,
      maxWaitSeconds,
      notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateRideRequestImplCopyWith<_$CreateRideRequestImpl> get copyWith =>
      __$$CreateRideRequestImplCopyWithImpl<_$CreateRideRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateRideRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateRideRequest implements CreateRideRequest {
  const factory _CreateRideRequest(
      {required final String rideType,
      final DateTime? scheduledAt,
      required final String vehicleId,
      required final LocationDto origin,
      required final LocationDto destination,
      required final int availableSeats,
      final int? maxDetourMeters,
      final int? maxWaitSeconds,
      final String? notes}) = _$CreateRideRequestImpl;

  factory _CreateRideRequest.fromJson(Map<String, dynamic> json) =
      _$CreateRideRequestImpl.fromJson;

  @override
  String get rideType;
  @override // SCHEDULED, INSTANT
  DateTime? get scheduledAt;
  @override
  String get vehicleId;
  @override
  LocationDto get origin;
  @override
  LocationDto get destination;
  @override
  int get availableSeats;
  @override
  int? get maxDetourMeters;
  @override
  int? get maxWaitSeconds;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$CreateRideRequestImplCopyWith<_$CreateRideRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateBookingRequest _$CreateBookingRequestFromJson(Map<String, dynamic> json) {
  return _CreateBookingRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateBookingRequest {
  int get seatCount => throw _privateConstructorUsedError;
  LocationDto get pickupLocation => throw _privateConstructorUsedError;
  String? get pickupAddress => throw _privateConstructorUsedError;
  LocationDto get dropoffLocation => throw _privateConstructorUsedError;
  String? get dropoffAddress => throw _privateConstructorUsedError;
  String get fareQuoteId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateBookingRequestCopyWith<CreateBookingRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateBookingRequestCopyWith<$Res> {
  factory $CreateBookingRequestCopyWith(CreateBookingRequest value,
          $Res Function(CreateBookingRequest) then) =
      _$CreateBookingRequestCopyWithImpl<$Res, CreateBookingRequest>;
  @useResult
  $Res call(
      {int seatCount,
      LocationDto pickupLocation,
      String? pickupAddress,
      LocationDto dropoffLocation,
      String? dropoffAddress,
      String fareQuoteId});

  $LocationDtoCopyWith<$Res> get pickupLocation;
  $LocationDtoCopyWith<$Res> get dropoffLocation;
}

/// @nodoc
class _$CreateBookingRequestCopyWithImpl<$Res,
        $Val extends CreateBookingRequest>
    implements $CreateBookingRequestCopyWith<$Res> {
  _$CreateBookingRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? seatCount = null,
    Object? pickupLocation = null,
    Object? pickupAddress = freezed,
    Object? dropoffLocation = null,
    Object? dropoffAddress = freezed,
    Object? fareQuoteId = null,
  }) {
    return _then(_value.copyWith(
      seatCount: null == seatCount
          ? _value.seatCount
          : seatCount // ignore: cast_nullable_to_non_nullable
              as int,
      pickupLocation: null == pickupLocation
          ? _value.pickupLocation
          : pickupLocation // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      pickupAddress: freezed == pickupAddress
          ? _value.pickupAddress
          : pickupAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      dropoffLocation: null == dropoffLocation
          ? _value.dropoffLocation
          : dropoffLocation // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      dropoffAddress: freezed == dropoffAddress
          ? _value.dropoffAddress
          : dropoffAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      fareQuoteId: null == fareQuoteId
          ? _value.fareQuoteId
          : fareQuoteId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
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
abstract class _$$CreateBookingRequestImplCopyWith<$Res>
    implements $CreateBookingRequestCopyWith<$Res> {
  factory _$$CreateBookingRequestImplCopyWith(_$CreateBookingRequestImpl value,
          $Res Function(_$CreateBookingRequestImpl) then) =
      __$$CreateBookingRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int seatCount,
      LocationDto pickupLocation,
      String? pickupAddress,
      LocationDto dropoffLocation,
      String? dropoffAddress,
      String fareQuoteId});

  @override
  $LocationDtoCopyWith<$Res> get pickupLocation;
  @override
  $LocationDtoCopyWith<$Res> get dropoffLocation;
}

/// @nodoc
class __$$CreateBookingRequestImplCopyWithImpl<$Res>
    extends _$CreateBookingRequestCopyWithImpl<$Res, _$CreateBookingRequestImpl>
    implements _$$CreateBookingRequestImplCopyWith<$Res> {
  __$$CreateBookingRequestImplCopyWithImpl(_$CreateBookingRequestImpl _value,
      $Res Function(_$CreateBookingRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? seatCount = null,
    Object? pickupLocation = null,
    Object? pickupAddress = freezed,
    Object? dropoffLocation = null,
    Object? dropoffAddress = freezed,
    Object? fareQuoteId = null,
  }) {
    return _then(_$CreateBookingRequestImpl(
      seatCount: null == seatCount
          ? _value.seatCount
          : seatCount // ignore: cast_nullable_to_non_nullable
              as int,
      pickupLocation: null == pickupLocation
          ? _value.pickupLocation
          : pickupLocation // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      pickupAddress: freezed == pickupAddress
          ? _value.pickupAddress
          : pickupAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      dropoffLocation: null == dropoffLocation
          ? _value.dropoffLocation
          : dropoffLocation // ignore: cast_nullable_to_non_nullable
              as LocationDto,
      dropoffAddress: freezed == dropoffAddress
          ? _value.dropoffAddress
          : dropoffAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      fareQuoteId: null == fareQuoteId
          ? _value.fareQuoteId
          : fareQuoteId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateBookingRequestImpl implements _CreateBookingRequest {
  const _$CreateBookingRequestImpl(
      {required this.seatCount,
      required this.pickupLocation,
      this.pickupAddress,
      required this.dropoffLocation,
      this.dropoffAddress,
      required this.fareQuoteId});

  factory _$CreateBookingRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateBookingRequestImplFromJson(json);

  @override
  final int seatCount;
  @override
  final LocationDto pickupLocation;
  @override
  final String? pickupAddress;
  @override
  final LocationDto dropoffLocation;
  @override
  final String? dropoffAddress;
  @override
  final String fareQuoteId;

  @override
  String toString() {
    return 'CreateBookingRequest(seatCount: $seatCount, pickupLocation: $pickupLocation, pickupAddress: $pickupAddress, dropoffLocation: $dropoffLocation, dropoffAddress: $dropoffAddress, fareQuoteId: $fareQuoteId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateBookingRequestImpl &&
            (identical(other.seatCount, seatCount) ||
                other.seatCount == seatCount) &&
            (identical(other.pickupLocation, pickupLocation) ||
                other.pickupLocation == pickupLocation) &&
            (identical(other.pickupAddress, pickupAddress) ||
                other.pickupAddress == pickupAddress) &&
            (identical(other.dropoffLocation, dropoffLocation) ||
                other.dropoffLocation == dropoffLocation) &&
            (identical(other.dropoffAddress, dropoffAddress) ||
                other.dropoffAddress == dropoffAddress) &&
            (identical(other.fareQuoteId, fareQuoteId) ||
                other.fareQuoteId == fareQuoteId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, seatCount, pickupLocation,
      pickupAddress, dropoffLocation, dropoffAddress, fareQuoteId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateBookingRequestImplCopyWith<_$CreateBookingRequestImpl>
      get copyWith =>
          __$$CreateBookingRequestImplCopyWithImpl<_$CreateBookingRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateBookingRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateBookingRequest implements CreateBookingRequest {
  const factory _CreateBookingRequest(
      {required final int seatCount,
      required final LocationDto pickupLocation,
      final String? pickupAddress,
      required final LocationDto dropoffLocation,
      final String? dropoffAddress,
      required final String fareQuoteId}) = _$CreateBookingRequestImpl;

  factory _CreateBookingRequest.fromJson(Map<String, dynamic> json) =
      _$CreateBookingRequestImpl.fromJson;

  @override
  int get seatCount;
  @override
  LocationDto get pickupLocation;
  @override
  String? get pickupAddress;
  @override
  LocationDto get dropoffLocation;
  @override
  String? get dropoffAddress;
  @override
  String get fareQuoteId;
  @override
  @JsonKey(ignore: true)
  _$$CreateBookingRequestImplCopyWith<_$CreateBookingRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PaymentRequest _$PaymentRequestFromJson(Map<String, dynamic> json) {
  return _PaymentRequest.fromJson(json);
}

/// @nodoc
mixin _$PaymentRequest {
  String get bookingId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get method =>
      throw _privateConstructorUsedError; // bkash, nagad, card, etc.
  String? get returnUrl => throw _privateConstructorUsedError;
  String get idempotencyKey => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PaymentRequestCopyWith<PaymentRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentRequestCopyWith<$Res> {
  factory $PaymentRequestCopyWith(
          PaymentRequest value, $Res Function(PaymentRequest) then) =
      _$PaymentRequestCopyWithImpl<$Res, PaymentRequest>;
  @useResult
  $Res call(
      {String bookingId,
      double amount,
      String method,
      String? returnUrl,
      String idempotencyKey});
}

/// @nodoc
class _$PaymentRequestCopyWithImpl<$Res, $Val extends PaymentRequest>
    implements $PaymentRequestCopyWith<$Res> {
  _$PaymentRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = null,
    Object? amount = null,
    Object? method = null,
    Object? returnUrl = freezed,
    Object? idempotencyKey = null,
  }) {
    return _then(_value.copyWith(
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      returnUrl: freezed == returnUrl
          ? _value.returnUrl
          : returnUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      idempotencyKey: null == idempotencyKey
          ? _value.idempotencyKey
          : idempotencyKey // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaymentRequestImplCopyWith<$Res>
    implements $PaymentRequestCopyWith<$Res> {
  factory _$$PaymentRequestImplCopyWith(_$PaymentRequestImpl value,
          $Res Function(_$PaymentRequestImpl) then) =
      __$$PaymentRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String bookingId,
      double amount,
      String method,
      String? returnUrl,
      String idempotencyKey});
}

/// @nodoc
class __$$PaymentRequestImplCopyWithImpl<$Res>
    extends _$PaymentRequestCopyWithImpl<$Res, _$PaymentRequestImpl>
    implements _$$PaymentRequestImplCopyWith<$Res> {
  __$$PaymentRequestImplCopyWithImpl(
      _$PaymentRequestImpl _value, $Res Function(_$PaymentRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = null,
    Object? amount = null,
    Object? method = null,
    Object? returnUrl = freezed,
    Object? idempotencyKey = null,
  }) {
    return _then(_$PaymentRequestImpl(
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      returnUrl: freezed == returnUrl
          ? _value.returnUrl
          : returnUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      idempotencyKey: null == idempotencyKey
          ? _value.idempotencyKey
          : idempotencyKey // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentRequestImpl implements _PaymentRequest {
  const _$PaymentRequestImpl(
      {required this.bookingId,
      required this.amount,
      required this.method,
      this.returnUrl,
      required this.idempotencyKey});

  factory _$PaymentRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentRequestImplFromJson(json);

  @override
  final String bookingId;
  @override
  final double amount;
  @override
  final String method;
// bkash, nagad, card, etc.
  @override
  final String? returnUrl;
  @override
  final String idempotencyKey;

  @override
  String toString() {
    return 'PaymentRequest(bookingId: $bookingId, amount: $amount, method: $method, returnUrl: $returnUrl, idempotencyKey: $idempotencyKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentRequestImpl &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.returnUrl, returnUrl) ||
                other.returnUrl == returnUrl) &&
            (identical(other.idempotencyKey, idempotencyKey) ||
                other.idempotencyKey == idempotencyKey));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, bookingId, amount, method, returnUrl, idempotencyKey);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentRequestImplCopyWith<_$PaymentRequestImpl> get copyWith =>
      __$$PaymentRequestImplCopyWithImpl<_$PaymentRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentRequestImplToJson(
      this,
    );
  }
}

abstract class _PaymentRequest implements PaymentRequest {
  const factory _PaymentRequest(
      {required final String bookingId,
      required final double amount,
      required final String method,
      final String? returnUrl,
      required final String idempotencyKey}) = _$PaymentRequestImpl;

  factory _PaymentRequest.fromJson(Map<String, dynamic> json) =
      _$PaymentRequestImpl.fromJson;

  @override
  String get bookingId;
  @override
  double get amount;
  @override
  String get method;
  @override // bkash, nagad, card, etc.
  String? get returnUrl;
  @override
  String get idempotencyKey;
  @override
  @JsonKey(ignore: true)
  _$$PaymentRequestImplCopyWith<_$PaymentRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
