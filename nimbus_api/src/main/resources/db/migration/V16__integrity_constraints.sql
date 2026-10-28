-- ============================================================================
-- V16: Integrity constraints found necessary by the guide compliance audit
-- ============================================================================

-- A driver gets at most one settlement per period; settlePeriod is
-- check-then-insert, so concurrent scheduler + admin trigger (or replicas)
-- could otherwise create duplicates (guide §13/§25).
ALTER TABLE settlements
    ADD CONSTRAINT uq_settlements_driver_period
    UNIQUE (driver_id, period_start, period_end);

-- Concurrent route-version inserts must not produce two active versions
-- with the same number (feeds the quote-staleness check, guide §10/§11).
CREATE UNIQUE INDEX uq_ride_routes_ride_version
    ON ride_routes(ride_id, version);

-- Ledger postings are unique per business reference + type: a replayed
-- webhook or a double-settle cannot create two entries for the same
-- event (guide §13 append-only, §12 idempotency).
CREATE UNIQUE INDEX uq_ledger_entries_reference
    ON ledger_entries(entry_type, reference_type, reference_id)
    WHERE reference_id IS NOT NULL;
