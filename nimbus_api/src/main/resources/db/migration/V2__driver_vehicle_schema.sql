-- ============================================================================
-- V2: Driver, vehicle, documents schema
-- ============================================================================

-- Driver profiles
CREATE TABLE driver_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    driver_status VARCHAR(20) NOT NULL DEFAULT 'OFFLINE',
    approval_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    license_number VARCHAR(100),
    license_expiry TIMESTAMP WITH TIME ZONE,
    rating DECIMAL(3,2) DEFAULT 0,
    reliability_score DECIMAL(5,4) DEFAULT 1.0,
    current_location GEOMETRY(Point, 4326),
    current_location_updated_at TIMESTAMP WITH TIME ZONE,
    total_rides INTEGER NOT NULL DEFAULT 0,
    total_earnings DECIMAL(18,2) NOT NULL DEFAULT 0,
    commission_rate DECIMAL(5,2),
    due_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_driver_profiles_user_id ON driver_profiles(user_id);
CREATE INDEX idx_driver_profiles_approval_status ON driver_profiles(approval_status);
CREATE INDEX idx_driver_profiles_driver_status ON driver_profiles(driver_status);
CREATE INDEX idx_driver_profiles_location ON driver_profiles USING GIST(current_location);
CREATE INDEX idx_driver_profiles_due_amount ON driver_profiles(due_amount);

-- Driver documents
CREATE TABLE driver_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES driver_profiles(id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL,
    document_number VARCHAR(255),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    expires_at TIMESTAMP WITH TIME ZONE,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    document_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_driver_documents_driver_id ON driver_documents(driver_id);
CREATE INDEX idx_driver_documents_type ON driver_documents(document_type);
CREATE INDEX idx_driver_documents_expires_at ON driver_documents(expires_at);
CREATE INDEX idx_driver_documents_status ON driver_documents(status);

-- Vehicles
CREATE TABLE vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES driver_profiles(id) ON DELETE CASCADE,
    registration_number VARCHAR(100) NOT NULL UNIQUE,
    type VARCHAR(50) NOT NULL,
    model VARCHAR(100),
    year INTEGER,
    color VARCHAR(50),
    seat_capacity INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_vehicles_driver_id ON vehicles(driver_id);

-- Vehicle documents
CREATE TABLE vehicle_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL,
    document_number VARCHAR(255),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    expires_at TIMESTAMP WITH TIME ZONE,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    document_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_vehicle_documents_vehicle_id ON vehicle_documents(vehicle_id);
CREATE INDEX idx_vehicle_documents_type ON vehicle_documents(document_type);
CREATE INDEX idx_vehicle_documents_expires_at ON vehicle_documents(expires_at);

-- Triggers
CREATE TRIGGER update_driver_profiles_updated_at
    BEFORE UPDATE ON driver_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_driver_documents_updated_at
    BEFORE UPDATE ON driver_documents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vehicles_updated_at
    BEFORE UPDATE ON vehicles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vehicle_documents_updated_at
    BEFORE UPDATE ON vehicle_documents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
