package com.nimbus.wallet.domain.repository;

import com.nimbus.wallet.domain.entity.LedgerEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public interface LedgerEntryRepository extends JpaRepository<LedgerEntry, UUID> {
    List<LedgerEntry> findByAccountId(UUID accountId);
    List<LedgerEntry> findByReferenceTypeAndReferenceId(String referenceType, UUID referenceId);
}
