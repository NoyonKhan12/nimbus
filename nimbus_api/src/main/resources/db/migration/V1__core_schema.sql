-- ============================================================================
-- V1: Core schema - users, profiles, devices, saved locations, config, audit
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS postgis;

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(255),
    password_hash VARCHAR(255),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    role VARCHAR(50) NOT NULL DEFAULT 'PASSENGER',
    phone_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_deleted_at ON users(deleted_at);

-- User profiles
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    profile_photo_url TEXT,
    gender VARCHAR(20),
    emergency_contact_name VARCHAR(200),
    emergency_contact_phone VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);

-- User devices
CREATE TABLE user_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id VARCHAR(255) NOT NULL,
    platform VARCHAR(20) NOT NULL,
    push_token TEXT,
    app_version VARCHAR(50),
    last_seen_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_user_devices_user_device ON user_devices(user_id, device_id);
CREATE INDEX idx_user_devices_push_token ON user_devices(push_token);

-- Saved locations
CREATE TABLE saved_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    label VARCHAR(100) NOT NULL,
    address TEXT,
    location GEOMETRY(Point, 4326),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_saved_locations_user_id ON saved_locations(user_id);
CREATE INDEX idx_saved_locations_location ON saved_locations USING GIST(location);

-- System configurations
CREATE TABLE system_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    config_key VARCHAR(100) NOT NULL UNIQUE,
    config_value TEXT,
    config_type VARCHAR(50) NOT NULL,
    description TEXT,
    is_encrypted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_system_configurations_key ON system_configurations(config_key);

-- Audit logs
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_user_id UUID REFERENCES users(id),
    actor_role VARCHAR(50),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id UUID,
    old_value JSONB,
    new_value JSONB,
    ip_address INET,
    device_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_actor ON audit_logs(actor_user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- Default system configurations
INSERT INTO system_configurations (config_key, config_value, config_type, description) VALUES
    ('OTP_EXPIRATION_MINUTES', '5', 'INTEGER', 'OTP expiration in minutes'),
    ('OTP_CODE_LENGTH', '6', 'INTEGER', 'OTP code length'),
    ('OTP_MAX_ATTEMPTS', '3', 'INTEGER', 'Max OTP verification attempts'),
    ('OTP_RATE_LIMIT_PER_15_MIN', '5', 'INTEGER', 'Max OTP requests per 15 minutes'),
    ('JWT_ACCESS_TOKEN_EXPIRATION_MS', '900000', 'INTEGER', 'JWT access token expiry in ms (15 min)'),
    ('JWT_REFRESH_TOKEN_EXPIRATION_MS', '2592000000', 'INTEGER', 'JWT refresh token expiry in ms (30 days)'),
    ('BOOKING_SEAT_HOLD_MINUTES', '5', 'INTEGER', 'Seat hold duration in minutes'),
    ('BOOKING_CUTOFF_MINUTES', '30', 'INTEGER', 'Booking cutoff before scheduled time'),
    ('DEFAULT_BASE_FARE_BDT', '25.00', 'DECIMAL', 'Default base fare in BDT'),
    ('DEFAULT_PER_KM_FARE_BDT', '12.00', 'DECIMAL', 'Default per km fare in BDT'),
    ('DEFAULT_PER_MINUTE_FARE_BDT', '0.50', 'DECIMAL', 'Default per minute fare in BDT'),
    ('DEFAULT_MINIMUM_FARE_BDT', '50.00', 'DECIMAL', 'Default minimum fare in BDT'),
    ('DEFAULT_SERVICE_FEE_BDT', '5.00', 'DECIMAL', 'Default service fee in BDT'),
    ('DEFAULT_COMMISSION_PERCENT', '10.00', 'DECIMAL', 'Default platform commission percent'),
    ('TAX_RATE_PERCENT', '0.00', 'DECIMAL', 'Default tax rate percent'),
    ('MAX_DETOUR_METERS', '3000', 'INTEGER', 'Maximum allowed detour in meters'),
    ('MAX_WAIT_SECONDS', '300', 'INTEGER', 'Maximum passenger wait time in seconds'),
    ('MATCHING_RADIUS_KM', '5', 'INTEGER', 'Default matching radius in km'),
    ('FARE_QUOTE_EXPIRY_MINUTES', '5', 'INTEGER', 'Fare quote validity in minutes');

-- Update timestamp trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END $$
LANGUAGE plpgsql;

-- Triggers for auto-updating updated_at
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_devices_updated_at
    BEFORE UPDATE ON user_devices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_saved_locations_updated_at
    BEFORE UPDATE ON saved_locations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_system_configurations_updated_at
    BEFORE UPDATE ON system_configurations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
