-- Bind fare quotes to the ride and passenger they were priced for so a
-- quote cannot be replayed on another ride/user/booking (guide §5/§11).
ALTER TABLE fare_quotes
    ADD COLUMN ride_id UUID REFERENCES rides(id),
    ADD COLUMN user_id UUID REFERENCES users(id);

CREATE INDEX idx_fare_quotes_ride_id ON fare_quotes(ride_id);
CREATE INDEX idx_fare_quotes_user_id ON fare_quotes(user_id);

-- A quote can be consumed by at most one booking.
CREATE UNIQUE INDEX uk_fare_quotes_booking
    ON fare_quotes(booking_id)
    WHERE booking_id IS NOT NULL;
