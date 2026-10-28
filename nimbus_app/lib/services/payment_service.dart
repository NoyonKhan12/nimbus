import '../network/backend_api.dart';
import '../network/backend_mapper.dart';

/// A payment intent as returned by the backend's `PaymentResponse`:
/// `{paymentId, bookingId, amount, method, status, providerReference,
///   clientSecret, paymentUrl, requiresRedirect, expiresAt}`.
class PaymentInit {
  final String id;
  final String bookingId;
  final double amount;
  final String method;
  final String status;
  final String? paymentUrl;
  final bool requiresRedirect;
  final DateTime? expiresAt;

  const PaymentInit({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.method,
    required this.status,
    this.paymentUrl,
    required this.requiresRedirect,
    this.expiresAt,
  });

  /// Whether the provider flow needs a browser/redirect hop.
  bool get needsRedirect => requiresRedirect && paymentUrl != null;

  factory PaymentInit.fromJson(Map<String, dynamic> json) {
    return PaymentInit(
      id: json['paymentId']?.toString() ?? json['id']?.toString() ?? '',
      bookingId: json['bookingId']?.toString() ?? '',
      amount: toDouble(json['amount']),
      method: json['method']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      paymentUrl: json['paymentUrl']?.toString(),
      requiresRedirect: json['requiresRedirect'] is bool
          ? json['requiresRedirect'] as bool
          : false,
      expiresAt: toDateOrNull(json['expiresAt']),
    );
  }
}

/// Service for payment intents and authoritative status polling.
///
/// The client never treats a local "success" flag as authoritative —
/// booking confirmation is driven by [getPayment]/booking status.
class PaymentService {
  final BackendApi _api;

  PaymentService(this._api);

  /// Creates a payment intent for a booking.
  ///
  /// [method] is one of `bkash`, `nagad`, `cash`, `wallet`.
  /// [idempotencyKey] must stay stable across retries of the same intent.
  Future<PaymentInit> createPayment({
    required String bookingId,
    required double amount,
    required String method,
    required String idempotencyKey,
    String? returnUrl,
  }) async {
    final body = await _api.post('/payments', body: {
      'bookingId': bookingId,
      'amount': amount,
      'method': method,
      'idempotencyKey': idempotencyKey,
      if (returnUrl != null) 'returnUrl': returnUrl,
    });
    return PaymentInit.fromJson(body.dataMap);
  }

  /// Polls the authoritative payment status from the backend.
  Future<PaymentInit> getPayment(String paymentId) async {
    final body = await _api.get('/payments/$paymentId');
    return PaymentInit.fromJson(body.dataMap);
  }
}
