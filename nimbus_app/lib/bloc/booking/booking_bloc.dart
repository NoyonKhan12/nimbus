import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../dto/fare_quote_dto.dart';
import '../../dto/ride_booking_dtos.dart';
import '../../network/backend_api.dart';
import '../../services/booking_service.dart';
import '../../services/payment_service.dart';

/// BookingBloc — the passenger booking pipeline:
/// quote → seat hold (HELD, 5 minutes) → payment → CONFIRMED.
///
/// The backend is authoritative: seats, fares and state transitions are
/// only ever confirmed by server responses.
abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

/// Requests a fare quote for [seats] seats, optionally with a voucher.
class BookingQuoteRequested extends BookingEvent {
  final String rideId;
  final int seats;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final String? voucherCode;

  const BookingQuoteRequested({
    required this.rideId,
    required this.seats,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    this.voucherCode,
  });

  @override
  List<Object?> get props =>
      [rideId, seats, pickupLat, pickupLng, dropoffLat, dropoffLng, voucherCode];
}

/// Converts the current quote into a booking (transactional seat hold).
class BookingSubmitted extends BookingEvent {
  final String rideId;
  final int seats;
  final double pickupLat;
  final double pickupLng;
  final String? pickupAddress;
  final double dropoffLat;
  final double dropoffLng;
  final String? dropoffAddress;

  const BookingSubmitted({
    required this.rideId,
    required this.seats,
    required this.pickupLat,
    required this.pickupLng,
    this.pickupAddress,
    required this.dropoffLat,
    required this.dropoffLng,
    this.dropoffAddress,
  });

  @override
  List<Object?> get props => [
        rideId, seats, pickupLat, pickupLng, pickupAddress,
        dropoffLat, dropoffLng, dropoffAddress,
      ];
}

/// Initiates payment for the held booking with the chosen method.
class BookingPaymentStarted extends BookingEvent {
  final String method; // bkash | nagad | cash | wallet

  const BookingPaymentStarted(this.method);

  @override
  List<Object?> get props => [method];
}

/// Re-polls booking/payment state (used by the hold countdown UI).
class BookingRefreshed extends BookingEvent {
  const BookingRefreshed();
}

/// Cancels the held/confirmed booking.
class BookingCancelled extends BookingEvent {
  final String reason;

  const BookingCancelled([this.reason = 'Cancelled by passenger']);

  @override
  List<Object?> get props => [reason];
}

/// Resets the bloc for a new flow.
class BookingReset extends BookingEvent {
  const BookingReset();
}

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingQuoteLoading extends BookingState {
  final String rideId;

  const BookingQuoteLoading(this.rideId);

  @override
  List<Object?> get props => [rideId];
}

class BookingQuoteReady extends BookingState {
  final String rideId;
  final int seats;
  final FareQuoteDto quote;

  const BookingQuoteReady({
    required this.rideId,
    required this.seats,
    required this.quote,
  });

  @override
  List<Object?> get props => [rideId, seats, quote];
}

/// Seat successfully held. [holdExpiresAt] drives the 5-minute countdown.
class BookingHoldActive extends BookingState {
  final Booking booking;
  final FareQuoteDto quote;
  final DateTime holdExpiresAt;

  const BookingHoldActive({
    required this.booking,
    required this.quote,
    required this.holdExpiresAt,
  });

  @override
  List<Object?> get props => [booking, quote, holdExpiresAt];
}

class BookingPaymentInProgress extends BookingState {
  final Booking booking;
  final FareQuoteDto quote;
  final PaymentInit payment;
  final String method;

  const BookingPaymentInProgress({
    required this.booking,
    required this.quote,
    required this.payment,
    required this.method,
  });

  @override
  List<Object?> get props => [booking, quote, payment, method];
}

class BookingConfirmedState extends BookingState {
  final Booking booking;
  final FareQuoteDto quote;

  const BookingConfirmedState({required this.booking, required this.quote});

  @override
  List<Object?> get props => [booking, quote];
}

class BookingCancelledState extends BookingState {
  final String message;

  const BookingCancelledState(this.message);

  @override
  List<Object?> get props => [message];
}

class BookingFailure extends BookingState {
  final String message;

  const BookingFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingService _bookingService;
  final PaymentService _paymentService;

  static const _pollInterval = Duration(seconds: 2);
  static const _pollTimeout = Duration(seconds: 30);

  String? _idempotencyKey;
  PaymentInit? _lastPayment;

  BookingBloc({
    required BookingService bookingService,
    required PaymentService paymentService,
  })  : _bookingService = bookingService,
        _paymentService = paymentService,
        super(BookingInitial()) {
    on<BookingQuoteRequested>(_onQuote);
    on<BookingSubmitted>(_onSubmit);
    on<BookingPaymentStarted>(_onPayment);
    on<BookingRefreshed>(_onRefresh);
    on<BookingCancelled>(_onCancel);
    on<BookingReset>(_onReset);
  }

