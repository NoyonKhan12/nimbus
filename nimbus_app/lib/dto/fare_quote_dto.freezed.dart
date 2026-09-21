// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fare_quote_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FareQuoteDto _$FareQuoteDtoFromJson(Map<String, dynamic> json) {
  return _FareQuoteDto.fromJson(json);
}

/// @nodoc
mixin _$FareQuoteDto {
  String get quoteId => throw _privateConstructorUsedError;
  String? get bookingId => throw _privateConstructorUsedError;
  String get fareRuleVersion => throw _privateConstructorUsedError;
  String get routeVersion => throw _privateConstructorUsedError;
  int get distanceMeters => throw _privateConstructorUsedError;
  int get durationSeconds => throw _privateConstructorUsedError;
  double get baseFare => throw _privateConstructorUsedError;
  double get distanceCharge => throw _privateConstructorUsedError;
  double get timeCharge => throw _privateConstructorUsedError;
  double get serviceFee => throw _privateConstructorUsedError;
  double get tax => throw _privateConstructorUsedError;
  double get grossFare => throw _privateConstructorUsedError;
  double get discount => throw _privateConstructorUsedError;
  double get finalPayable => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FareQuoteDtoCopyWith<FareQuoteDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FareQuoteDtoCopyWith<$Res> {
  factory $FareQuoteDtoCopyWith(
          FareQuoteDto value, $Res Function(FareQuoteDto) then) =
      _$FareQuoteDtoCopyWithImpl<$Res, FareQuoteDto>;
  @useResult
  $Res call(
      {String quoteId,
      String? bookingId,
      String fareRuleVersion,
      String routeVersion,
      int distanceMeters,
      int durationSeconds,
      double baseFare,
      double distanceCharge,
      double timeCharge,
      double serviceFee,
      double tax,
      double grossFare,
      double discount,
      double finalPayable,
      String currency,
      DateTime expiresAt});
}

/// @nodoc
class _$FareQuoteDtoCopyWithImpl<$Res, $Val extends FareQuoteDto>
    implements $FareQuoteDtoCopyWith<$Res> {
  _$FareQuoteDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? quoteId = null,
    Object? bookingId = freezed,
    Object? fareRuleVersion = null,
    Object? routeVersion = null,
    Object? distanceMeters = null,
    Object? durationSeconds = null,
    Object? baseFare = null,
    Object? distanceCharge = null,
    Object? timeCharge = null,
    Object? serviceFee = null,
    Object? tax = null,
    Object? grossFare = null,
    Object? discount = null,
    Object? finalPayable = null,
    Object? currency = null,
    Object? expiresAt = null,
  }) {
    return _then(_value.copyWith(
      quoteId: null == quoteId
          ? _value.quoteId
          : quoteId // ignore: cast_nullable_to_non_nullable
              as String,
      bookingId: freezed == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String?,
      fareRuleVersion: null == fareRuleVersion
          ? _value.fareRuleVersion
          : fareRuleVersion // ignore: cast_nullable_to_non_nullable
              as String,
      routeVersion: null == routeVersion
          ? _value.routeVersion
          : routeVersion // ignore: cast_nullable_to_non_nullable
              as String,
      distanceMeters: null == distanceMeters
          ? _value.distanceMeters
          : distanceMeters // ignore: cast_nullable_to_non_nullable
              as int,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      baseFare: null == baseFare
          ? _value.baseFare
          : baseFare // ignore: cast_nullable_to_non_nullable
              as double,
      distanceCharge: null == distanceCharge
          ? _value.distanceCharge
          : distanceCharge // ignore: cast_nullable_to_non_nullable
              as double,
      timeCharge: null == timeCharge
          ? _value.timeCharge
          : timeCharge // ignore: cast_nullable_to_non_nullable
              as double,
      serviceFee: null == serviceFee
          ? _value.serviceFee
          : serviceFee // ignore: cast_nullable_to_non_nullable
              as double,
      tax: null == tax
          ? _value.tax
          : tax // ignore: cast_nullable_to_non_nullable
              as double,
      grossFare: null == grossFare
          ? _value.grossFare
          : grossFare // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      finalPayable: null == finalPayable
          ? _value.finalPayable
          : finalPayable // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FareQuoteDtoImplCopyWith<$Res>
    implements $FareQuoteDtoCopyWith<$Res> {
  factory _$$FareQuoteDtoImplCopyWith(
          _$FareQuoteDtoImpl value, $Res Function(_$FareQuoteDtoImpl) then) =
      __$$FareQuoteDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String quoteId,
      String? bookingId,
      String fareRuleVersion,
      String routeVersion,
      int distanceMeters,
      int durationSeconds,
      double baseFare,
      double distanceCharge,
      double timeCharge,
      double serviceFee,
      double tax,
      double grossFare,
      double discount,
      double finalPayable,
      String currency,
      DateTime expiresAt});
}

/// @nodoc
class __$$FareQuoteDtoImplCopyWithImpl<$Res>
    extends _$FareQuoteDtoCopyWithImpl<$Res, _$FareQuoteDtoImpl>
    implements _$$FareQuoteDtoImplCopyWith<$Res> {
  __$$FareQuoteDtoImplCopyWithImpl(
      _$FareQuoteDtoImpl _value, $Res Function(_$FareQuoteDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? quoteId = null,
    Object? bookingId = freezed,
    Object? fareRuleVersion = null,
    Object? routeVersion = null,
    Object? distanceMeters = null,
    Object? durationSeconds = null,
    Object? baseFare = null,
    Object? distanceCharge = null,
    Object? timeCharge = null,
    Object? serviceFee = null,
    Object? tax = null,
    Object? grossFare = null,
    Object? discount = null,
    Object? finalPayable = null,
    Object? currency = null,
    Object? expiresAt = null,
  }) {
    return _then(_$FareQuoteDtoImpl(
      quoteId: null == quoteId
          ? _value.quoteId
          : quoteId // ignore: cast_nullable_to_non_nullable
              as String,
      bookingId: freezed == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String?,
      fareRuleVersion: null == fareRuleVersion
          ? _value.fareRuleVersion
          : fareRuleVersion // ignore: cast_nullable_to_non_nullable
              as String,
      routeVersion: null == routeVersion
          ? _value.routeVersion
          : routeVersion // ignore: cast_nullable_to_non_nullable
              as String,
      distanceMeters: null == distanceMeters
          ? _value.distanceMeters
          : distanceMeters // ignore: cast_nullable_to_non_nullable
              as int,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      baseFare: null == baseFare
          ? _value.baseFare
          : baseFare // ignore: cast_nullable_to_non_nullable
              as double,
      distanceCharge: null == distanceCharge
          ? _value.distanceCharge
          : distanceCharge // ignore: cast_nullable_to_non_nullable
              as double,
      timeCharge: null == timeCharge
          ? _value.timeCharge
          : timeCharge // ignore: cast_nullable_to_non_nullable
              as double,
      serviceFee: null == serviceFee
          ? _value.serviceFee
          : serviceFee // ignore: cast_nullable_to_non_nullable
              as double,
      tax: null == tax
          ? _value.tax
          : tax // ignore: cast_nullable_to_non_nullable
              as double,
      grossFare: null == grossFare
          ? _value.grossFare
          : grossFare // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      finalPayable: null == finalPayable
          ? _value.finalPayable
          : finalPayable // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FareQuoteDtoImpl implements _FareQuoteDto {
  const _$FareQuoteDtoImpl(
      {required this.quoteId,
      this.bookingId,
      required this.fareRuleVersion,
      required this.routeVersion,
      required this.distanceMeters,
      required this.durationSeconds,
      required this.baseFare,
      required this.distanceCharge,
      required this.timeCharge,
      required this.serviceFee,
      required this.tax,
      required this.grossFare,
      required this.discount,
      required this.finalPayable,
      required this.currency,
      required this.expiresAt});

  factory _$FareQuoteDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$FareQuoteDtoImplFromJson(json);

  @override
  final String quoteId;
  @override
  final String? bookingId;
  @override
  final String fareRuleVersion;
  @override
  final String routeVersion;
  @override
  final int distanceMeters;
  @override
  final int durationSeconds;
  @override
  final double baseFare;
  @override
  final double distanceCharge;
  @override
  final double timeCharge;
  @override
  final double serviceFee;
  @override
  final double tax;
  @override
  final double grossFare;
  @override
  final double discount;
  @override
  final double finalPayable;
  @override
  final String currency;
  @override
  final DateTime expiresAt;

  @override
  String toString() {
    return 'FareQuoteDto(quoteId: $quoteId, bookingId: $bookingId, fareRuleVersion: $fareRuleVersion, routeVersion: $routeVersion, distanceMeters: $distanceMeters, durationSeconds: $durationSeconds, baseFare: $baseFare, distanceCharge: $distanceCharge, timeCharge: $timeCharge, serviceFee: $serviceFee, tax: $tax, grossFare: $grossFare, discount: $discount, finalPayable: $finalPayable, currency: $currency, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FareQuoteDtoImpl &&
            (identical(other.quoteId, quoteId) || other.quoteId == quoteId) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.fareRuleVersion, fareRuleVersion) ||
                other.fareRuleVersion == fareRuleVersion) &&
            (identical(other.routeVersion, routeVersion) ||
                other.routeVersion == routeVersion) &&
            (identical(other.distanceMeters, distanceMeters) ||
                other.distanceMeters == distanceMeters) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.baseFare, baseFare) ||
                other.baseFare == baseFare) &&
            (identical(other.distanceCharge, distanceCharge) ||
                other.distanceCharge == distanceCharge) &&
            (identical(other.timeCharge, timeCharge) ||
                other.timeCharge == timeCharge) &&
            (identical(other.serviceFee, serviceFee) ||
                other.serviceFee == serviceFee) &&
            (identical(other.tax, tax) || other.tax == tax) &&
            (identical(other.grossFare, grossFare) ||
                other.grossFare == grossFare) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.finalPayable, finalPayable) ||
                other.finalPayable == finalPayable) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      quoteId,
      bookingId,
      fareRuleVersion,
      routeVersion,
      distanceMeters,
      durationSeconds,
      baseFare,
      distanceCharge,
      timeCharge,
      serviceFee,
      tax,
      grossFare,
      discount,
      finalPayable,
      currency,
      expiresAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FareQuoteDtoImplCopyWith<_$FareQuoteDtoImpl> get copyWith =>
      __$$FareQuoteDtoImplCopyWithImpl<_$FareQuoteDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FareQuoteDtoImplToJson(
      this,
    );
  }
}

