# Nimbus — Bangladesh Commuter Ride-Pooling Platform

A modular Spring Boot 3.x monolith backend for commuter ride-pooling in Bangladesh.

## Architecture

- **Java 21** + Spring Boot 3.2.0
- **PostgreSQL + PostGIS** for spatial data
- **Redis** for OTP storage, caching, and real-time state
- **Liquibase** for database migrations
- **JWT** (access: 15min, refresh: 30 days) + Argon2 password hashing
- **WebSocket/STOMP** for real-time ride tracking

## Prerequisites

- Java 21 (Temurin or OpenJDK)
- Docker & Docker Compose
- Maven (or use the Maven Wrapper `./mvnw`)

## Quick Start

1. Start PostgreSQL and Redis:
   ```bash
   docker-compose up -d
   ```

2. Compile the project:
   ```bash
   ./mvnw compile
   ```

3. Run unit tests:
   ```bash
   ./mvnw test
   ```

4. Run integration tests (requires Docker):
   ```bash
   ./mvnw verify
   ```

5. Start the application:
   ```bash
   ./mvnw spring-boot:run
   ```

## Configuration

Set the following secret in your environment:
```bash
export APP_JWT_SECRET="your-base64-encoded-secret-key"
```

## API Documentation

Once the application is running, Swagger UI is available at:
- `http://localhost:8080/swagger-ui.html`
- OpenAPI spec at `http://localhost:8080/v3/api-docs.yaml`

## Project Structure

```
nimbus/
├── src/
│   ├── main/
│   │   ├── java/com/nimbus/
│   │   │   ├── auth/           # Authentication (OTP, JWT)
│   │   │   ├── audit/          # Audit logging
│   │   │   ├── config/         # Spring configuration
│   │   ├── constants/         # Error codes, constants
│   │   ├── dto/               # Request/Response DTOs
│   │   ├── entity/            # JPA entities
│   │   ├── exception/         # Exception handling
│   │   ├── repository/        # Spring Data repositories
│   │   ├── security/          # JWT, auth tokens
│   │   ├── user/              # User management
│   │   └── safety/            # Real-time WebSocket controllers
│   │   ├── resources/
│   │   │   ├── application.yml
│   │   │   └── db/migration/   # Liquibase changelogs
│   └── test/
│       ├── auth/           # Auth unit tests
│       ├── user/           # User service tests
│       └── integration/    # Testcontainers integration tests
├── docker-compose.yml
├── Dockerfile
├── pom.xml
└── PHASE1.md
```

## Key Design Decisions

- **Modular Monorepo**: Related features are grouped into packages (auth, user, safety) with clear boundaries
- **Database Authority**: Server is the sole authority for all business decisions
- **Financial Immutability**: Ledger entries never modified, only created
- **Backend for Frontend**: Clients cannot directly modify ride/driver state

## License

This project is for a Bangladesh commuter ride-pooling platform ("Nimbus").