-- ============================================================================
-- V3: Rides, ride stops, ride passengers, bookings, fare quotes
-- ============================================================================

-- Rides
CREATE TABLE rides (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID REFERENCES driver_profiles(id),
    creator_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vehicle_id UUID REFERENCES vehicles(id),
    type VARCHAR(20) NOT NULL,
    scheduled_at TIMESTAMP WITH TIME ZONE,
    actual_start_at TIMESTAMP WITH TIME ZONE,
    actual_end_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    origin_location GEOMETRY(Point, 4326),
    origin_address TEXT,
    destination_location GEOMETRY(Point, 4326),
    destination_address TEXT,
    available_seats INTEGER NOT NULL DEFAULT 0,
    max_detour_meters INTEGER,
    max_wait_seconds INTEGER,
    route_version INTEGER NOT NULL DEFAULT 0,
    fare_rule_version VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_rides_status_scheduled_at ON rides(status, scheduled_at);
CREATE INDEX idx_rides_driver_status ON rides(driver_id, status);

-- Ride stops
CREATE TABLE ride_stops (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_id UUID NOT NULL REFERENCES rides(id) ON DELETE CASCADE,
    booking_id UUID, -- FK added after bookings is created (circular dependency)
    stop_sequence INTEGER NOT NULL,
    stop_type VARCHAR(20) NOT NULL,
    location GEOMETRY(Point, 4326),
    address TEXT,
    planned_time TIMESTAMP WITH TIME ZONE,
    actual_time TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ride_stops_ride_seq ON ride_stops(ride_id, stop_sequence);
CREATE INDEX idx_ride_stops_booking_id ON ride_stops(booking_id);

-- Ride passengers
CREATE TABLE ride_passengers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_id UUID NOT NULL REFERENCES rides(id) ON DELETE CASCADE,
    passenger_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    booking_id UUID, -- FK added after bookings is created (circular dependency)
    seats INTEGER NOT NULL DEFAULT 1,
    journey_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(ride_id, passenger_id)
);

CREATE INDEX idx_ride_passengers_ride_id ON ride_passengers(ride_id);
CREATE INDEX idx_ride_passengers_passenger_id ON ride_passengers(passenger_id);

-- Bookings
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_id UUID NOT NULL REFERENCES rides(id) ON DELETE CASCADE,
    passenger_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    seats INTEGER NOT NULL DEFAULT 1,
    status VARCHAR(20) NOT NULL DEFAULT 'HELD',
    pickup_location GEOMETRY(Point, 4326),
    pickup_address TEXT,
    dropoff_location GEOMETRY(Point, 4326),
    dropoff_address TEXT,
    pickup_stop_id UUID REFERENCES ride_stops(id),
    dropoff_stop_id UUID REFERENCES ride_stops(id),
    pickup_planned_time TIMESTAMP WITH TIME ZONE,
    dropoff_planned_time TIMESTAMP WITH TIME ZONE,
    picked_up_at TIMESTAMP WITH TIME ZONE,
    dropped_off_at TIMESTAMP WITH TIME ZONE,
    fare_quote_id UUID, -- FK added in V4 after fare_quotes exists
    planned_distance_meters INTEGER,
    planned_duration_seconds INTEGER,
    final_payable DECIMAL(18,2),
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancelled_by UUID REFERENCES users(id),
    cancellation_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_bookings_ride_id ON bookings(ride_id);
CREATE INDEX idx_bookings_ride_id_status ON bookings(ride_id, status);
CREATE INDEX idx_bookings_passenger_id_created_at ON bookings(passenger_id, created_at);

-- Deferred FK constraints (tables reference each other, so added post-create)
ALTER TABLE ride_stops
    ADD CONSTRAINT fk_ride_stops_booking_id FOREIGN KEY (booking_id) REFERENCES bookings(id);

ALTER TABLE ride_passengers
    ADD CONSTRAINT fk_ride_passengers_booking_id FOREIGN KEY (booking_id) REFERENCES bookings(id);

-- Ride routes
CREATE TABLE ride_routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_id UUID NOT NULL REFERENCES rides(id) ON DELETE CASCADE,
    version INTEGER NOT NULL,
    provider VARCHAR(50),
    polyline TEXT,
    geometry GEOMETRY(LineString, 4326),
    distance_meters INTEGER,
    duration_seconds INTEGER,
    optimization_score DECIMAL(10,4),
    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ride_routes_ride_version ON ride_routes(ride_id, version);
CREATE INDEX idx_ride_routes_geometry ON ride_routes USING GIST(geometry);

-- Triggers
CREATE TRIGGER update_rides_updated_at
    BEFORE UPDATE ON rides
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ride_stops_updated_at
    BEFORE UPDATE ON ride_stops
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ride_passengers_updated_at
    BEFORE UPDATE ON ride_passengers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at
    BEFORE UPDATE ON bookings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
