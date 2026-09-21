// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RatingImpl _$$RatingImplFromJson(Map<String, dynamic> json) => _$RatingImpl(
      id: json['id'] as String,
      rideId: json['rideId'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      score: (json['score'] as num).toDouble(),
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$RatingImplToJson(_$RatingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rideId': instance.rideId,
      'fromUserId': instance.fromUserId,
      'toUserId': instance.toUserId,
      'score': instance.score,
      'comment': instance.comment,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$CreateRatingRequestImpl _$$CreateRatingRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateRatingRequestImpl(
      rideId: json['rideId'] as String,
      toUserId: json['toUserId'] as String,
      score: (json['score'] as num).toDouble(),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$$CreateRatingRequestImplToJson(
        _$CreateRatingRequestImpl instance) =>
    <String, dynamic>{
      'rideId': instance.rideId,
      'toUserId': instance.toUserId,
      'score': instance.score,
      'comment': instance.comment,
    };
