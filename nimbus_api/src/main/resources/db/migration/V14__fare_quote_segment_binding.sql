-- Bind a fare quote to the passenger's actual pickup/drop-off segment.
-- Without this, a passenger could request a cheap short quote and then
-- create a booking for a much longer segment, paying the stale quote.
ALTER TABLE fare_quotes
    ADD COLUMN pickup_latitude DOUBLE PRECISION,
    ADD COLUMN pickup_longitude DOUBLE PRECISION,
    ADD COLUMN dropoff_latitude DOUBLE PRECISION,
    ADD COLUMN dropoff_longitude DOUBLE PRECISION;
