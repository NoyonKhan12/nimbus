# Nimbus - Bangladesh Commuter Ride-Pooling Platform

## Overview
Nimbus is a commuter ride-pooling platform for Bangladesh built as a Java 21 + Spring Boot 3.2.0 modular monolith. It supports OTP-based authentication with Bangladesh phone format (+880), real-time ride tracking via WebSocket/STOMP, and spatial data handling with PostgreSQL/PostGIS.

## Technology Stack
- **Java 21** (run via `/opt/homebrew/opt/openjdk@21`)
- **Spring Boot 3.2.0**
- **PostgreSQL 15 + PostGIS** (Docker: postgis/postgis:15-3.4)
- **Redis 7.2** (Docker: redis:7.2-alpine)
- **Liquibase** for database migrations
- **JWT** (access: 15min, refresh: 30 days) with Base64-encoded secret
- **Argon2** for password hashing
- **Testcontainers** for integration testing
- **springdoc-openapi 2.3.0** for API documentation

## Project Structure

### Domain Modules
- `auth/` - Authentication (OTP send/verify, refresh, logout)
- `user/` - User profile management, saved locations
- `driver/` - Driver profiles, vehicle management, driver applications
- `ride/` - Ride lifecycle (REQUESTED → ACTIVE → COMPLETED/CANCELLED)
- `booking/` - Booking with seat hold mechanism (5-min hold)
- `fare/` - Fare calculation and quoting
- `payment/` - Payment processing DTOs
- `wallet/` - Wallet balance and transactions
- `voucher/` - Voucher management and validation
- `notification/` - Notification DTOs
- `rating/` - Driver/user rating system
- `safety/` - SOS, trip sharing, WebSocket real-time updates
- `complaint/` - Complaint reporting
- `matching/` - (Reserved for future ride-matching logic)
- `routing/` - (Reserved for routing algorithms)
- `audit/` - Audit logging

### Common Modules
- `config/` - Spring configuration (Security, Redis, Cache, WebSocket, OpenAPI)
- `constants/` - ErrorCode enum
- `dto/` - Common DTOs (ApiResponse, PagedResponse)
- `entity/` - Core entities (User, UserProfile, UserDevice, SavedLocation, SystemConfiguration, AuditLog)
- `exception/` - Error handling (GlobalExceptionHandler, NimbusException, ErrorResponse)
- `repository/` - Core Spring Data JPA repositories
- `security/` - JWT utilities (JwtTokenUtil, JwtAuthenticationFilter)

## Build & Run

### Prerequisites
- Java 21 JDK (via Homebrew: `openjdk@21`)
- Docker (for PostgreSQL + Redis containers)

### Development Setup

The project has three environment-specific Docker Compose configurations: **local**, **dev**, and **prod**.

Set the active environment via the `APP_ENV` variable in `.env`:

```bash
cp .env.example .env  # then edit .env to set APP_ENV=local|dev|prod
```

#### Using the compose helper script

A helper script `./compose` automatically selects the right compose file based on `APP_ENV` in `.env`:

```bash
# Start the stack (builds and runs everything)
./compose up

# Start in detached mode
./compose up -d

# Stop and remove containers
./compose down

# View logs
./compose logs -f

# Rebuild images
./compose build
```

#### Using docker compose directly

```bash
# Local (your coding machine)
docker compose -f docker-compose.yml up --build

# Dev (containerized)
docker compose -f docker-compose.dev.yml up --build

# Prod
docker compose -f docker-compose.prod.yml up --build
```

#### Environment details

| Environment | Compose file | Dockerfile | API port | DB | Redis |
|---|---|---|---|---|---|
| **local** | `docker-compose.yml` | `Dockerfile.local` | 9090 | localhost:5432, `nimbus` | localhost:6379 |
| **dev** | `docker-compose.dev.yml` | `Dockerfile.dev` | 8080 | `postgres:5432`, `nimbus` | `redis:6379` (by name) |
| **prod** | `docker-compose.prod.yml` | `Dockerfile.prod` | 8080 | external/env vars | external/env vars |

- **Local**: live volume mounts for fast iteration, containers connect to host services via `host.docker.internal`
- **Dev**: all services containerized on internal Docker network, named volumes for persistence
- **Prod**: non-root container user, no DB/Redis ports exposed, all secrets via environment variables

#### Run without Docker (local only)
```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@21
mvn clean package -DskipTests
java -Dspring.profiles.active=local \
     -jar target/nimbus-1.0.0-SNAPSHOT.jar
```

### API Base URL
All endpoints are prefixed with `/api/v1` (configured via `server.servlet.context-path`).

### Profiles
- `local` - Local development (default)
- `dev` - Development environment
- `staging` - Staging environment
- `prod` - Production environment

## Testing

### Run Unit Tests
```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@21
mvn test
```

### Run Integration Tests (requires Docker)
```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@21
mvn verify
```

### Test Files
- `AuthServiceTest.java` - Unit tests for authentication service
- `OtpServiceTest.java` - Unit tests for OTP service
- `UserServiceTest.java` - Unit tests for user service
- `AuthFlowIntegrationIT.java` - Integration test for complete auth flow

## API Endpoints

### Auth (`/auth`)
- `POST /auth/send-otp` - Send OTP to phone number
- `POST /auth/verify-otp` - Verify OTP and get tokens
- `POST /auth/refresh` - Refresh access token
- `POST /auth/logout` - Logout (invalidate tokens)
- `GET /auth/sessions` - List active sessions

