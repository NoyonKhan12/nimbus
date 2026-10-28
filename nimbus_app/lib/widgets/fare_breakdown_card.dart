import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../dto/fare_quote_dto.dart';

/// Line-by-line fare breakdown for a quote:
/// base + distance + time + service fee + tax − discount = final payable.
class FareBreakdownCard extends StatelessWidget {
  final FareQuoteDto quote;

  const FareBreakdownCard({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Fare breakdown',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const Spacer(),
                Text(
                  'ID ${quote.quoteId.substring(0, 8)}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
            const Divider(height: 24),
            _row('Base fare', quote.baseFare),
            _row(
                'Distance (${AppFormatters.distance(quote.distanceMeters)})',
                quote.distanceCharge),
            _row(
                'Time (${AppFormatters.duration(quote.durationSeconds)})',
                quote.timeCharge),
            _row('Service fee', quote.serviceFee),
            _row('Tax / VAT', quote.tax),
            if (quote.discount > 0)
              _row('Discount', -quote.discount, highlight: AppTheme.success),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total payable',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                Text(
                  AppFormatters.money(quote.finalPayable,
                      currency: quote.currency),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Quote expires ${AppFormatters.time(quote.expiresAt)} '
              '· rule v${quote.fareRuleVersion}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, double amount, {Color? highlight}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
          Text(
            AppFormatters.money(amount),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: highlight ?? (amount < 0 ? AppTheme.success : null),
            ),
          ),
        ],
      ),
    );
  }
}
