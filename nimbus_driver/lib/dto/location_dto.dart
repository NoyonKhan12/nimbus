/// A geographic point with an optional human-readable label.
class LocationDto {
  final double latitude;
  final double longitude;
  final String? address;

  const LocationDto({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  factory LocationDto.fromJson(Map<String, dynamic> json) => LocationDto(
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
        address: json['address']?.toString(),
      );
}
