import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../network/backend_api.dart';
import '../../network/backend_mapper.dart';
import '../../services/driver_service.dart';
import '../../services/wallet_service.dart';
import '../../widgets/state_views.dart';

/// Earnings — driver lifetime stats, wallet balance and ledger history.
///
/// Detailed settlements are reviewed by operations (admin side); the
/// driver sees their running totals and wallet ledger here.
class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  late Future<(DriverProfile, WalletInfo, List<WalletTx>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(DriverProfile, WalletInfo, List<WalletTx>)> _load() async {
    final profile = await context.read<DriverService>().getProfile();
    if (profile == null) {
      throw ApiException(
        code: 'NO_PROFILE',
        message: 'Driver profile not found — apply first.',
      );
    }
    final wallet = await context.read<WalletService>().getWallet();
    final txs = await context.read<WalletService>().getTransactions();
    return (profile, wallet, txs);
  }

  void _reload() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<(DriverProfile, WalletInfo, List<WalletTx>)>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(children: [
                SizedBox(
                  height: 500,
                  child: ErrorState(
                    message: snapshot.error.toString(),
                    onRetry: _reload,
                  ),
                ),
              ]);
            }
            final (profile, wallet, txs) = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Lifetime stats
                Row(
                  children: [
                    _stat(
                        '৳${profile.totalEarnings.toStringAsFixed(0)}',
                        'Gross earned',
                        AppTheme.success),
                    _stat('${profile.totalRides}', 'Rides',
                        AppTheme.primary),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _stat(profile.rating.toStringAsFixed(1), 'Rating',
                        AppTheme.warning),
                    _stat(
                        '${(profile.commissionRate * 100).toStringAsFixed(0)}%',
                        'Commission',
                        Colors.blueGrey),
                  ],
                ),
                const SizedBox(height: 20),

                // Wallet balance
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
                      Text('Wallet balance',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(
                        AppFormatters.money(wallet.balance,
                            currency: wallet.currency),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Ledger',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                if (txs.isEmpty)
                  const SizedBox(
                    height: 160,
                    child: EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No transactions yet',
                      subtitle: 'Fares you collect appear here.',
                    ),
                  )
                else
                  ...txs.map(_txTile),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: color)),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _txTile(WalletTx tx) {
    final isCredit = tx.amount >= 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor:
              (isCredit ? AppTheme.success : AppTheme.error).withOpacity(0.12),
          child: Icon(
            isCredit ? Icons.south_west : Icons.north_east,
            size: 20,
            color: isCredit ? AppTheme.success : AppTheme.error,
          ),
        ),
        title: Text(
          tx.description ?? statusLabel(tx.type),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${statusLabel(tx.type)} · ${AppFormatters.relativeDate(tx.createdAt)}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Text(
          '${isCredit ? '+' : '−'}${AppFormatters.amount(tx.amount.abs())}',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isCredit ? AppTheme.success : AppTheme.error),
        ),
      ),
    );
  }
}
