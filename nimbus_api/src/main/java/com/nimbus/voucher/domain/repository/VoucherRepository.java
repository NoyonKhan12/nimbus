package com.nimbus.voucher.domain.repository;

import com.nimbus.voucher.domain.entity.Voucher;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public interface VoucherRepository extends JpaRepository<Voucher, UUID> {
    Optional<Voucher> findByCode(String code);
    List<Voucher> findByActiveTrue();
}
