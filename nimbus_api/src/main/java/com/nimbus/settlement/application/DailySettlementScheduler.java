package com.nimbus.settlement.application;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.ZoneOffset;

/**
 * Daily settlement job (guide §25/§13): closes the previous day's financial
 * period for every driver. The calculation itself lives in
 * {@link SettlementService} so the scheduled run and the admin trigger
 * share one implementation. Idempotent: a driver+period row is created once.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class DailySettlementScheduler {

    private final SettlementService settlementService;

    @Scheduled(cron = "${nimbus.settlement.cron:0 0 1 * * *}")
    @Transactional
    public void runDailySettlement() {
        int created = settlementService.settlePeriod(LocalDate.now(ZoneOffset.UTC).minusDays(1));
        log.info("Daily settlement complete: {} settlement rows created", created);
    }
}
