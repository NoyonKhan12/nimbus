import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_dto.freezed.dart';
part 'payment_dto.g.dart';

@freezed
class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String bookingId,
    required double amount,
    required String currency,
    required String status,
    String? paymentMethod,
    String? transactionId,
    DateTime? processedAt,
    DateTime? createdAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}
