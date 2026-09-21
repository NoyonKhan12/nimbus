// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voucher_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VoucherValidation _$VoucherValidationFromJson(Map<String, dynamic> json) {
  return _VoucherValidation.fromJson(json);
}

/// @nodoc
mixin _$VoucherValidation {
  bool get valid => throw _privateConstructorUsedError;
  double? get discountAmount => throw _privateConstructorUsedError;
  String? get voucherCode => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VoucherValidationCopyWith<VoucherValidation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoucherValidationCopyWith<$Res> {
  factory $VoucherValidationCopyWith(
          VoucherValidation value, $Res Function(VoucherValidation) then) =
      _$VoucherValidationCopyWithImpl<$Res, VoucherValidation>;
  @useResult
  $Res call(
      {bool valid,
      double? discountAmount,
      String? voucherCode,
      String? message});
}

/// @nodoc
class _$VoucherValidationCopyWithImpl<$Res, $Val extends VoucherValidation>
    implements $VoucherValidationCopyWith<$Res> {
  _$VoucherValidationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? valid = null,
    Object? discountAmount = freezed,
    Object? voucherCode = freezed,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      valid: null == valid
          ? _value.valid
          : valid // ignore: cast_nullable_to_non_nullable
              as bool,
      discountAmount: freezed == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      voucherCode: freezed == voucherCode
          ? _value.voucherCode
          : voucherCode // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VoucherValidationImplCopyWith<$Res>
    implements $VoucherValidationCopyWith<$Res> {
  factory _$$VoucherValidationImplCopyWith(_$VoucherValidationImpl value,
          $Res Function(_$VoucherValidationImpl) then) =
      __$$VoucherValidationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool valid,
      double? discountAmount,
      String? voucherCode,
      String? message});
}

/// @nodoc
class __$$VoucherValidationImplCopyWithImpl<$Res>
    extends _$VoucherValidationCopyWithImpl<$Res, _$VoucherValidationImpl>
    implements _$$VoucherValidationImplCopyWith<$Res> {
  __$$VoucherValidationImplCopyWithImpl(_$VoucherValidationImpl _value,
      $Res Function(_$VoucherValidationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? valid = null,
    Object? discountAmount = freezed,
    Object? voucherCode = freezed,
    Object? message = freezed,
  }) {
    return _then(_$VoucherValidationImpl(
      valid: null == valid
          ? _value.valid
          : valid // ignore: cast_nullable_to_non_nullable
              as bool,
      discountAmount: freezed == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      voucherCode: freezed == voucherCode
          ? _value.voucherCode
          : voucherCode // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VoucherValidationImpl implements _VoucherValidation {
  const _$VoucherValidationImpl(
      {required this.valid,
      required this.discountAmount,
      this.voucherCode,
      this.message});

  factory _$VoucherValidationImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoucherValidationImplFromJson(json);

  @override
  final bool valid;
  @override
  final double? discountAmount;
  @override
  final String? voucherCode;
  @override
  final String? message;

  @override
  String toString() {
    return 'VoucherValidation(valid: $valid, discountAmount: $discountAmount, voucherCode: $voucherCode, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoucherValidationImpl &&
            (identical(other.valid, valid) || other.valid == valid) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.voucherCode, voucherCode) ||
                other.voucherCode == voucherCode) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, valid, discountAmount, voucherCode, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VoucherValidationImplCopyWith<_$VoucherValidationImpl> get copyWith =>
      __$$VoucherValidationImplCopyWithImpl<_$VoucherValidationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoucherValidationImplToJson(
      this,
    );
  }
}

abstract class _VoucherValidation implements VoucherValidation {
  const factory _VoucherValidation(
      {required final bool valid,
      required final double? discountAmount,
      final String? voucherCode,
      final String? message}) = _$VoucherValidationImpl;

  factory _VoucherValidation.fromJson(Map<String, dynamic> json) =
      _$VoucherValidationImpl.fromJson;

  @override
  bool get valid;
  @override
  double? get discountAmount;
  @override
  String? get voucherCode;
  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$VoucherValidationImplCopyWith<_$VoucherValidationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VoucherValidateRequest _$VoucherValidateRequestFromJson(
    Map<String, dynamic> json) {
  return _VoucherValidateRequest.fromJson(json);
}

/// @nodoc
mixin _$VoucherValidateRequest {
  String get code => throw _privateConstructorUsedError;
  double? get fare => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VoucherValidateRequestCopyWith<VoucherValidateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoucherValidateRequestCopyWith<$Res> {
  factory $VoucherValidateRequestCopyWith(VoucherValidateRequest value,
          $Res Function(VoucherValidateRequest) then) =
      _$VoucherValidateRequestCopyWithImpl<$Res, VoucherValidateRequest>;
  @useResult
  $Res call({String code, double? fare});
}

/// @nodoc
class _$VoucherValidateRequestCopyWithImpl<$Res,
        $Val extends VoucherValidateRequest>
    implements $VoucherValidateRequestCopyWith<$Res> {
  _$VoucherValidateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? fare = freezed,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      fare: freezed == fare
          ? _value.fare
          : fare // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VoucherValidateRequestImplCopyWith<$Res>
    implements $VoucherValidateRequestCopyWith<$Res> {
  factory _$$VoucherValidateRequestImplCopyWith(
          _$VoucherValidateRequestImpl value,
          $Res Function(_$VoucherValidateRequestImpl) then) =
      __$$VoucherValidateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, double? fare});
}

/// @nodoc
class __$$VoucherValidateRequestImplCopyWithImpl<$Res>
    extends _$VoucherValidateRequestCopyWithImpl<$Res,
        _$VoucherValidateRequestImpl>
    implements _$$VoucherValidateRequestImplCopyWith<$Res> {
  __$$VoucherValidateRequestImplCopyWithImpl(
      _$VoucherValidateRequestImpl _value,
      $Res Function(_$VoucherValidateRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? fare = freezed,
  }) {
    return _then(_$VoucherValidateRequestImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      fare: freezed == fare
          ? _value.fare
          : fare // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VoucherValidateRequestImpl implements _VoucherValidateRequest {
  const _$VoucherValidateRequestImpl({required this.code, this.fare});

  factory _$VoucherValidateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoucherValidateRequestImplFromJson(json);

  @override
  final String code;
  @override
  final double? fare;

  @override
  String toString() {
    return 'VoucherValidateRequest(code: $code, fare: $fare)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoucherValidateRequestImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.fare, fare) || other.fare == fare));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, code, fare);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VoucherValidateRequestImplCopyWith<_$VoucherValidateRequestImpl>
      get copyWith => __$$VoucherValidateRequestImplCopyWithImpl<
          _$VoucherValidateRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoucherValidateRequestImplToJson(
      this,
    );
  }
}

abstract class _VoucherValidateRequest implements VoucherValidateRequest {
  const factory _VoucherValidateRequest(
      {required final String code,
      final double? fare}) = _$VoucherValidateRequestImpl;

  factory _VoucherValidateRequest.fromJson(Map<String, dynamic> json) =
      _$VoucherValidateRequestImpl.fromJson;

  @override
  String get code;
  @override
  double? get fare;
  @override
  @JsonKey(ignore: true)
  _$$VoucherValidateRequestImplCopyWith<_$VoucherValidateRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
