package com.nimbus.voucher.domain.repository;

import com.nimbus.voucher.domain.entity.VoucherRedemption;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public interface VoucherRedemptionRepository extends JpaRepository<VoucherRedemption, UUID> {
    long countByVoucherIdAndUserId(UUID voucherId, UUID userId);
    long countByVoucherId(UUID voucherId);
    List<VoucherRedemption> findByVoucherId(UUID voucherId);
    List<VoucherRedemption> findByUserId(UUID userId);
    List<VoucherRedemption> findByBookingId(UUID bookingId);
}
