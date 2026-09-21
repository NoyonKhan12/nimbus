package com.nimbus.wallet.domain.repository;

import com.nimbus.wallet.domain.entity.LedgerAccount;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public interface LedgerAccountRepository extends JpaRepository<LedgerAccount, UUID> {
    Optional<LedgerAccount> findByWalletIdAndAccountType(UUID walletId, LedgerAccount.AccountType accountType);
    List<LedgerAccount> findByWalletId(UUID walletId);
}
