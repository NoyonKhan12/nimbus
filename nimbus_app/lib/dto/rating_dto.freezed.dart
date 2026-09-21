// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rating_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Rating _$RatingFromJson(Map<String, dynamic> json) {
  return _Rating.fromJson(json);
}

/// @nodoc
mixin _$Rating {
  String get id => throw _privateConstructorUsedError;
  String get rideId => throw _privateConstructorUsedError;
  String get fromUserId => throw _privateConstructorUsedError;
  String get toUserId => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RatingCopyWith<Rating> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RatingCopyWith<$Res> {
  factory $RatingCopyWith(Rating value, $Res Function(Rating) then) =
      _$RatingCopyWithImpl<$Res, Rating>;
  @useResult
  $Res call(
      {String id,
      String rideId,
      String fromUserId,
      String toUserId,
      double score,
      String? comment,
      DateTime? createdAt});
}

/// @nodoc
class _$RatingCopyWithImpl<$Res, $Val extends Rating>
    implements $RatingCopyWith<$Res> {
  _$RatingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rideId = null,
    Object? fromUserId = null,
    Object? toUserId = null,
    Object? score = null,
    Object? comment = freezed,
    Object? createdAt = freezed,
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
      fromUserId: null == fromUserId
          ? _value.fromUserId
          : fromUserId // ignore: cast_nullable_to_non_nullable
              as String,
      toUserId: null == toUserId
          ? _value.toUserId
          : toUserId // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RatingImplCopyWith<$Res> implements $RatingCopyWith<$Res> {
  factory _$$RatingImplCopyWith(
          _$RatingImpl value, $Res Function(_$RatingImpl) then) =
      __$$RatingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String rideId,
      String fromUserId,
      String toUserId,
      double score,
      String? comment,
      DateTime? createdAt});
}

/// @nodoc
class __$$RatingImplCopyWithImpl<$Res>
    extends _$RatingCopyWithImpl<$Res, _$RatingImpl>
    implements _$$RatingImplCopyWith<$Res> {
  __$$RatingImplCopyWithImpl(
      _$RatingImpl _value, $Res Function(_$RatingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rideId = null,
    Object? fromUserId = null,
    Object? toUserId = null,
    Object? score = null,
    Object? comment = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$RatingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rideId: null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
      fromUserId: null == fromUserId
          ? _value.fromUserId
          : fromUserId // ignore: cast_nullable_to_non_nullable
              as String,
      toUserId: null == toUserId
          ? _value.toUserId
          : toUserId // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RatingImpl implements _Rating {
  const _$RatingImpl(
      {required this.id,
      required this.rideId,
      required this.fromUserId,
      required this.toUserId,
      required this.score,
      this.comment,
      this.createdAt});

  factory _$RatingImpl.fromJson(Map<String, dynamic> json) =>
      _$$RatingImplFromJson(json);

  @override
  final String id;
  @override
  final String rideId;
  @override
  final String fromUserId;
  @override
  final String toUserId;
  @override
  final double score;
  @override
  final String? comment;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Rating(id: $id, rideId: $rideId, fromUserId: $fromUserId, toUserId: $toUserId, score: $score, comment: $comment, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RatingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.fromUserId, fromUserId) ||
                other.fromUserId == fromUserId) &&
            (identical(other.toUserId, toUserId) ||
                other.toUserId == toUserId) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, rideId, fromUserId, toUserId, score, comment, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RatingImplCopyWith<_$RatingImpl> get copyWith =>
      __$$RatingImplCopyWithImpl<_$RatingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RatingImplToJson(
      this,
    );
  }
}

abstract class _Rating implements Rating {
  const factory _Rating(
      {required final String id,
      required final String rideId,
      required final String fromUserId,
      required final String toUserId,
      required final double score,
      final String? comment,
      final DateTime? createdAt}) = _$RatingImpl;

  factory _Rating.fromJson(Map<String, dynamic> json) = _$RatingImpl.fromJson;