  Future<void> _onQuote(
    BookingQuoteRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingQuoteLoading(event.rideId));
    try {
      final quote = await _bookingService.getFareQuote(
        rideId: event.rideId,
        seats: event.seats,
        pickupLat: event.pickupLat,
        pickupLng: event.pickupLng,
        dropoffLat: event.dropoffLat,
        dropoffLng: event.dropoffLng,
        voucherCode: event.voucherCode,
      );
      emit(BookingQuoteReady(
        rideId: event.rideId,
        seats: event.seats,
        quote: quote,
      ));
    } catch (e) {
      emit(BookingFailure(_message(e)));
    }
  }

  Future<void> _onSubmit(
    BookingSubmitted event,
    Emitter<BookingState> emit,
  ) async {
    final current = state;
    final quote = current is BookingQuoteReady ? current.quote : null;
    if (quote == null) {
      emit(const BookingFailure('Request a fare quote first.'));
      return;
    }
    try {
      final booking = await _bookingService.createBooking(
        rideId: event.rideId,
        seats: event.seats,
        pickupLat: event.pickupLat,
        pickupLng: event.pickupLng,
        pickupAddress: event.pickupAddress,
        dropoffLat: event.dropoffLat,
        dropoffLng: event.dropoffLng,
        dropoffAddress: event.dropoffAddress,
        fareQuoteId: quote.quoteId,
      );
      // Seat hold duration: 5 minutes per the platform contract; prefer the
      // quote expiry when the server already applied one.
      final expires = quote.expiresAt.isAfter(DateTime.now().toUtc())
          ? quote.expiresAt
          : DateTime.now().toUtc().add(const Duration(minutes: 5));
      emit(BookingHoldActive(
        booking: booking,
        quote: quote,
        holdExpiresAt: expires,
      ));
    } catch (e) {
      emit(BookingFailure(_message(e)));
    }
  }

  Future<void> _onPayment(
    BookingPaymentStarted event,
    Emitter<BookingState> emit,
  ) async {
    final hold = state is BookingHoldActive
        ? state as BookingHoldActive
        : null;
    if (hold == null) {
      emit(const BookingFailure('No active booking to pay for.'));
      return;
    }
    // Fresh key per intent; stable across polls/retries of THIS intent.
    _idempotencyKey ??= _bookingService.newIdempotencyKey();
    try {
      var payment = await _paymentService.createPayment(
        bookingId: hold.booking.id,
        amount: hold.quote.finalPayable,
        method: event.method,
        idempotencyKey: _idempotencyKey!,
      );
      _lastPayment = payment;
      emit(BookingPaymentInProgress(
        booking: hold.booking,
        quote: hold.quote,
        payment: payment,
        method: event.method,
      ));

      // Poll authoritative status; never trust client-side success.
      payment = await _pollPayment(payment.id);
      _lastPayment = payment;

      if (_isTerminalSuccess(payment.status)) {
        final booking = await _ensureConfirmed(hold.booking.id);
        emit(BookingConfirmedState(booking: booking, quote: hold.quote));
      } else {
        emit(BookingFailure('Payment not completed (${payment.status}).'));
      }
    } catch (e) {
      emit(BookingFailure(_message(e)));
    }
  }

  Future<void> _onRefresh(
    BookingRefreshed event,
    Emitter<BookingState> emit,
  ) async {
    final current = state;
    if (current is BookingHoldActive) {
      try {
        final booking = await _bookingService.getBooking(current.booking.id);
        emit(booking.status == BookingStatus.confirmed
            ? BookingConfirmedState(
                booking: booking, quote: current.quote)
            : BookingHoldActive(
                booking: booking,
                quote: current.quote,
                holdExpiresAt: current.holdExpiresAt,
              ));
      } catch (_) {
        // Keep the last known state on transient failures.
      }
    }
  }

  Future<void> _onCancel(
    BookingCancelled event,
    Emitter<BookingState> emit,
  ) async {
    final current = state;
    final bookingId = current is BookingHoldActive
        ? current.booking.id
        : current is BookingPaymentInProgress
            ? current.booking.id
            : current is BookingConfirmedState
                ? current.booking.id
                : null;
    if (bookingId == null) return;
    try {
      await _bookingService.cancelBooking(bookingId);
      emit(BookingCancelledState(event.reason));
    } catch (e) {
      emit(BookingFailure(_message(e)));
    }
  }

  void _onReset(
    BookingReset event,
    Emitter<BookingState> emit,
  ) {
    _idempotencyKey = null;
    _lastPayment = null;
    emit(BookingInitial());
  }

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  Future<PaymentInit> _pollPayment(String paymentId) async {
    final deadline = DateTime.now().add(_pollTimeout);
    var latest = _lastPayment!;
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(_pollInterval);
      try {
        latest = await _paymentService.getPayment(paymentId);
      } catch (e) {
        if (kDebugMode) debugPrint('BookingBloc: poll error: $e');
        continue; // Graceful degradation — retry until the deadline.
      }
      final status = latest.status.toUpperCase();
      if (_isTerminalSuccess(status) || _isTerminalFailure(status)) {
        return latest;
      }
    }
    return latest;
  }

  /// Ensures the booking reflects CONFIRMED server-side (covers the cash
  /// flow where the driver collects fare and the hold must be converted).
  Future<Booking> _ensureConfirmed(String bookingId) async {
    var booking = await _bookingService.getBooking(bookingId);
    if (booking.status == BookingStatus.held) {
      booking = await _bookingService.confirmBooking(bookingId);
    }
    return booking;
  }

  bool _isTerminalSuccess(String status) {
    const successStates = {'COMPLETED', 'SUCCESS', 'SUCCESSFUL', 'CONFIRMED'};
    return successStates.contains(status.toUpperCase());
  }

  bool _isTerminalFailure(String status) {
    const failureStates = {'FAILED', 'CANCELLED', 'EXPIRED', 'REJECTED'};
    return failureStates.contains(status.toUpperCase());
  }

  String _message(Object e) {
    if (e is ApiException) return e.message;
    return e.toString();
  }
}
