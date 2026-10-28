import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../dto/wallet_dto.dart';
import '../../services/wallet_service.dart';

/// WalletBloc — wallet balance and transaction history.
abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class WalletLoadRequested extends WalletEvent {
  const WalletLoadRequested();
}

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final Wallet wallet;
  final List<WalletTransaction> transactions;

  const WalletLoaded({required this.wallet, required this.transactions});

  @override
  List<Object?> get props => [wallet, transactions];
}

class WalletFailure extends WalletState {
  final String message;

  const WalletFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletService _walletService;

  WalletBloc({required WalletService walletService})
      : _walletService = walletService,
        super(WalletInitial()) {
    on<WalletLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    WalletLoadRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      final results = await Future.wait([
        _walletService.getWallet(),
        _walletService.getTransactions(),
      ]);
      emit(WalletLoaded(
        wallet: results[0] as Wallet,
        transactions: results[1] as List<WalletTransaction>,
      ));
    } catch (e) {
      emit(WalletFailure(e.toString()));
    }
  }
}
