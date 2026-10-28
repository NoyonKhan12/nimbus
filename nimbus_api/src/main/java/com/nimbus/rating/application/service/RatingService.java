package com.nimbus.rating.application.service;

import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.booking.domain.repository.BookingRepository;
import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.kernel.domain.entity.User;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.kernel.domain.repository.UserRepository;
import com.nimbus.rating.application.RatingRequest;
import com.nimbus.rating.domain.entity.Rating;
import com.nimbus.rating.domain.repository.RatingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.*;

/**
 * Rating service for post-trip feedback.
 *
 * <p>Ratings update the rated user's average score in a transactionally
 * safe manner. Only one rating per booking per rater is allowed.</p>
 */
@Service
@RequiredArgsConstructor
public class RatingService {

    private final RatingRepository ratingRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final com.nimbus.driver.domain.repository.DriverProfileRepository driverProfileRepository;

    /**
     * Create a rating for a completed booking.
     */
    @Transactional
    public void createRating(UUID userId, RatingRequest request) {
        // Validate booking exists and is completed
        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new NimbusException(ErrorCode.BOOKING_NOT_FOUND, HttpStatus.NOT_FOUND));

        if (booking.getStatus() != Booking.BookingStatus.COMPLETED) {
            throw new NimbusException(ErrorCode.BOOKING_EXPIRED,
                    "Can only rate completed bookings", HttpStatus.CONFLICT);
        }

        // Verify rater is participant in the booking
        User rater = userRepository.findById(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.USER_NOT_FOUND, HttpStatus.NOT_FOUND));

        // Authorization: only passenger or driver can rate
        boolean isPassenger = booking.getPassenger().getId().equals(userId);
        boolean isDriver = booking.getRide() != null &&
                booking.getRide().getCreator() != null &&
                booking.getRide().getCreator().getId().equals(userId);

        if (!isPassenger && !isDriver) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        // Get rated user
        User ratedUser = userRepository.findById(request.getRatedId())
                .orElseThrow(() -> new NimbusException(ErrorCode.USER_NOT_FOUND, HttpStatus.NOT_FOUND));

        // The rated user must be the other participant in this booking.
        // Without this check a passenger could rate any account (or
        // themselves), distorting public driver/passenger reputation.
        UUID expectedCounterparty = null;
        if (isPassenger && booking.getRide() != null
                && booking.getRide().getCreator() != null) {
            expectedCounterparty = booking.getRide().getCreator().getId();
        } else if (isDriver && booking.getPassenger() != null) {
            expectedCounterparty = booking.getPassenger().getId();
        }
        if (expectedCounterparty == null
                || !expectedCounterparty.equals(request.getRatedId())) {
            throw new NimbusException(ErrorCode.VALIDATION_ERROR,
                    "You can only rate the other participant in this booking",
                    HttpStatus.BAD_REQUEST);
        }

        // Check for duplicate rating
        if (ratingRepository.existsByBookingIdAndRaterId(request.getBookingId(), userId)) {
            throw new NimbusException(ErrorCode.VALIDATION_ERROR,
                    "Rating already submitted for this booking", HttpStatus.CONFLICT);
        }

        // Create rating
        Rating rating = Rating.builder()
                .booking(booking)
                .rater(rater)
                .rated(ratedUser)
                .score(request.getScore())
                .comment(request.getComment())
                .createdAt(Instant.now())
                .build();

        ratingRepository.save(rating);

        // Update the rated driver's rolling average (guide §6/§19) — the
        // driver profile rating is what matching and the apps display.
        if (booking.getRide() != null && booking.getRide().getDriver() != null) {
            var driverProfile = booking.getRide().getDriver();
            if (driverProfile.getUser().getId().equals(request.getRatedId())) {
                Double average = ratingRepository.findByRatedId(request.getRatedId()).stream()
                        .mapToInt(Rating::getScore)
                        .average()
                        .orElse(0.0);
                driverProfile.setRating(java.math.BigDecimal
                        .valueOf(average)
                        .setScale(2, java.math.RoundingMode.HALF_UP));
                driverProfileRepository.save(driverProfile);
            }
        }
    }

    /**
     * Get ratings for a user.
     */
    @Transactional(readOnly = true)
    public List<Rating> getUserRatings(UUID userId, int limit) {
        return ratingRepository.findByRatedId(userId).stream()
                .limit(limit)
                .toList();
    }
}
