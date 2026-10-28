package com.nimbus.payment.domain.repository;

import com.nimbus.payment.domain.entity.PaymentTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public interface PaymentTransactionRepository extends JpaRepository<PaymentTransaction, UUID> {
    List<PaymentTransaction> findByPaymentId(UUID paymentId);

    boolean existsByProviderAndProviderEventRef(String provider, String providerEventRef);
}
