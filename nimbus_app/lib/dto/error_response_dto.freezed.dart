// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'error_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) {
  return _ErrorResponse.fromJson(json);
}

/// @nodoc
mixin _$ErrorResponse {
  DateTime get timestamp => throw _privateConstructorUsedError;
  int get status => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String? get path => throw _privateConstructorUsedError;
  String? get traceId => throw _privateConstructorUsedError;
  List<FieldError>? get fieldErrors => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ErrorResponseCopyWith<ErrorResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ErrorResponseCopyWith<$Res> {
  factory $ErrorResponseCopyWith(
          ErrorResponse value, $Res Function(ErrorResponse) then) =
      _$ErrorResponseCopyWithImpl<$Res, ErrorResponse>;
  @useResult
  $Res call(
      {DateTime timestamp,
      int status,
      String code,
      String message,
      String? path,
      String? traceId,
      List<FieldError>? fieldErrors});
}

/// @nodoc
class _$ErrorResponseCopyWithImpl<$Res, $Val extends ErrorResponse>
    implements $ErrorResponseCopyWith<$Res> {
  _$ErrorResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? status = null,
    Object? code = null,
    Object? message = null,
    Object? path = freezed,
    Object? traceId = freezed,
    Object? fieldErrors = freezed,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      path: freezed == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String?,
      traceId: freezed == traceId
          ? _value.traceId
          : traceId // ignore: cast_nullable_to_non_nullable
              as String?,
      fieldErrors: freezed == fieldErrors
          ? _value.fieldErrors
          : fieldErrors // ignore: cast_nullable_to_non_nullable
              as List<FieldError>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ErrorResponseImplCopyWith<$Res>
    implements $ErrorResponseCopyWith<$Res> {
  factory _$$ErrorResponseImplCopyWith(
          _$ErrorResponseImpl value, $Res Function(_$ErrorResponseImpl) then) =
      __$$ErrorResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime timestamp,
      int status,
      String code,
      String message,
      String? path,
      String? traceId,
      List<FieldError>? fieldErrors});
}

/// @nodoc
class __$$ErrorResponseImplCopyWithImpl<$Res>
    extends _$ErrorResponseCopyWithImpl<$Res, _$ErrorResponseImpl>
    implements _$$ErrorResponseImplCopyWith<$Res> {
  __$$ErrorResponseImplCopyWithImpl(
      _$ErrorResponseImpl _value, $Res Function(_$ErrorResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? status = null,
    Object? code = null,
    Object? message = null,
    Object? path = freezed,
    Object? traceId = freezed,
    Object? fieldErrors = freezed,
  }) {
    return _then(_$ErrorResponseImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      path: freezed == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String?,
      traceId: freezed == traceId
          ? _value.traceId
          : traceId // ignore: cast_nullable_to_non_nullable
              as String?,
      fieldErrors: freezed == fieldErrors
          ? _value._fieldErrors
          : fieldErrors // ignore: cast_nullable_to_non_nullable
              as List<FieldError>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ErrorResponseImpl implements _ErrorResponse {
  const _$ErrorResponseImpl(
      {required this.timestamp,
      required this.status,
      required this.code,
      required this.message,
      this.path,
      this.traceId,
      final List<FieldError>? fieldErrors})
      : _fieldErrors = fieldErrors;

  factory _$ErrorResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ErrorResponseImplFromJson(json);

  @override
  final DateTime timestamp;
  @override
  final int status;
  @override
  final String code;
  @override
  final String message;
  @override
  final String? path;
  @override
  final String? traceId;
  final List<FieldError>? _fieldErrors;
  @override
  List<FieldError>? get fieldErrors {
    final value = _fieldErrors;
    if (value == null) return null;
    if (_fieldErrors is EqualUnmodifiableListView) return _fieldErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ErrorResponse(timestamp: $timestamp, status: $status, code: $code, message: $message, path: $path, traceId: $traceId, fieldErrors: $fieldErrors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorResponseImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.traceId, traceId) || other.traceId == traceId) &&
            const DeepCollectionEquality()
                .equals(other._fieldErrors, _fieldErrors));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, timestamp, status, code, message,
      path, traceId, const DeepCollectionEquality().hash(_fieldErrors));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorResponseImplCopyWith<_$ErrorResponseImpl> get copyWith =>
      __$$ErrorResponseImplCopyWithImpl<_$ErrorResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ErrorResponseImplToJson(
      this,
    );
  }
}

