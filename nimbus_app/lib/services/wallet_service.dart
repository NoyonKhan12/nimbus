import '../dto/voucher_dto.dart';
import '../dto/wallet_dto.dart';
import '../network/backend_api.dart';
import '../network/backend_mapper.dart';

/// Service for the user wallet and voucher validation.
class WalletService {
  final BackendApi _api;

  WalletService(this._api);

  /// Fetches the wallet balance for the current user.
  Future<Wallet> getWallet() async {
    final body = await _api.get('/wallet');
    return walletFromJson(body.dataMap);
  }

  /// Fetches the wallet transaction ledger, newest first.
  Future<List<WalletTransaction>> getTransactions({
    int page = 0,
    int size = 20,
  }) async {
    final body = await _api.get(
      '/wallet/transactions',
      query: {'page': page, 'size': size},
    );
    // Paged endpoints keep the list under `data` (with optional `meta`).
    return body.dataList
        .whereType<Map<String, dynamic>>()
        .map(walletTransactionFromJson)
        .toList();
  }

  /// Validates a voucher code against an optional fare amount.
  Future<VoucherValidation> validateVoucher(String code, {double? fare}) async {
    final body = await _api.post('/vouchers/validate', body: {
      'code': code,
      if (fare != null) 'fare': fare,
    });
    final data = body.dataMap;
    return VoucherValidation(
      valid: data['valid'] is bool ? data['valid'] as bool : false,
      discountAmount: data['discountAmount'] == null
          ? null
          : toDouble(data['discountAmount']),
      voucherCode: data['voucherCode']?.toString() ?? code,
      message: data['message']?.toString(),
    );
  }
}
