import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_dto.freezed.dart';
part 'wallet_dto.g.dart';

@freezed
class Wallet with _$Wallet {
  const factory Wallet({
    required String id,
    required String userId,
    required double balance,
    String? currency,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) = _Wallet;

  factory Wallet.fromJson(Map<String, dynamic> json) =>
      _$WalletFromJson(json);
}

@freezed
class WalletTransaction with _$WalletTransaction {
  const factory WalletTransaction({
    required String id,
    required String walletId,
    required double amount,
    required String type,
    required String status,
    String? referenceId,
    String? description,
    double? balanceBefore,
    double? balanceAfter,
    DateTime? createdAt,
  }) = _WalletTransaction;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionFromJson(json);
}
