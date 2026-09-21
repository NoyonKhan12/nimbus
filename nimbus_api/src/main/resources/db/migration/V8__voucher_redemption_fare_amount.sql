-- ============================================================================
-- V8: Add fare_amount to voucher_redemptions (VoucherRedemption.fareAmount
-- was missing from the original V6 table definition)
-- ============================================================================

ALTER TABLE voucher_redemptions ADD COLUMN fare_amount DECIMAL(18,2);
