import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_dto.freezed.dart';
part 'location_dto.g.dart';

/// Location DTO matching the backend contract.
@freezed
class LocationDto with _$LocationDto {
  const factory LocationDto({
    required double latitude,
    required double longitude,
    String? address,
  }) = _LocationDto;

  factory LocationDto.fromJson(Map<String, dynamic> json) =>
      _$LocationDtoFromJson(json);
}
