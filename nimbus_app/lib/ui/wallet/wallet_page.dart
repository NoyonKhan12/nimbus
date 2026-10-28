import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/wallet/wallet_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../dto/wallet_dto.dart';
import '../../widgets/state_views.dart';

/// Wallet tab — balance and ledger transactions.
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(const WalletLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is WalletFailure) {
            return ErrorState(
              message: state.message,
              onRetry: () => context
                  .read<WalletBloc>()
                  .add(const WalletLoadRequested()),
            );
          }
          if (state is WalletLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<WalletBloc>()
                    .add(const WalletLoadRequested());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Balance card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryVariant],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available balance',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppFormatters.money(
                            state.wallet.balance,
                            currency: state.wallet.currency,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Transactions',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (state.transactions.isEmpty)
                    const SizedBox(
                      height: 220,
                      child: EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No transactions yet',
                      ),
                    )
                  else
                    ...state.transactions.map(_txTile),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _txTile(WalletTransaction tx) {
    final amount = tx.amount;
    final isCredit = amount >= 0;
    final type = tx.type.toUpperCase();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor:
              (isCredit ? AppTheme.success : AppTheme.error).withOpacity(0.12),
          child: Icon(
            _iconFor(type),
            size: 20,
            color: isCredit ? AppTheme.success : AppTheme.error,
          ),
        ),
        title: Text(
          tx.description ?? _labelFor(type),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${_labelFor(type)} · ${AppFormatters.relativeDate(tx.createdAt)}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Text(
          '${isCredit ? '+' : '−'}${AppFormatters.amount(amount.abs())}',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: isCredit ? AppTheme.success : AppTheme.error,
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String type) {
    if (type.contains('REFUND') || type.contains('CREDIT')) {
      return Icons.undo;
    }
    if (type.contains('RIDE') || type.contains('TRIP')) return Icons.route;
    if (type.contains('VOUCHER')) return Icons.local_offer;
    if (type.contains('TOPUP') || type.contains('DEPOSIT')) {
      return Icons.add_card;
    }
    return Icons.swap_horiz;
  }

  String _labelFor(String type) {
    return type
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0]}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}
