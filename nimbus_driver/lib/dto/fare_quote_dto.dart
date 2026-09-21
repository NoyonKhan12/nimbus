import 'package:freezed_annotation/freezed_annotation.dart';

part 'fare_quote_dto.freezed.dart';
part 'fare_quote_dto.g.dart';

/// Fare quote response matching the backend contract.
@freezed
class FareQuoteDto with _$FareQuoteDto {
  const factory FareQuoteDto({
    required String quoteId,
    String? bookingId,
    required String fareRuleVersion,
    required String routeVersion,
    required int distanceMeters,
    required int durationSeconds,
    required double baseFare,
    required double distanceCharge,
    required double timeCharge,
    required double serviceFee,
    required double tax,
    required double grossFare,
    required double discount,
    required double finalPayable,
    required String currency,
    required DateTime expiresAt,
  }) = _FareQuoteDto;

  factory FareQuoteDto.fromJson(Map<String, dynamic> json) =>
      _$FareQuoteDtoFromJson(json);
}