abstract class _FareQuoteDto implements FareQuoteDto {
  const factory _FareQuoteDto(
      {required final String quoteId,
      final String? bookingId,
      required final String fareRuleVersion,
      required final String routeVersion,
      required final int distanceMeters,
      required final int durationSeconds,
      required final double baseFare,
      required final double distanceCharge,
      required final double timeCharge,
      required final double serviceFee,
      required final double tax,
      required final double grossFare,
      required final double discount,
      required final double finalPayable,
      required final String currency,
      required final DateTime expiresAt}) = _$FareQuoteDtoImpl;

  factory _FareQuoteDto.fromJson(Map<String, dynamic> json) =
      _$FareQuoteDtoImpl.fromJson;

  @override
  String get quoteId;
  @override
  String? get bookingId;
  @override
  String get fareRuleVersion;
  @override
  String get routeVersion;
  @override
  int get distanceMeters;
  @override
  int get durationSeconds;
  @override
  double get baseFare;
  @override
  double get distanceCharge;
  @override
  double get timeCharge;
  @override
  double get serviceFee;
  @override
  double get tax;
  @override
  double get grossFare;
  @override
  double get discount;
  @override
  double get finalPayable;
  @override
  String get currency;
  @override
  DateTime get expiresAt;
  @override
  @JsonKey(ignore: true)
  _$$FareQuoteDtoImplCopyWith<_$FareQuoteDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
