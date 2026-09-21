-- ============================================================================
-- V9: Additional indexes for admin query performance
-- Optimizations for dashboard stats and admin listing endpoints
-- ============================================================================

-- Index for fast user search (by phone or email, with status filter)
CREATE INDEX IF NOT EXISTS idx_users_phone_email_search ON users(phone, email);
CREATE INDEX IF NOT EXISTS idx_users_status_created_at ON users(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_users_role_status ON users(role, status);

-- Index for driver listing with user joins (approval + driver status)
CREATE INDEX IF NOT EXISTS idx_driver_profiles_approval_driver_status ON driver_profiles(approval_status, driver_status);

-- Index for ride listing (status + created_at is already there from V3, but add sort optimization)
CREATE INDEX IF NOT EXISTS idx_rides_created_at_desc ON rides(created_at DESC);

-- Index for payment listing with status filter
CREATE INDEX IF NOT EXISTS idx_payments_status_created_at ON payments(status, created_at DESC);

-- Index for settlement listing with status filter
CREATE INDEX IF NOT EXISTS idx_settlements_status_created_at ON settlements(status, created_at DESC);

-- Composite index for booking lookups (used in payment joins)
CREATE INDEX IF NOT EXISTS idx_bookings_passenger_id_status ON bookings(passenger_id, status);

-- Index to speed up dashboard count queries
CREATE INDEX IF NOT EXISTS idx_driver_documents_driver_id_status ON driver_documents(driver_id, status);
CREATE INDEX IF NOT EXISTS idx_vehicles_driver_id_status ON vehicles(driver_id, status);

COMMENT ON INDEX idx_users_status_created_at IS 'Speeds up admin user listing and status filtering';
COMMENT ON INDEX idx_driver_profiles_approval_driver_status IS 'Speeds up admin driver listing with approval status filter';
COMMENT ON INDEX idx_rides_created_at_desc IS 'Speeds up admin recent rides query (ORDER BY created_at DESC)';
COMMENT ON INDEX idx_payments_status_created_at IS 'Speeds up admin payment listing and status filtering';
COMMENT ON INDEX idx_settlements_status_created_at IS 'Speeds up admin settlement listing and status filtering';
