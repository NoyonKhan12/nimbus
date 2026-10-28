-- ============================================================================
-- V11: Fare rules (versioned), ledger immutability enforcement,
--      voucher funding source, payment webhook dedupe, recurring rides
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Fare rules: versioned rate cards. fare_quotes.rule_version references
-- fare_rules.version so historical quotes remain reproducible (guide §11).
-- ----------------------------------------------------------------------------
CREATE TABLE fare_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    version VARCHAR(50) NOT NULL UNIQUE,
    base_fare DECIMAL(18,2) NOT NULL,
    per_km_rate DECIMAL(18,2) NOT NULL,
    per_minute_rate DECIMAL(18,2) NOT NULL,
    service_fee DECIMAL(18,2) NOT NULL,
    minimum_fare DECIMAL(18,2) NOT NULL,
    tax_rate_percent DECIMAL(5,2) NOT NULL DEFAULT 0,
    commission_percent DECIMAL(5,2) NOT NULL DEFAULT 20,
    currency VARCHAR(10) NOT NULL DEFAULT 'BDT',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    effective_from TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_fare_rules_active ON fare_rules(is_active, effective_from);

-- Seed v1 from the system-configuration defaults used by FareService.
INSERT INTO fare_rules (version, base_fare, per_km_rate, per_minute_rate, service_fee, minimum_fare, tax_rate_percent)
VALUES ('v1', 25.00, 12.00, 0.50, 5.00, 50.00, 0.00);

-- ----------------------------------------------------------------------------
-- Ledger immutability (guide §5/§13): financial history is append-only.
-- Blocking UPDATE/DELETE at the database level and preventing account
-- deletion from cascading into entries.
-- ----------------------------------------------------------------------------
ALTER TABLE ledger_entries
    DROP CONSTRAINT ledger_entries_account_id_fkey;
ALTER TABLE ledger_entries
    ADD CONSTRAINT ledger_entries_account_id_fkey
    FOREIGN KEY (account_id) REFERENCES ledger_accounts(id) ON DELETE RESTRICT;

CREATE OR REPLACE FUNCTION prevent_ledger_mutation()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'ledger_entries is append-only: % not permitted', TG_OP;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ledger_entries_append_only
    BEFORE UPDATE OR DELETE ON ledger_entries
    FOR EACH ROW EXECUTE FUNCTION prevent_ledger_mutation();

-- ----------------------------------------------------------------------------
-- Vouchers: funding source (guide §6 - funding/rules)
-- ----------------------------------------------------------------------------
ALTER TABLE vouchers ADD COLUMN funding_source VARCHAR(30) NOT NULL DEFAULT 'PLATFORM';

-- ----------------------------------------------------------------------------
-- Payment webhook dedupe (guide §12): idempotent processing of provider
-- callbacks keyed by the provider's own event reference.
-- ----------------------------------------------------------------------------
ALTER TABLE payment_transactions ADD COLUMN provider_event_ref VARCHAR(255);
CREATE UNIQUE INDEX uk_payment_tx_provider_event
    ON payment_transactions(provider, provider_event_ref)
    WHERE provider_event_ref IS NOT NULL;

-- ----------------------------------------------------------------------------
-- Voucher redemption linkage (guide §6): quotes remember the voucher that
-- priced them; redemptions are idempotent per booking and reversible.
-- ----------------------------------------------------------------------------
ALTER TABLE fare_quotes ADD COLUMN voucher_code VARCHAR(50);

CREATE UNIQUE INDEX uk_voucher_redemptions_booking
    ON voucher_redemptions(booking_id)
    WHERE booking_id IS NOT NULL AND status = 'REDEEMED';

-- ----------------------------------------------------------------------------
-- Recurring rides (guide §2): a recurring ride carries its pattern; the
-- materializer clones it into concrete scheduled instances.
-- ----------------------------------------------------------------------------
ALTER TABLE rides
    ADD COLUMN recurrence_type VARCHAR(20) NOT NULL DEFAULT 'NONE',
    ADD COLUMN recurrence_until TIMESTAMP WITH TIME ZONE,
    ADD COLUMN parent_ride_id UUID;
ALTER TABLE rides
    ADD CONSTRAINT fk_rides_parent_ride FOREIGN KEY (parent_ride_id) REFERENCES rides(id);

CREATE INDEX idx_rides_recurrence ON rides(recurrence_type, recurrence_until);

-- ----------------------------------------------------------------------------
-- Safety events: full incident context (guide §19 — SOS records
-- ride/booking/driver/vehicle) plus trip-share tokens (guide §19/§15).
-- ----------------------------------------------------------------------------
ALTER TABLE safety_events
    ADD COLUMN driver_id UUID REFERENCES driver_profiles(id),
    ADD COLUMN vehicle_id UUID,
    ADD COLUMN share_token VARCHAR(64),
    ADD COLUMN expires_at TIMESTAMP WITH TIME ZONE;
CREATE UNIQUE INDEX uk_safety_events_share_token
    ON safety_events(share_token) WHERE share_token IS NOT NULL;