  @override
  String get id;
  @override
  String get rideId;
  @override
  String get fromUserId;
  @override
  String get toUserId;
  @override
  double get score;
  @override
  String? get comment;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$RatingImplCopyWith<_$RatingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateRatingRequest _$CreateRatingRequestFromJson(Map<String, dynamic> json) {
  return _CreateRatingRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateRatingRequest {
  String get rideId => throw _privateConstructorUsedError;
  String get toUserId => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateRatingRequestCopyWith<CreateRatingRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateRatingRequestCopyWith<$Res> {
  factory $CreateRatingRequestCopyWith(
          CreateRatingRequest value, $Res Function(CreateRatingRequest) then) =
      _$CreateRatingRequestCopyWithImpl<$Res, CreateRatingRequest>;
  @useResult
  $Res call({String rideId, String toUserId, double score, String? comment});
}

/// @nodoc
class _$CreateRatingRequestCopyWithImpl<$Res, $Val extends CreateRatingRequest>
    implements $CreateRatingRequestCopyWith<$Res> {
  _$CreateRatingRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
    Object? toUserId = null,
    Object? score = null,
    Object? comment = freezed,
  }) {
    return _then(_value.copyWith(
      rideId: null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
      toUserId: null == toUserId
          ? _value.toUserId
          : toUserId // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateRatingRequestImplCopyWith<$Res>
    implements $CreateRatingRequestCopyWith<$Res> {
  factory _$$CreateRatingRequestImplCopyWith(_$CreateRatingRequestImpl value,
          $Res Function(_$CreateRatingRequestImpl) then) =
      __$$CreateRatingRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String rideId, String toUserId, double score, String? comment});
}

/// @nodoc
class __$$CreateRatingRequestImplCopyWithImpl<$Res>
    extends _$CreateRatingRequestCopyWithImpl<$Res, _$CreateRatingRequestImpl>
    implements _$$CreateRatingRequestImplCopyWith<$Res> {
  __$$CreateRatingRequestImplCopyWithImpl(_$CreateRatingRequestImpl _value,
      $Res Function(_$CreateRatingRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
    Object? toUserId = null,
    Object? score = null,
    Object? comment = freezed,
  }) {
    return _then(_$CreateRatingRequestImpl(
      rideId: null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
      toUserId: null == toUserId
          ? _value.toUserId
          : toUserId // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateRatingRequestImpl implements _CreateRatingRequest {
  const _$CreateRatingRequestImpl(
      {required this.rideId,
      required this.toUserId,
      required this.score,
      this.comment});

  factory _$CreateRatingRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateRatingRequestImplFromJson(json);

  @override
  final String rideId;
  @override
  final String toUserId;
  @override
  final double score;
  @override
  final String? comment;

  @override
  String toString() {
    return 'CreateRatingRequest(rideId: $rideId, toUserId: $toUserId, score: $score, comment: $comment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateRatingRequestImpl &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.toUserId, toUserId) ||
                other.toUserId == toUserId) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.comment, comment) || other.comment == comment));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, rideId, toUserId, score, comment);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateRatingRequestImplCopyWith<_$CreateRatingRequestImpl> get copyWith =>
      __$$CreateRatingRequestImplCopyWithImpl<_$CreateRatingRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateRatingRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateRatingRequest implements CreateRatingRequest {
  const factory _CreateRatingRequest(
      {required final String rideId,
      required final String toUserId,
      required final double score,
      final String? comment}) = _$CreateRatingRequestImpl;

  factory _CreateRatingRequest.fromJson(Map<String, dynamic> json) =
      _$CreateRatingRequestImpl.fromJson;

  @override
  String get rideId;
  @override
  String get toUserId;
  @override
  double get score;
  @override
  String? get comment;
  @override
  @JsonKey(ignore: true)
  _$$CreateRatingRequestImplCopyWith<_$CreateRatingRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
