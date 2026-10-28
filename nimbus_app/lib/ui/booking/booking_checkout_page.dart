import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/booking/booking_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../dto/location_dto.dart';
import '../../dto/ride_booking_dtos.dart';
import '../../widgets/fare_breakdown_card.dart';
import '../../widgets/state_views.dart';
import '../ride/trip_tracking_page.dart';

/// Booking checkout — fare quote → seat hold (5-min countdown) → payment.
///
/// All state transitions come from [BookingBloc]; the page only collects
/// inputs (voucher, payment method) and renders backend truth.
class BookingCheckoutPage extends StatefulWidget {
  final Ride ride;
  final int seats;
  final LocationDto pickup;
  final LocationDto dropoff;

  const BookingCheckoutPage({
    super.key,
    required this.ride,
    required this.seats,
    required this.pickup,
    required this.dropoff,
  });

  @override
  State<BookingCheckoutPage> createState() => _BookingCheckoutPageState();
}

class _BookingCheckoutPageState extends State<BookingCheckoutPage> {
  final _voucherController = TextEditingController();
  String? _appliedVoucher;
  String _paymentMethod = 'bkash';

  @override
  void initState() {
    super.initState();
    _requestQuote();
  }

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  void _requestQuote() {
    context.read<BookingBloc>().add(BookingQuoteRequested(
          rideId: widget.ride.id,
          seats: widget.seats,
          pickupLat: widget.pickup.latitude,
          pickupLng: widget.pickup.longitude,
          dropoffLat: widget.dropoff.latitude,
          dropoffLng: widget.dropoff.longitude,
          voucherCode: _appliedVoucher,
        ));
  }

