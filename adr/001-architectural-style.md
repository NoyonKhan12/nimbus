# ADR-001: Architectural Style - Modular Monolith with Hexagonal Architecture

## Status
Accepted

## Context
We need to build a rideshare platform (Nimbus) for Bangladesh that can scale from
an MVP to handle millions of rides. The team is starting small but expects to grow.

Key requirements:
- Fast initial delivery of core ride-hailing functionality
- Clear domain boundaries for maintainability
- Ability to split into microservices later if needed
- Backend must be authoritative for all safety-critical decisions (fares, seats, payments)

## Decision
We adopt a **modular monolith** with **hexagonal architecture** (ports and adapters).

### Structure
```
src/main/java/com/nimbus/
├── kernel/          # Shared kernel (domain primitives, exceptions, security)
├── auth/            # Authentication (OTP, JWT)
├── user/            # User management
├── driver/          # Driver profiles, vehicles, documents
├── ride/            # Ride lifecycle (driver-created journeys)
├── booking/         # Passenger bookings on rides
├── matching/        # Ride matching algorithm
├── routing/         # Route optimization
├── fare/            # Fare calculation
├── payment/         # Payment processing
├── wallet/          # Wallet and ledger (double-entry bookkeeping)
├── settlement/      # Driver settlements
├── voucher/         # Discount vouchers
├── notification/    # Push, SMS, email
├── rating/          # Post-trip ratings
├── complaint/       # Complaint handling
├── safety/          # SOS and safety events
└── admin/           # Admin operations
```

### Rationale
1. **Single deployable** - Simpler CI/CD, no distributed transaction complexity
2. **Clear boundaries** - Modules communicate only via defined interfaces
3. **Future-proof** - Modules can be extracted to separate services later
4. **Shared database** - Eliminates eventual consistency issues for critical operations
5. **Domain-driven design** - Each module encapsulates its domain logic

## Consequences
- Transaction boundaries are clear within modules
- Cross-module calls go through well-defined service interfaces
- Database migrations are applied centrally via Flyway
- Testing is straightforward without service mesh
