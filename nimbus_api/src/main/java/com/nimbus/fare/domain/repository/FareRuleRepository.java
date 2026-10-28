package com.nimbus.fare.domain.repository;

import com.nimbus.fare.domain.entity.FareRule;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface FareRuleRepository extends JpaRepository<FareRule, UUID> {

    Optional<FareRule> findByActiveTrueOrderByEffectiveFromDesc();

    Optional<FareRule> findByVersion(String version);
}
