import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_dtos.freezed.dart';
part 'payment_dtos.g.dart';

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
  partiallyRefunded
}

enum PaymentMethod { bkash, nagad, rocket, card, cash, wallet }

@freezed
class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String bookingId,
    required double amount,
    required PaymentMethod method,
    required PaymentStatus status,
    String? providerReference,
    String? currency,
    DateTime? createdAt,
    DateTime? completedAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}

@freezed
class PaymentRequest with _$PaymentRequest {
  const factory PaymentRequest({
    required String bookingId,
    required double amount,
    required String method,
    String? returnUrl,
    required String idempotencyKey,
  }) = _PaymentRequest;

  factory PaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestFromJson(json);
}
