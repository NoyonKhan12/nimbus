-- ============================================================================
-- V5: Wallets, ledger accounts, ledger entries, settlements
-- ============================================================================

-- Wallets
CREATE TABLE wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    owner_type VARCHAR(20) NOT NULL,
    balance DECIMAL(18,2) NOT NULL DEFAULT 0,
    currency VARCHAR(10) NOT NULL DEFAULT 'BDT',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_wallets_owner ON wallets(owner_id);

-- Ledger accounts
CREATE TABLE ledger_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
    account_type VARCHAR(50) NOT NULL,
    balance DECIMAL(18,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ledger_accounts_wallet_id ON ledger_accounts(wallet_id);
CREATE INDEX idx_ledger_accounts_type ON ledger_accounts(account_type);

-- Ledger entries (immutable double-entry)
CREATE TABLE ledger_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES ledger_accounts(id) ON DELETE CASCADE,
    entry_type VARCHAR(20) NOT NULL, -- DEBIT or CREDIT
    amount DECIMAL(18,2) NOT NULL,
    reference_type VARCHAR(50),
    reference_id UUID,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ledger_entries_account_id ON ledger_entries(account_id);
CREATE INDEX idx_ledger_entries_reference ON ledger_entries(reference_type, reference_id);
CREATE INDEX idx_ledger_entries_created_at ON ledger_entries(created_at);

-- Settlements
CREATE TABLE settlements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES driver_profiles(id) ON DELETE CASCADE,
    period_start TIMESTAMP WITH TIME ZONE NOT NULL,
    period_end TIMESTAMP WITH TIME ZONE NOT NULL,
    gross_earnings DECIMAL(18,2) NOT NULL,
    commission DECIMAL(18,2) NOT NULL,
    adjustments DECIMAL(18,2) DEFAULT 0,
    refunds DECIMAL(18,2) DEFAULT 0,
    driver_credits DECIMAL(18,2) DEFAULT 0,
    payable DECIMAL(18,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    payment_reference VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_settlements_driver_id_period ON settlements(driver_id, period_start, period_end);
CREATE INDEX idx_settlements_status ON settlements(status);

-- Triggers
CREATE TRIGGER update_wallets_updated_at
    BEFORE UPDATE ON wallets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ledger_accounts_updated_at
    BEFORE UPDATE ON ledger_accounts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_settlements_updated_at
    BEFORE UPDATE ON settlements
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
