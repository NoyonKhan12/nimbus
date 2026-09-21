package com.nimbus.admin.application.service;

import com.nimbus.admin.domain.projection.SettlementAdminProjection;
import com.nimbus.kernel.application.dto.PagedResponse;
import com.nimbus.kernel.application.dto.PagedResponse.PageMeta;
import com.nimbus.settlement.domain.entity.Settlement;
import com.nimbus.settlement.domain.repository.SettlementRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.*;

/**
 * Service for admin settlement operations.
 * Caching at the service layer to avoid ResponseEntity serialization issues.
 */
@Service
@Slf4j
public class AdminSettlementService {

    private final SettlementRepository settlementRepository;

    public AdminSettlementService(SettlementRepository settlementRepository) {
        this.settlementRepository = settlementRepository;
    }

    public PagedResponse<SettlementAdminProjection> listSettlements(int page, int size, String status) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));

        Settlement.SettlementStatus statusEnum = null;
        if (status != null && !status.isEmpty()) {
            statusEnum = Settlement.SettlementStatus.valueOf(status.toUpperCase());
        }

        Page<SettlementAdminProjection> settlementPage = settlementRepository.findAdminSettlements(statusEnum, pageable);
        return toPagedResponse(settlementPage);
    }

    public Optional<SettlementAdminProjection> getSettlementById(String id) {
        UUID settlementId = UUID.fromString(id);
        return settlementRepository.findByIdProjection(settlementId);
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
