-- V9: Align audit/metadata and spatial columns with the entity field types.
--
-- The entities store these values as plain Java strings (coordinates ride in
-- dedicated scalar columns such as origin_latitude/pickup_latitude). Hibernate
-- binds String fields as varchar, which PostgreSQL rejects for inet/jsonb/
-- geometry columns even for NULL values — e.g. verify-otp failed with:
--   ERROR: column "ip_address" is of type inet but expression is of type
--          character varying
-- The columns are converted to text to match the code's actual usage.
-- (SavedLocation.location keeps its working geometry(Point,4326) mapping.)

-- Spatial GiST indexes on columns being converted must go first — a GiST
-- index has no operator class for the text type. They served the geometry
-- design; the columns are plain text afterwards, so the indexes have no
-- purpose. Matching searches use the scalar lat/lng columns.
DROP INDEX IF EXISTS idx_driver_profiles_location;
DROP INDEX IF EXISTS idx_ride_routes_geometry;

ALTER TABLE audit_logs ALTER COLUMN old_value TYPE text USING old_value::text;
ALTER TABLE audit_logs ALTER COLUMN new_value TYPE text USING new_value::text;

ALTER TABLE notifications ALTER COLUMN metadata TYPE text USING metadata::text;

ALTER TABLE payment_transactions ALTER COLUMN raw_response TYPE text USING raw_response::text;

ALTER TABLE bookings ALTER COLUMN pickup_location TYPE text USING pickup_location::text;
ALTER TABLE bookings ALTER COLUMN dropoff_location TYPE text USING dropoff_location::text;

ALTER TABLE rides ALTER COLUMN origin_location TYPE text USING origin_location::text;
ALTER TABLE rides ALTER COLUMN destination_location TYPE text USING destination_location::text;

ALTER TABLE ride_stops ALTER COLUMN location TYPE text USING location::text;

ALTER TABLE ride_routes ALTER COLUMN geometry TYPE text USING geometry::text;

ALTER TABLE driver_profiles ALTER COLUMN current_location TYPE text USING current_location::text;
