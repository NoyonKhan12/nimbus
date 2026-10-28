import '../network/backend_api.dart';
import '../network/backend_mapper.dart';

/// Driver wallet — balance and ledger transactions (earnings, settlements).
class WalletService {
  final BackendApi _api;

  WalletService(this._api);

  Future<WalletInfo> getWallet() async {
    final body = await _api.get('/wallet');
    return WalletInfo.fromJson(body.dataMap);
  }

  Future<List<WalletTx>> getTransactions({int page = 0, int size = 20}) async {
    final body = await _api.get(
      '/wallet/transactions',
      query: {'page': page, 'size': size},
    );
    return body.dataList
        .whereType<Map<String, dynamic>>()
        .map(WalletTx.fromJson)
        .toList();
  }
}
