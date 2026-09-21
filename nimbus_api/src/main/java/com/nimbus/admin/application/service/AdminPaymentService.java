package com.nimbus.admin.application.service;

import com.nimbus.admin.domain.projection.PaymentAdminProjection;
import com.nimbus.kernel.application.dto.PagedResponse;
import com.nimbus.kernel.application.dto.PagedResponse.PageMeta;
import com.nimbus.payment.domain.entity.Payment;
import com.nimbus.payment.domain.repository.PaymentRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.*;

/**
 * Service for admin payment operations.
 * Caching at the service layer to avoid ResponseEntity serialization issues.
 */
@Service
@Slf4j
public class AdminPaymentService {

    private final PaymentRepository paymentRepository;
    private final AdminCacheService cacheService;

    public AdminPaymentService(PaymentRepository paymentRepository, AdminCacheService cacheService) {
        this.paymentRepository = paymentRepository;
        this.cacheService = cacheService;
    }

    public PagedResponse<PaymentAdminProjection> listPayments(int page, int size, String status) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));

        Payment.PaymentStatus statusEnum = null;
        if (status != null && !status.isEmpty()) {
            statusEnum = Payment.PaymentStatus.valueOf(status.toUpperCase());
        }

        Page<PaymentAdminProjection> paymentPage = paymentRepository.findAdminPayments(statusEnum, pageable);
        return toPagedResponse(paymentPage);
    }

    public Optional<PaymentAdminProjection> getPaymentById(String id) {
        UUID paymentId = UUID.fromString(id);
        return paymentRepository.findByIdProjection(paymentId);
    }

    public void refundPayment(String id) {
        UUID paymentId = UUID.fromString(id);
        Payment payment = paymentRepository.findById(paymentId)
            .orElseThrow(() -> new RuntimeException("Payment not found"));

        if (!payment.canBeRefunded()) {
            throw new RuntimeException("Payment cannot be refunded: " + payment.getStatus());
        }

        payment.setStatus(Payment.PaymentStatus.REFUNDED);
        paymentRepository.save(payment);

        cacheService.invalidatePayments();
        cacheService.invalidateDashboardStats();
    }

    private <T> PagedResponse<T> toPagedResponse(Page<T> page) {
        PageMeta meta = new PageMeta(
            page.getNumber(),
            page.getSize(),
            page.getTotalElements(),
            page.getTotalPages()
        );
        return PagedResponse.<T>builder()
            .success(true)
            .data(page.getContent())
            .meta(meta)
            .timestamp(Instant.now().toString())
            .build();
    }
}