### User (`/user`)
- `GET /user/profile` - Get user profile
- `PUT /user/profile` - Update user profile
- `POST /user/saved-locations` - Save a location
- `GET /user/saved-locations` - Get all saved locations

### Driver (`/driver`)
- `POST /driver/application` - Apply to become a driver
- `GET /driver/profile/{id}` - Get driver profile

### Ride (`/ride`)
- `POST /ride` - Create a ride
- `GET /ride/{id}` - Get ride details

### Booking (`/booking`)
- `POST /booking` - Create a booking (with seat hold)
- `GET /booking/{id}` - Get booking details

### Fare (`/fare`)
- `POST /fare/quote` - Get fare quote

### WebSocket (`/ws`)
- `/ws` endpoint for STOMP real-time messaging
- Topics: `/topic/ride/{rideId}`, `/topic/driver/{driverId}`

## Database

### Liquibase Migrations
Migrations are in `src/main/resources/db/migration/db.changelog-master.yaml`:
- `v1` - Core schema (users, user_profiles, user_devices, saved_locations, system_configurations, audit_logs)
- `v2` - Extended schema (driver_profiles, vehicles, rides, ride_stops, bookings, fare_quotes, wallets, wallet_transactions, payments, vouchers, settlements, notifications, ratings, complaints, safety_events)

### Key Tables
- `users` - User accounts with phone, role, verification status
- `user_profiles` - Extended user information
- `driver_profiles` - Driver-specific attributes (license, vehicle, rating)
- `bookings` - Seat reservations with 5-minute hold (HELD → CONFIRMED → PICKED_UP → COMPLETED)
- `rides` - Ride trips with status tracking
- `wallets` - User wallet balances
- `payments` - Payment records with idempotency keys

## Configuration

### Spring Profiles
Profile-specific config lives in `src/main/resources/config/`:
- `application-local.yml` — localhost:5432, localhost:6379
- `application-dev.yml` — Docker service names (postgres, redis)
- `application-prod.yml` — all secrets via env vars, Hikari pool sizing

### Important Properties (application.yml)
- `app.jwt.secret` - Base64-encoded JWT signing secret
- `app.jwt.access-token-expiration-ms` - 900000 (15 min)
- `app.jwt.refresh-token-expiration-ms` - 2592000000 (30 days)
- `app.otp.*` - OTP configuration (expiration, code length, rate limits)
- `app.argon2.*` - Argon2 password hashing parameters

## Fare Calculation Formula
```
Total Fare = Base Fare + Distance Charge + Time Charge + Service Fee + Tax - Discount
```

## Seat Hold Mechanism
Bookings go through the following states:
1. **HELD** - Seat is reserved for 5 minutes (`seat_hold_duration_minutes`)
2. **CONFIRMED** - User confirms the booking
3. **PICKED_UP** - Driver picks up passenger
4. **COMPLETED** - Ride completed
5. **CANCELLED** - Booking cancelled (seat released)

## Error Handling
All API errors return `ApiResponse` with:
- `success: false`
- `error.code` - Error code from `ErrorCode` enum
- `error.message` - Human-readable error message
- `timestamp` - ISO timestamp

## Flutter Client

A Flutter client app lives at `clients/nimbus_app/` with the following structure:

| Directory | Purpose |
|---|---|
| `lib/core/` | Constants, theme, storage keys, utils |
| `lib/network/` | API client, Dio interceptors, error handling |
| `lib/api/` | REST API contract (retrofit) |
| `lib/dto/` | Data transfer objects (auth, user, ride, booking, fare, driver, payment) |
| `lib/services/` | Auth, user, API service, WebSocket service |
| `lib/models/` | Domain entities |
| `lib/bloc/` | BLoC state management (auth, ride, booking) |
| `lib/ui/` | Screens (auth flow, home, ride search, booking, payment, profile) |
| `lib/widgets/` | Reusable UI components |

State management: `flutter_bloc`. HTTP client: `dio` + `retrofit`. WebSocket: `web_socket_channel`. Maps: `google_maps_flutter`. Notifications: `firebase_messaging`. Secure storage: `flutter_secure_storage`.

Build:
```bash
cd clients/nimbus_app
flutter pub get
flutter run
```

## Development Notes

### Java Version
- The system default Java is 11 (used by the `aladin` project)
- For nimbus, always use: `export JAVA_HOME=/opt/homebrew/opt/openjdk@21`

### Docker Notes
- `docker-compose.yml` — local dev on your coding machine, API on port 9090
- `docker-compose.dev.yml` — containerized dev, API on port 8080
- `docker-compose.prod.yml` — production, secrets via environment variables
- `.env` — sets `APP_ENV=local|dev|prod` to control which compose file is used
- `./compose` — helper script that auto-selects compose file based on `APP_ENV` in `.env`
- Each compose file uses separate named volumes (`pgdata_local`, `pgdata_dev`, `pgdata_prod`)
- All containers use explicit names: `nimbus-postgres`, `nimbus-redis`, `nimbus-api`
- `Dockerfile.local` — local dev, Spring `local` profile active
- `Dockerfile.dev` — dev container, Spring `dev` profile active
- `Dockerfile.prod` — production, non-root user, Spring `prod` profile active

### Build Order
When rebuilding, ensure Lombok and MapStruct annotation processors are available. The `maven-compiler-plugin` handles this via `annotationProcessorPaths`.

### Troubleshooting
- If Docker tests fail with "Could not find a valid Docker environment", ensure Docker Desktop is running
- If compilation fails with `UnsupportedClassVersionError`, check Java version (must be 21+)
- If JWT secret errors occur, ensure the secret is Base64-encoded
