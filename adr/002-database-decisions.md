# ADR-002: Database Decisions - PostgreSQL + PostGIS + Redis

## Status
Accepted

## Context
Nimbus requires:
1. Spatial data support for geolocation and route matching
2. ACID transactions for financial operations (payments, settlements)
3. Fast temporary storage for OTP, caching, and idempotency
4. High-performance geospatial queries for ride matching

## Decision

### Primary Database: PostgreSQL with PostGIS
- **UUID v4** as primary keys (distributed-safe, no sequential enumeration)
- **PostGIS** for geospatial types (Point, LineString) and spatial indexes (GIST)
- **NUMERIC(18,2)** for all monetary values to avoid floating-point errors
- **UTC timestamps** for all temporal data
- **Asia/Dhaka** timezone for business logic and scheduled jobs
- **WAL (Write-Ahead Logging)** for durability
- **Row-level locking** (`@Lock(PESSIMISTIC_WRITE)`) for seat allocation
- **Advisory locks** for distributed operations where needed

### Schema Migrations
- **Flyway** for version-controlled schema migrations (V1-V7)
- **Migration naming**: `V{n}__{description}.sql`
- **Baseline version**: 0 (for existing database compatibility)
- All migrations are idempotent and reversible where possible

### Caching & Temporary Storage: Redis
- **OTP storage** with 5-minute TTL
- **Idempotency keys** with 48-hour TTL for payment/retry safety
- **Rate limiting** via sliding window counters
- **Seat holds** with 5-minute TTL (Redis-backed, validated against DB)
- **Caching** for frequently accessed read data

## Rationale

### PostgreSQL + PostGIS
1. PostGIS is the industry standard for geospatial data in PostgreSQL
2. Spatial indexes (GIST) enable efficient `ST_DWithin` proximity queries
3. ACID compliance is mandatory for financial correctness
4. UUID keys prevent information leakage and support future sharding
5. Decimal type ensures monetary precision

### Redis
1. OTP must be ephemeral (5-minute expiry) - perfect for Redis TTL
2. Idempotency protection requires fast lookup (Redis provides O(1))
3. Rate limiting needs atomic increment operations
4. Caching frequently accessed data reduces database load

## Consequences
- Database backups must include PostGIS extension data
- Redis persistence strategy (AOF) must be configured for production
- Connection pooling (HikariCP) is configured for optimal performance
- Flyway migrations must be tested against a real PostgreSQL instance
