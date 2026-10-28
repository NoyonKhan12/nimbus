package com.nimbus.fare.application.service;

import com.nimbus.fare.domain.entity.FareRule;
import com.nimbus.fare.domain.repository.FareRuleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

/**
 * Accessor for the currently active fare rule version.
 *
 * <p>Deliberately not Redis-cached: caching a JPA entity in Redis loses its
 * type on deserialization (ClassCastException on read), and the table is a
 * single indexed row lookup per quote. Quotes persist the rule version, so
 * reproducibility never depends on this lookup anyway.</p>
 */
@Component
@RequiredArgsConstructor
public class FareRuleProvider {

    private final FareRuleRepository fareRuleRepository;

    public FareRule getActiveRule() {
        return fareRuleRepository.findByActiveTrueOrderByEffectiveFromDesc()
                .orElse(null);
    }
}
