-- Dynamic roles with per-role permission maps.
CREATE TABLE roles (
    id            UUID PRIMARY KEY,
    name          VARCHAR(64)  NOT NULL UNIQUE,
    description   TEXT,
    is_system     BOOLEAN      NOT NULL DEFAULT FALSE,
    permissions   TEXT         NOT NULL DEFAULT '{}',
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    deleted_at    TIMESTAMPTZ
);

-- System roles: the defaults used by existing accounts.
-- PASSENGER / DRIVER are app-user roles referenced by legacy rows.
INSERT INTO roles (id, name, description, is_system, permissions, created_at, updated_at)
VALUES
  (gen_random_uuid(), 'PASSENGER', 'Rider app users — onboard via OTP (system)', TRUE,
   '{}', NOW(), NOW()),
  (gen_random_uuid(), 'DRIVER', 'Driver app users — onboard via application flow (system)', TRUE,
   '{}', NOW(), NOW()),
  (gen_random_uuid(), 'ADMIN', 'Full platform administration', TRUE,
   '{"users":"FULL","passengers":"FULL","drivers":"FULL","vehicles":"FULL","rides":"FULL","payments":"FULL","settlements":"FULL","complaints":"FULL","safety":"FULL","config":"FULL"}',
   NOW(), NOW()),
  (gen_random_uuid(), 'OPERATIONS', 'Days-of-operations staff: rides, drivers, vehicles', TRUE,
   '{"users":"NONE","passengers":"FULL","drivers":"FULL","vehicles":"FULL","rides":"FULL","payments":"VIEW","settlements":"VIEW","complaints":"VIEW","safety":"VIEW","config":"NONE"}',
   NOW(), NOW()),
  (gen_random_uuid(), 'FINANCE', 'Finance staff: payments and settlements', TRUE,
   '{"users":"VIEW","passengers":"VIEW","drivers":"VIEW","vehicles":"NONE","rides":"VIEW","payments":"FULL","settlements":"FULL","complaints":"NONE","safety":"NONE","config":"NONE"}',
   NOW(), NOW()),
  (gen_random_uuid(), 'SUPPORT', 'Customer support: passengers, complaints, trips', TRUE,
   '{"users":"VIEW","passengers":"VIEW","drivers":"VIEW","vehicles":"VIEW","rides":"VIEW","payments":"NONE","settlements":"NONE","complaints":"FULL","safety":"VIEW","config":"NONE"}',
   NOW(), NOW()),
  (gen_random_uuid(), 'SAFETY', 'Safety operations: SOS events and emergency follow-up', TRUE,
   '{"users":"NONE","passengers":"VIEW","drivers":"VIEW","vehicles":"VIEW","rides":"VIEW","payments":"NONE","settlements":"NONE","complaints":"VIEW","safety":"FULL","config":"NONE"}',
   NOW(), NOW());