abstract class _ErrorResponse implements ErrorResponse {
  const factory _ErrorResponse(
      {required final DateTime timestamp,
      required final int status,
      required final String code,
      required final String message,
      final String? path,
      final String? traceId,
      final List<FieldError>? fieldErrors}) = _$ErrorResponseImpl;

  factory _ErrorResponse.fromJson(Map<String, dynamic> json) =
      _$ErrorResponseImpl.fromJson;

  @override
  DateTime get timestamp;
  @override
  int get status;
  @override
  String get code;
  @override
  String get message;
  @override
  String? get path;
  @override
  String? get traceId;
  @override
  List<FieldError>? get fieldErrors;
  @override
  @JsonKey(ignore: true)
  _$$ErrorResponseImplCopyWith<_$ErrorResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FieldError _$FieldErrorFromJson(Map<String, dynamic> json) {
  return _FieldError.fromJson(json);
}

/// @nodoc
mixin _$FieldError {
  String get field => throw _privateConstructorUsedError;
  String get rejectedValue => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FieldErrorCopyWith<FieldError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FieldErrorCopyWith<$Res> {
  factory $FieldErrorCopyWith(
          FieldError value, $Res Function(FieldError) then) =
      _$FieldErrorCopyWithImpl<$Res, FieldError>;
  @useResult
  $Res call({String field, String rejectedValue, String message});
}

/// @nodoc
class _$FieldErrorCopyWithImpl<$Res, $Val extends FieldError>
    implements $FieldErrorCopyWith<$Res> {
  _$FieldErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field = null,
    Object? rejectedValue = null,
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      field: null == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String,
      rejectedValue: null == rejectedValue
          ? _value.rejectedValue
          : rejectedValue // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FieldErrorImplCopyWith<$Res>
    implements $FieldErrorCopyWith<$Res> {
  factory _$$FieldErrorImplCopyWith(
          _$FieldErrorImpl value, $Res Function(_$FieldErrorImpl) then) =
      __$$FieldErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String field, String rejectedValue, String message});
}

/// @nodoc
class __$$FieldErrorImplCopyWithImpl<$Res>
    extends _$FieldErrorCopyWithImpl<$Res, _$FieldErrorImpl>
    implements _$$FieldErrorImplCopyWith<$Res> {
  __$$FieldErrorImplCopyWithImpl(
      _$FieldErrorImpl _value, $Res Function(_$FieldErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field = null,
    Object? rejectedValue = null,
    Object? message = null,
  }) {
    return _then(_$FieldErrorImpl(
      field: null == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String,
      rejectedValue: null == rejectedValue
          ? _value.rejectedValue
          : rejectedValue // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FieldErrorImpl implements _FieldError {
  const _$FieldErrorImpl(
      {required this.field,
      required this.rejectedValue,
      required this.message});

  factory _$FieldErrorImpl.fromJson(Map<String, dynamic> json) =>
      _$$FieldErrorImplFromJson(json);

  @override
  final String field;
  @override
  final String rejectedValue;
  @override
  final String message;

  @override
  String toString() {
    return 'FieldError(field: $field, rejectedValue: $rejectedValue, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FieldErrorImpl &&
            (identical(other.field, field) || other.field == field) &&
            (identical(other.rejectedValue, rejectedValue) ||
                other.rejectedValue == rejectedValue) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, field, rejectedValue, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FieldErrorImplCopyWith<_$FieldErrorImpl> get copyWith =>
      __$$FieldErrorImplCopyWithImpl<_$FieldErrorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FieldErrorImplToJson(
      this,
    );
  }
}

abstract class _FieldError implements FieldError {
  const factory _FieldError(
      {required final String field,
      required final String rejectedValue,
      required final String message}) = _$FieldErrorImpl;

  factory _FieldError.fromJson(Map<String, dynamic> json) =
      _$FieldErrorImpl.fromJson;

  @override
  String get field;
  @override
  String get rejectedValue;
  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$FieldErrorImplCopyWith<_$FieldErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
