package com.nimbus.voucher;

import com.nimbus.kernel.domain.entity.User;
import com.nimbus.kernel.domain.repository.UserRepository;
import com.nimbus.voucher.application.service.VoucherService;
import com.nimbus.voucher.domain.entity.Voucher;
import com.nimbus.voucher.domain.entity.VoucherRedemption;
import com.nimbus.voucher.domain.repository.VoucherRedemptionRepository;
import com.nimbus.voucher.domain.repository.VoucherRepository;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.Mockito.*;

/**
 * Voucher redemption lifecycle (guide §6/§13): redemption is recorded when
 * the booking confirms, is idempotent per booking, and reverses on
 * cancellation — so usage/per-user limits stay honest.
 */
@ExtendWith(MockitoExtension.class)
class VoucherServiceTest {

    @Mock private VoucherRepository voucherRepository;
    @Mock private VoucherRedemptionRepository redemptionRepository;
    @Mock private UserRepository userRepository;

    @InjectMocks
    private VoucherService service;

    private final UUID userId = UUID.randomUUID();
    private final UUID bookingId = UUID.randomUUID();

    @Test
    void recordRedemption_persistsWithBookingLink() {
        Voucher voucher = Voucher.builder().code("SAVE50").build();
        when(voucherRepository.findByCode("SAVE50")).thenReturn(Optional.of(voucher));
        when(userRepository.findById(userId)).thenReturn(Optional.of(
                User.builder().id(userId).build()));
        when(redemptionRepository.findByBookingId(bookingId)).thenReturn(List.of());

        service.recordRedemption(userId, "SAVE50", BigDecimal.TEN, BigDecimal.ONE, bookingId);

        verify(redemptionRepository).save(argThat(r ->
                r.getVoucher() == voucher
                        && r.getBooking() != null
                        && bookingId.equals(r.getBooking().getId())));
    }

    @Test
    void recordRedemption_isIdempotentPerBooking() {
        when(redemptionRepository.findByBookingId(bookingId)).thenReturn(List.of(
                VoucherRedemption.builder().build()));

        service.recordRedemption(userId, "SAVE50", BigDecimal.TEN, BigDecimal.ONE, bookingId);

        verify(redemptionRepository, never()).save(any());
    }

    @Test
    void recordRedemption_ignoresZeroDiscount() {
        service.recordRedemption(userId, "SAVE50", BigDecimal.TEN, BigDecimal.ZERO, bookingId);

        verifyNoInteractions(voucherRepository, redemptionRepository);
    }

    @Test
    void reverseRedemptionForBooking_flipsRedeemedToReversed() {
        VoucherRedemption redeemed = VoucherRedemption.builder()
                .status(VoucherRedemption.RedemptionStatus.REDEEMED)
                .build();
        VoucherRedemption alreadyReversed = VoucherRedemption.builder()
                .status(VoucherRedemption.RedemptionStatus.REVERSED)
                .build();
        when(redemptionRepository.findByBookingId(bookingId))
                .thenReturn(List.of(redeemed, alreadyReversed));

        service.reverseRedemptionForBooking(bookingId);

        assertEquals(VoucherRedemption.RedemptionStatus.REVERSED, redeemed.getStatus());
        verify(redemptionRepository).save(redeemed);
        verify(redemptionRepository, never()).save(alreadyReversed);
    }
}
