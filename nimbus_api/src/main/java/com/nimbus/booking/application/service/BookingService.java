package com.nimbus.booking.application.service;

import com.nimbus.booking.application.BookingResponse;
import com.nimbus.booking.application.CreateBookingRequest;
import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.booking.domain.repository.BookingRepository;
import com.nimbus.fare.domain.entity.FareQuote;
import com.nimbus.fare.domain.repository.FareQuoteRepository;
import com.nimbus.payment.domain.entity.Payment;
import com.nimbus.payment.domain.repository.PaymentRepository;
import com.nimbus.wallet.application.service.LedgerService;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.kernel.domain.entity.User;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.kernel.domain.repository.UserRepository;
import com.nimbus.ride.domain.entity.Ride;
import com.nimbus.ride.domain.repository.RideRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Booking management service handling seat holds, booking lifecycle,
 * and transactional seat allocation.
 *
 * <p>Seat allocation uses database row locking (pessimistic write lock)
 * to prevent overbooking under concurrent reservation. Seat holds last
 * 5 minutes and are tracked via Redis TTL in production.</p>
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class BookingService {

    private final BookingRepository bookingRepository;
    private final RideRepository rideRepository;
    private final UserRepository userRepository;
    private final FareQuoteRepository fareQuoteRepository;
    private final PaymentRepository paymentRepository;
    private final LedgerService ledgerService;
    private final SimpMessagingTemplate messagingTemplate;
    private final com.nimbus.matching.application.MatchingService matchingService;
    private final com.nimbus.voucher.application.service.VoucherService voucherService;
    private final com.nimbus.booking.infrastructure.SeatHoldStore seatHoldStore;
    private final com.nimbus.routing.application.RouteService routeService;
    private final com.nimbus.notification.application.service.NotificationService notificationService;

    /**
     * Create a booking with seat hold.
     * Seat holds last 5 minutes.
     */
    @Transactional
    public BookingResponse createBooking(UUID userId, CreateBookingRequest request) {
        if (request.getRideId() == null) {
            throw new NimbusException(ErrorCode.VALIDATION_ERROR,
                    "Ride ID is required", HttpStatus.BAD_REQUEST);
        }
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.USER_NOT_FOUND, HttpStatus.NOT_FOUND));

        // Lock the ride row (PESSIMISTIC_WRITE) so concurrent bookings for
        // the same ride serialize here and cannot overbook (guide §5/§7).
        Ride ride = rideRepository.findByIdForUpdate(request.getRideId())
                .orElseThrow(() -> new NimbusException(ErrorCode.RIDE_NOT_FOUND, HttpStatus.NOT_FOUND));

        // Validate booking window
        if (ride.getStatus() != Ride.RideStatus.PUBLISHED &&
                ride.getStatus() != Ride.RideStatus.ROUTE_LOCKED) {
            throw new NimbusException(ErrorCode.RIDE_NOT_BOOKABLE, HttpStatus.BAD_REQUEST);
        }

        // Validate available seats using database-level count (locked transaction)
        int allocatedSeats = bookingRepository.sumActiveSeatsByRideId(ride.getId());
        if (ride.getAvailableSeats() - allocatedSeats < request.getSeats()) {
            throw new NimbusException(ErrorCode.RIDE_NO_SEATS, HttpStatus.CONFLICT);
        }

        // Parse pickup/dropoff coordinates
        Double[] pickup = request.getPickupLocation();
        Double[] dropoff = request.getDropoffLocation();

        // Revalidate hard constraints inside this transaction (guide §9
        // step 7): corridor fit for both ends, pickup-before-dropoff.
        if (pickup != null && dropoff != null
                && pickup.length >= 2 && dropoff.length >= 2) {
            matchingService.revalidateBookingFit(ride,
                    pickup[0], pickup[1], dropoff[0], dropoff[1], request.getSeats());
        }

        // A booking must consume a live quote that was issued to this
        // passenger for this ride (guide §5/§11). Lock the quote row so the
        // same quote cannot be used by two concurrent bookings.
        if (request.getFareQuoteId() == null || request.getFareQuoteId().isBlank()) {
            throw new NimbusException(ErrorCode.VALIDATION_ERROR,
                    "Fare quote is required", HttpStatus.BAD_REQUEST);
        }
        UUID fareQuoteId;
        try {
            fareQuoteId = UUID.fromString(request.getFareQuoteId());
        } catch (IllegalArgumentException e) {
            throw new NimbusException(ErrorCode.VALIDATION_ERROR,
                    "Invalid fare quote id", HttpStatus.BAD_REQUEST);
        }
        FareQuote quote = fareQuoteRepository.findByIdForUpdate(fareQuoteId)
                .orElseThrow(() -> new NimbusException(ErrorCode.FARE_QUOTE_EXPIRED,
                        "Fare quote not found", HttpStatus.BAD_REQUEST));
        if (quote.getBookingId() != null) {
            throw new NimbusException(ErrorCode.FARE_QUOTE_EXPIRED,
                    "Fare quote has already been used", HttpStatus.CONFLICT);
        }
        if (!quote.isValid()) {
            throw new NimbusException(ErrorCode.FARE_QUOTE_EXPIRED,
                    "Fare quote has expired — request a new quote", HttpStatus.BAD_REQUEST);
        }
        if (quote.getRideId() == null || !quote.getRideId().equals(ride.getId())) {
            throw new NimbusException(ErrorCode.FARE_QUOTE_EXPIRED,
                    "Fare quote does not belong to this ride", HttpStatus.BAD_REQUEST);
        }
        if (quote.getUserId() == null || !quote.getUserId().equals(userId)) {
            throw new NimbusException(ErrorCode.FARE_QUOTE_EXPIRED,
                    "Fare quote does not belong to this passenger", HttpStatus.BAD_REQUEST);
        }
        if (quote.getRouteVersion() == null
                || !quote.getRouteVersion().equals(ride.getRouteVersion())) {
            throw new NimbusException(ErrorCode.FARE_QUOTE_EXPIRED,
                    "Fare quote is stale — request a new quote", HttpStatus.CONFLICT);
        }
        validateQuoteSegment(quote, pickup, dropoff);

        Booking.BookingBuilder bookingBuilder = Booking.builder()
                .ride(ride)
                .passenger(user)
                .seats(request.getSeats())
                .status(Booking.BookingStatus.HELD)
                .pickupAddress(request.getPickupAddress())
                .dropoffAddress(request.getDropoffAddress())
                .fareQuoteId(quote.getId())
                .createdAt(Instant.now())
                .updatedAt(Instant.now());

        Booking booking = bookingBuilder.build();

        // Store coordinates as WKT. The request carries [longitude, latitude]
        // (GeoJSON order) and WKT POINT is POINT(lng lat) — same order.
        if (pickup != null && pickup.length >= 2) {
            booking.setPickupLocation(String.format("POINT(%s %s)", pickup[0], pickup[1]));
        }
        if (dropoff != null && dropoff.length >= 2) {
            booking.setDropoffLocation(String.format("POINT(%s %s)", dropoff[0], dropoff[1]));
        }

        // Carry the quoted fare onto the booking (guide §5: every booking
        // stores its passenger-specific fare for reproducible settlement).
        booking.setFinalPayable(quote.getFinalPayable());
        booking.setPlannedDistanceMeters(quote.getDistanceMeters());
        booking.setPlannedDurationSeconds(quote.getDurationSeconds());

        Booking saved = bookingRepository.save(booking);

        // Consume the quote: it can now only be redeemed by this booking.
        quote.setBookingId(saved.getId());
        fareQuoteRepository.save(quote);

        seatHoldStore.hold(ride.getId(), saved.getId(), Duration.ofSeconds(300));
        broadcastSeatAvailability(ride);
        return toBookingResponse(saved);
    }

    /** Pushes remaining-seat count to the ride topic (guide §17). */
    private void broadcastSeatAvailability(Ride ride) {
        try {
            messagingTemplate.convertAndSend("/topic/ride/" + ride.getId(),
                    java.util.Map.of(
                            "event", "SEAT_AVAILABILITY_CHANGED",
                            "rideId", ride.getId().toString(),
                            "data", java.util.Map.of("availableSeats", ride.getAvailableSeats()),
                            "timestamp", Instant.now().toString()));
        } catch (Exception e) {
            log.warn("Failed to broadcast seat availability: {}", e.getMessage());
        }
    }

    /**
     * Confirm a booking (transition from HELD to CONFIRMED).
     * Called after payment succeeds.
     */
    @Transactional
    public BookingResponse confirmBooking(UUID bookingId, UUID userId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new NimbusException(ErrorCode.BOOKING_NOT_FOUND, HttpStatus.NOT_FOUND));

        // Only the passenger can confirm their own booking
        if (!booking.getPassenger().getId().equals(userId)) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        // Confirmation is idempotent: payment now confirms the booking
        // server-side, and the client still calls this endpoint. A repeated
        // call must return the confirmed booking rather than fail.
        if (booking.getStatus() == Booking.BookingStatus.CONFIRMED) {
            return toBookingResponse(booking);
        }
        if (booking.getStatus() != Booking.BookingStatus.HELD) {
            throw new NimbusException(ErrorCode.BOOKING_EXPIRED,
                    "Booking must be HELD to confirm", HttpStatus.CONFLICT);
        }

        // Payment confirms the seat (guide §5/§12): a HELD booking can only
        // be confirmed once a SUCCESS payment exists — the client can never
        // mint a confirmed seat without paying (payment success also
        // auto-confirms server-side; this guards the manual path).
        boolean paid = paymentRepository
                .findFirstByBookingIdAndStatusOrderByCreatedAtDesc(
                        bookingId, Payment.PaymentStatus.SUCCESS)
                .isPresent();
        if (!paid) {
            throw new NimbusException(ErrorCode.PAYMENT_FAILED,
                    "Complete payment before confirming the booking",
                    org.springframework.http.HttpStatus.PAYMENT_REQUIRED);
        }

        // Server-side fare linkage (guide §5/§11): the quote must be
        // reproducible from stored versions and endpoint-served, never from
        // today's rates. If the client booked without carrying a quoteId,
        // bind the persisted quote created for this booking so the
        // booking's payable/distance are authoritative for settlement.
        if (booking.getFareQuoteId() == null) {
            fareQuoteRepository.findByBookingId(booking.getId())
                    .filter(com.nimbus.fare.domain.entity.FareQuote::isValid)
                    .ifPresent(q -> {
                        booking.setFareQuoteId(q.getId());
                        booking.setFinalPayable(q.getFinalPayable());
                        booking.setPlannedDistanceMeters(q.getDistanceMeters());
                        booking.setPlannedDurationSeconds(q.getDurationSeconds());
                        bookingRepository.save(booking);
                    });
        }

        // The voucher (if the pricing quote used one) is redeemed now that
        // the seat is actually committed — idempotent per booking.
        if (booking.getFareQuoteId() != null) {
            fareQuoteRepository.findById(booking.getFareQuoteId())
                    .filter(q -> q.getDiscount() != null && q.getDiscount().signum() > 0
                            && q.getVoucherCode() != null)
                    .ifPresent(q -> voucherService.recordRedemption(userId, q.getVoucherCode(),
                            q.getGrossFare(), q.getDiscount(), booking.getId()));
        }

        var oldStatus = booking.getStatus();
        booking.transitionTo(Booking.BookingStatus.CONFIRMED);
        bookingRepository.save(booking);
        seatHoldStore.release(booking.getRide().getId(), booking.getId());

        // Route insertion (guide §10): the confirmed pickup/drop-off pair
        // is inserted into the ride's stop sequence and a new route
        // version is persisted — same transaction as the confirmation.
        try {
            routeService.insertBookingIntoRoute(booking.getRide().getId(), booking.getId());
        } catch (Exception e) {
            log.warn("Route insertion failed for booking {}: {}", booking.getId(), e.getMessage());
        }

        broadcastBookingStatus(booking, oldStatus, Booking.BookingStatus.CONFIRMED);

        // Notify both sides (guide §25/notification types) and push to the
        // driver's private topic (guide §17 /topic/driver/{driverId}).
        try {
            notificationService.sendNotification(userId,
                    com.nimbus.notification.domain.entity.Notification.NotificationType.BOOKING_CONFIRMED,
                    "Booking confirmed",
                    "Your seat is confirmed for the ride.",
                    java.util.Map.of("bookingId", booking.getId().toString(),
                            "rideId", booking.getRide().getId().toString()));
            if (booking.getRide().getCreator() != null) {
                UUID driverUserId = booking.getRide().getCreator().getId();
                notificationService.sendNotification(driverUserId,
                        com.nimbus.notification.domain.entity.Notification.NotificationType.BOOKING_CONFIRMED,
                        "New passenger booking",
                        "A passenger confirmed " + booking.getSeats() + " seat(s) on your ride.",
                        java.util.Map.of("bookingId", booking.getId().toString()));
                messagingTemplate.convertAndSend("/topic/driver/" + driverUserId,
                        java.util.Map.of(
                                "event", "NEW_BOOKING",
                                "bookingId", booking.getId().toString(),
                                "rideId", booking.getRide().getId().toString(),
                                "data", java.util.Map.of(
                                        "seats", booking.getSeats(),
                                        "rideId", booking.getRide().getId().toString()),
                                "timestamp", Instant.now().toString()));
            }
        } catch (Exception e) {
            log.warn("Booking confirmation notification failed: {}", e.getMessage());
        }

        return toBookingResponse(booking);
    }

    /**
     * Get booking by ID. Only accessible to booking passenger or ride creator.
     */
    @Transactional(readOnly = true)
    public BookingResponse getBooking(UUID bookingId, UUID userId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new NimbusException(ErrorCode.BOOKING_NOT_FOUND, HttpStatus.NOT_FOUND));

        // Authorization check - passenger or ride creator
        if (!booking.getPassenger().getId().equals(userId) &&
                (booking.getRide().getCreator() == null ||
                 !booking.getRide().getCreator().getId().equals(userId))) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        return toBookingResponse(booking);
    }

    /**
     * List user's bookings.
     */
    @Transactional(readOnly = true)
    public List<BookingResponse> listBookings(UUID userId) {
        return bookingRepository.findByPassengerId(userId).stream()
                .map(this::toBookingResponse)
                .collect(Collectors.toList());
    }

    /**
     * Booking entities for a ride — for internal jobs (reminders etc.).
     */
    @Transactional(readOnly = true)
    public List<Booking> getRideBookingEntities(UUID rideId) {
        return bookingRepository.findByRideId(rideId);
    }

    /**
     * List the bookings on a ride. Only the ride creator (driver) may view
     * them — used by the driver app's ride control screen.
     */
    @Transactional(readOnly = true)
    public List<BookingResponse> listByRide(UUID rideId, UUID userId) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new NimbusException(ErrorCode.RIDE_NOT_FOUND, HttpStatus.NOT_FOUND));

        boolean isDriver = ride.getCreator() != null
                && ride.getCreator().getId().equals(userId);
        if (!isDriver) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        return bookingRepository.findByRideId(rideId).stream()
                .map(this::toBookingResponse)
                .collect(Collectors.toList());
    }

    /**
     * Cancel a booking.
     */
    @Transactional
    public void cancelBooking(UUID bookingId, UUID userId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new NimbusException(ErrorCode.BOOKING_NOT_FOUND, HttpStatus.NOT_FOUND));

        if (!booking.getPassenger().getId().equals(userId)) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        if (booking.getStatus() == Booking.BookingStatus.COMPLETED) {
            throw new NimbusException(ErrorCode.BOOKING_EXPIRED, HttpStatus.CONFLICT);
        }
        // Only HELD/CONFIRMED can be cancelled — PICKED_UP/EXPIRED/etc. must
        // surface a 409, not a raw IllegalStateException → 500 (guide §8).
        if (!booking.canBeCancelled()) {
            throw new NimbusException(ErrorCode.BOOKING_EXPIRED,
                    "Booking in status " + booking.getStatus()
                            + " cannot be cancelled", HttpStatus.CONFLICT);
        }

        doCancel(booking, userId);
    }

    /**
     * Driver-side cancellation used when a ride is cancelled (guide §5:
     * operations-driven cancellation cascades to bookings). Authorizes the
     * ride creator and cancels HELD/CONFIRMED bookings with refunds.
     */
    @Transactional
    public void cancelBookingByDriver(UUID bookingId, UUID driverUserId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new NimbusException(ErrorCode.BOOKING_NOT_FOUND, HttpStatus.NOT_FOUND));

        Ride ride = booking.getRide();
        boolean isRideDriver = ride.getCreator() != null
                && ride.getCreator().getId().equals(driverUserId);
        if (!isRideDriver) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }
        if (booking.getStatus() != Booking.BookingStatus.HELD
                && booking.getStatus() != Booking.BookingStatus.CONFIRMED) {
            return; // nothing active to cancel
        }
        doCancel(booking, driverUserId);
    }

    /** Shared cancellation body — authorization decided by the caller. */
    private void doCancel(Booking booking, UUID actorId) {
        Ride ride = booking.getRide();
        boolean rideStarted = ride.getStatus() == Ride.RideStatus.IN_PROGRESS
                || ride.getStatus() == Ride.RideStatus.ROUTE_LOCKED
                || ride.getStatus() == Ride.RideStatus.DRIVER_ARRIVING;

        // Validate state transition via the domain entity
        var oldStatus = booking.getStatus();
        booking.transitionTo(Booking.BookingStatus.CANCELLED);
        booking.setCancelledAt(Instant.now());
        booking.setCancelledBy(actorId);
        bookingRepository.save(booking);
        seatHoldStore.release(ride.getId(), booking.getId());
        voucherService.reverseRedemptionForBooking(booking.getId());
        broadcastBookingStatus(booking, oldStatus, Booking.BookingStatus.CANCELLED);
        broadcastSeatAvailability(ride);

        // Let the driver know a seat opened up.
        try {
            if (ride.getCreator() != null) {
                notificationService.sendNotification(ride.getCreator().getId(),
                        com.nimbus.notification.domain.entity.Notification.NotificationType.BOOKING_CANCELLED,
                        "Booking cancelled",
                        "A passenger cancelled their booking on your ride.",
                        java.util.Map.of("bookingId", booking.getId().toString()));
            }
        } catch (Exception e) {
            log.warn("Booking cancellation notification failed: {}", e.getMessage());
        }

        // Refund policy (guide §13): full refund if the ride has not
        // started; once underway the fare is forfeit and a cancellation
        // fee entry records the charge. Refunds credit the passenger's
        // wallet as app credit (source-specific returns are the
        // gateway's job).
        if (booking.getFinalPayable() != null
                && booking.getFinalPayable().signum() > 0) {
            var successfulPayment = paymentRepository
                    .findFirstByBookingIdAndStatusOrderByCreatedAtDesc(
                            booking.getId(), Payment.PaymentStatus.SUCCESS)
                    .orElse(null);
            if (!rideStarted && successfulPayment != null) {
                ledgerService.postRefund(booking, booking.getFinalPayable(),
                        successfulPayment.getId());
                // Mark the payment terminal in the same transaction. Without
                // this the admin refund action still considers it refundable
                // and can pay the passenger twice (guide §12/§13).
                successfulPayment.updateStatus(Payment.PaymentStatus.REFUNDED);
                paymentRepository.save(successfulPayment);
            } else if (rideStarted) {
                ledgerService.postCancellationFee(booking, booking.getFinalPayable());
            }
        }

        // Notify the passenger their booking was cancelled (by the driver,
        // or self-cancelled confirmation).
        try {
            notificationService.sendNotification(booking.getPassenger().getId(),
                    com.nimbus.notification.domain.entity.Notification.NotificationType.BOOKING_CANCELLED,
                    "Booking cancelled",
                    "Your booking was cancelled."
                            + (rideStarted ? " The ride was already underway." : ""),
                    java.util.Map.of("bookingId", booking.getId().toString()));
        } catch (Exception e) {
            log.warn("Passenger cancellation notification failed: {}", e.getMessage());
        }
    }

    /**
     * Mark passenger as picked up.
     */
    @Transactional
    public void pickup(UUID bookingId, UUID userId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new NimbusException(ErrorCode.BOOKING_NOT_FOUND, HttpStatus.NOT_FOUND));

        // Only the ride driver can mark pickup
        if (!booking.getRide().getCreator().getId().equals(userId)) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        if (booking.getStatus() != Booking.BookingStatus.CONFIRMED) {
            throw new NimbusException(ErrorCode.BOOKING_EXPIRED,
                    "Booking must be confirmed before pickup", HttpStatus.CONFLICT);
        }

        booking.transitionTo(Booking.BookingStatus.PICKED_UP);
        booking.setPickedUpAt(Instant.now());
        bookingRepository.save(booking);
        broadcastEvent(booking, "PASSENGER_PICKED_UP");
    }

    /**
     * Mark passenger as dropped off.
     */
    @Transactional
    public void dropoff(UUID bookingId, UUID userId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new NimbusException(ErrorCode.BOOKING_NOT_FOUND, HttpStatus.NOT_FOUND));

        if (!booking.getRide().getCreator().getId().equals(userId)) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        if (booking.getStatus() != Booking.BookingStatus.PICKED_UP) {
            throw new NimbusException(ErrorCode.BOOKING_EXPIRED,
                    "Booking must be picked up before dropoff", HttpStatus.CONFLICT);
        }

        booking.transitionTo(Booking.BookingStatus.COMPLETED);
        booking.setDroppedOffAt(Instant.now());
        bookingRepository.save(booking);
        broadcastEvent(booking, "PASSENGER_DROPPED_OFF");
    }

    /**
     * A quote is only valid for the segment it was priced for. A 150 m
     * tolerance absorbs GPS jitter while still preventing a passenger from
     * quoting a short trip and booking a materially longer one.
     */
    private void validateQuoteSegment(FareQuote quote, Double[] pickup, Double[] dropoff) {
        if (quote.getPickupLatitude() == null || quote.getPickupLongitude() == null
                || quote.getDropoffLatitude() == null || quote.getDropoffLongitude() == null) {
            throw new NimbusException(ErrorCode.FARE_QUOTE_EXPIRED,
                    "Fare quote is stale — request a new quote", HttpStatus.CONFLICT);
        }
        if (pickup == null || pickup.length < 2 || dropoff == null || dropoff.length < 2) {
            throw new NimbusException(ErrorCode.VALIDATION_ERROR,
                    "Pickup and drop-off are required", HttpStatus.BAD_REQUEST);
        }
        double pickupMeters = haversineMeters(pickup[1], pickup[0],
                quote.getPickupLatitude(), quote.getPickupLongitude());
        double dropoffMeters = haversineMeters(dropoff[1], dropoff[0],
                quote.getDropoffLatitude(), quote.getDropoffLongitude());
        if (pickupMeters > 150 || dropoffMeters > 150) {
            throw new NimbusException(ErrorCode.FARE_QUOTE_EXPIRED,
                    "Pickup/drop-off changed — request a new fare quote",
                    HttpStatus.CONFLICT);
        }
    }

    private double haversineMeters(double lat1, double lng1, double lat2, double lng2) {
        double r = 6371000.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        return 2 * r * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    private BookingResponse toBookingResponse(Booking booking) {
        BookingResponse.BookingResponseBuilder builder = BookingResponse.builder()
                .id(booking.getId())
                .rideId(booking.getRide() != null ? booking.getRide().getId() : null)
                .passengerId(booking.getPassenger() != null ? booking.getPassenger().getId() : null)
                .seats(booking.getSeats())
                .status(booking.getStatus())
                .pickupAddress(booking.getPickupAddress())
                .dropoffAddress(booking.getDropoffAddress())
                .pickupPlannedTime(booking.getPickupPlannedTime())
                .dropoffPlannedTime(booking.getDropoffPlannedTime())
                .pickedUpAt(booking.getPickedUpAt())
                .droppedOffAt(booking.getDroppedOffAt())
                .fareQuoteId(booking.getFareQuoteId())
                .plannedDistanceMeters(booking.getPlannedDistanceMeters())
                .plannedDurationSeconds(booking.getPlannedDurationSeconds())
                .finalPayable(booking.getFinalPayable())
                .createdAt(booking.getCreatedAt())
                .updatedAt(booking.getUpdatedAt());

        // Parse coordinates from WKT
        Double[] pickupCoords = parseLocation(booking.getPickupLocation());
        if (pickupCoords != null) {
            builder.pickupLatitude(pickupCoords[0]);
            builder.pickupLongitude(pickupCoords[1]);
        }
        Double[] dropoffCoords = parseLocation(booking.getDropoffLocation());
        if (dropoffCoords != null) {
            builder.dropoffLatitude(dropoffCoords[0]);
            builder.dropoffLongitude(dropoffCoords[1]);
        }

        return builder.build();
    }

    private void broadcastEvent(Booking booking, String event) {
        try {
            messagingTemplate.convertAndSend("/topic/ride/" + booking.getRide().getId(),
                    java.util.Map.of(
                            "event", event,
                            "bookingId", booking.getId().toString(),
                            "data", java.util.Map.of("bookingId", booking.getId().toString()),
                            "timestamp", Instant.now().toString()));
        } catch (Exception e) {
            log.warn("Failed to broadcast {}: {}", event, e.getMessage());
        }
    }

    /** Booking status transition event (guide §17: BOOKING_STATUS_CHANGED). */
    private void broadcastBookingStatus(Booking booking,
                                        Booking.BookingStatus oldStatus,
                                        Booking.BookingStatus newStatus) {
        try {
            messagingTemplate.convertAndSend("/topic/ride/" + booking.getRide().getId(),
                    java.util.Map.of(
                            "event", "BOOKING_STATUS_CHANGED",
                            "bookingId", booking.getId().toString(),
                            "data", java.util.Map.of(
                                    "oldStatus", oldStatus.name(),
                                    "newStatus", newStatus.name()),
                            "timestamp", Instant.now().toString()));
        } catch (Exception e) {
            log.warn("Failed to broadcast booking status change: {}", e.getMessage());
        }
    }

    private Double[] parseLocation(String wkt) {
        if (wkt != null && wkt.startsWith("POINT(")) {
            try {
                String coords = wkt.substring(6, wkt.length() - 1);
                String[] parts = coords.split(" ");
                Double lng = Double.parseDouble(parts[0]);
                Double lat = Double.parseDouble(parts[1]);
                return new Double[]{lat, lng};
            } catch (Exception ignored) {
            }
        }
        return null;
    }
}