  void _applyVoucher() {
    final code = _voucherController.text.trim();
    if (code.isEmpty) return;
    setState(() => _appliedVoucher = code);
    _requestQuote();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book your seat')),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BookingQuoteLoading) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Calculating your fare…'),
                ],
              ),
            );
          }
          if (state is BookingQuoteReady) {
            return _quoteView(context, state);
          }
          if (state is BookingHoldActive) {
            return _holdView(context, state);
          }
          if (state is BookingPaymentInProgress) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Confirming payment with the provider…'),
                  SizedBox(height: 8),
                  Text(
                    'This usually takes a few seconds.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            );
          }
          if (state is BookingConfirmedState) {
            return _confirmedView(context, state);
          }
          if (state is BookingFailure) {
            return ErrorState(message: state.message, onRetry: _requestQuote);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // -------------------------------------------------------------------
  // Step 1: quote
  // -------------------------------------------------------------------

  Widget _quoteView(BuildContext context, BookingQuoteReady state) {
    final ride = widget.ride;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your journey',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 12),
                _segmentRow(
                  Icons.trip_origin,
                  AppTheme.primary,
                  widget.pickup,
                ),
                const SizedBox(height: 8),
                _segmentRow(
                  Icons.location_on,
                  AppTheme.secondary,
                  widget.dropoff,
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(Icons.event_seat, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('${widget.seats} seat(s)'),
                    const Spacer(),
                    Text(
                      AppFormatters.dateTime(ride.scheduledAt),
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Voucher
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _voucherController,
                    enabled: _appliedVoucher == null,
                    decoration: const InputDecoration(
                      hintText: 'Voucher code',
                      isDense: true,
                      prefixIcon: Icon(Icons.local_offer_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed:
                      _appliedVoucher == null ? _applyVoucher : _clearVoucher,
                  child: Text(_appliedVoucher == null ? 'Apply' : 'Remove'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FareBreakdownCard(quote: state.quote),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.warning.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined,
                  size: 20, color: AppTheme.warning),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Confirming holds your seat for '
                  '${AppConstants.seatHoldMinutes} minutes. '
                  'Complete payment within the window.',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => context.read<BookingBloc>().add(
                  BookingSubmitted(
                    rideId: widget.ride.id,
                    seats: widget.seats,
                    pickupLat: widget.pickup.latitude,
                    pickupLng: widget.pickup.longitude,
                    pickupAddress: widget.pickup.address,
                    dropoffLat: widget.dropoff.latitude,
                    dropoffLng: widget.dropoff.longitude,
                    dropoffAddress: widget.dropoff.address,
                  ),
                ),
            child: Text(
                'Hold my seat · ${AppFormatters.money(state.quote.finalPayable)}'),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // Step 2: hold + payment
  // -------------------------------------------------------------------

  Widget _holdView(BuildContext context, BookingHoldActive state) {
    return Scaffold(
      body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        HoldCountdown(expiresAt: state.holdExpiresAt),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seat held',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  'Booking #${state.booking.id.substring(0, 8)} · '
                  '${state.booking.seats} seat(s)',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FareBreakdownCard(quote: state.quote),
        const SizedBox(height: 12),
        PaymentMethodSection(
          selected: _paymentMethod,
          onChanged: (m) => setState(() => _paymentMethod = m),
        ),
      ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => context
                    .read<BookingBloc>()
                    .add(BookingPaymentStarted(_paymentMethod)),
                child: Text('Pay '
                    '${AppFormatters.money(state.quote.finalPayable)}'),
              ),
              TextButton(
                onPressed: () => _confirmCancel(context),
                child: const Text(
                  'Cancel booking',
                  style: TextStyle(color: AppTheme.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // Step 3: confirmed
  // -------------------------------------------------------------------

  Widget _confirmedView(BuildContext context, BookingConfirmedState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check,
                  color: Colors.white, size: 44),
            ),
            const SizedBox(height: 20),
            const Text(
              'Booking confirmed!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Booking #${state.booking.id.substring(0, 8)}\n'
              'Total paid: ${AppFormatters.money(state.quote.finalPayable)}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => TripTrackingPage(
                      rideId: state.booking.rideId,
                      bookingId: state.booking.id,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.radar),
              label: const Text('Track my ride'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Back to my rides'),
            ),
          ],
        ),
      ),
    );
  }

  void _clearVoucher() {
    setState(() {
      _appliedVoucher = null;
      _voucherController.clear();
    });
    _requestQuote();
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: const Text('Your held seat will be released.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep seat'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancel booking',
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<BookingBloc>().add(const BookingCancelled());
      Navigator.of(context).pop(false);
    }
  }

  Widget _segmentRow(IconData icon, Color color, dynamic location) {
    final address = location.address as String?;
    final lat = location.latitude as double;
    final lng = location.longitude as double;
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            (address != null && address.isNotEmpty)
                ? address
                : '$lat, $lng',
            style: const TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Live 5-minute hold countdown.
class HoldCountdown extends StatefulWidget {
  final DateTime expiresAt;

  const HoldCountdown({super.key, required this.expiresAt});

  @override
  State<HoldCountdown> createState() => _HoldCountdownState();
}

class _HoldCountdownState extends State<HoldCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.expiresAt.difference(DateTime.now().toUtc());
    final expired = remaining.isNegative;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: expired
            ? AppTheme.error.withOpacity(0.1)
            : AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            expired ? Icons.error_outline : Icons.timer,
            color: expired ? AppTheme.error : AppTheme.primary,
          ),
          const SizedBox(width: 10),
          Text(
            expired
                ? 'Hold expired — please rebook.'
                : 'Seat held · ${AppFormatters.countdown(remaining)} left',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: expired ? AppTheme.error : AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Payment method picker (bKash / Nagad / wallet / cash).
class PaymentMethodSection extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const PaymentMethodSection({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _methods = [
    (id: 'bkash', label: 'bKash', icon: Icons.account_balance_wallet),
    (id: 'nagad', label: 'Nagad', icon: Icons.currency_exchange),
    (id: 'wallet', label: 'Nimbus wallet', icon: Icons.account_balance),
    (id: 'cash', label: 'Cash to driver', icon: Icons.payments_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Text(
                'Payment method',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            ..._methods.map((m) => RadioListTile<String>(
                  value: m.id,
                  groupValue: selected,
                  onChanged: (v) => onChanged(v!),
                  title: Row(
                    children: [
                      Icon(m.icon, size: 20, color: AppTheme.primary),
                      const SizedBox(width: 10),
                      Text(m.label),
                    ],
                  ),
                  dense: true,
                )),
          ],
        ),
      ),
    );
  }
}
