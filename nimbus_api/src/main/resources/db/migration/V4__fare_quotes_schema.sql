-- ============================================================================
-- V4: Fare quotes, payments, payment transactions
-- ============================================================================

-- Fare quotes
CREATE TABLE fare_quotes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID REFERENCES bookings(id),
    rule_version VARCHAR(50) NOT NULL,
    route_version INTEGER NOT NULL,
    distance_meters INTEGER NOT NULL,
    duration_seconds INTEGER NOT NULL,
    base_fare DECIMAL(18,2) NOT NULL,
    distance_charge DECIMAL(18,2) NOT NULL,
    time_charge DECIMAL(18,2) NOT NULL,
    service_fee DECIMAL(18,2) NOT NULL,
    tax DECIMAL(18,2) NOT NULL DEFAULT 0,
    discount DECIMAL(18,2) NOT NULL DEFAULT 0,
    gross_fare DECIMAL(18,2) NOT NULL,
    final_payable DECIMAL(18,2) NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT 'BDT',
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_fare_quotes_booking_id ON fare_quotes(booking_id);

-- Deferred FK constraint (bookings created in V3 references fare_quotes)
ALTER TABLE bookings
    ADD CONSTRAINT fk_bookings_fare_quote_id FOREIGN KEY (fare_quote_id) REFERENCES fare_quotes(id);

-- Payments
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id),
    payer_id UUID NOT NULL REFERENCES users(id),
    amount DECIMAL(18,2) NOT NULL,
    method VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    provider_reference VARCHAR(255),
    idempotency_key VARCHAR(255) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payments_booking_id ON payments(booking_id);
CREATE INDEX idx_payments_payer_id ON payments(payer_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_idempotency_key ON payments(idempotency_key);

-- Payment transactions
CREATE TABLE payment_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL REFERENCES payments(id),
    provider VARCHAR(50) NOT NULL,
    provider_status VARCHAR(50),
    amount DECIMAL(18,2),
    raw_response JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payment_transactions_payment_id ON payment_transactions(payment_id);

-- Trigger
CREATE TRIGGER update_payments_updated_at
    BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
