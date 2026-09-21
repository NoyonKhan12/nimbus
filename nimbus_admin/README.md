# Nimbus Admin Panel

A Next.js 14 admin dashboard for the Nimbus ride-pooling platform management.

## Features

- **Authentication** — JWT-based admin login with automatic token refresh
- **Dashboard** — Key statistics overview with revenue, ride counts
- **User Management** — Search, suspend/activate, delete users
- **Driver Management** — Approve/reject applications, suspend/activate drivers
- **Ride Tracking** — View all rides with status filtering
- **Payment Management** — List payments, issue refunds
- **Settlement Management** — Track driver settlements and payouts

## Tech Stack

- **Next.js 14** (App Router, TypeScript)
- **Tailwind CSS** — styling
- **Axios** — HTTP client with JWT interceptors
- **React Hook Form** — form validation
- **js-cookie** — cookie management for tokens

## Getting Started

### Prerequisites

- Node.js 18+
- npm or yarn

### Installation

```bash
cd clients/nimbus_admin
npm install
```

### Environment Variables

Create a `.env.local` file:

```bash
# API base URL (defaults to http://localhost:9090/api/v1)
NEXT_PUBLIC_API_BASE_URL=http://localhost:9090/api/v1
```

### Development

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### Build

```bash
npm run build
npm start
```

## Project Structure

```
src/
├── app/                    # Next.js App Router pages
│   ├── login/              # Login page
│   └── dashboard/          # Dashboard routes with Layout
│       ├── users/
│       ├── drivers/
│       ├── rides/
│       ├── payments/
│       └── settlements/
├── components/             # Shared React components
├── services/               # API services
│   ├── api.ts              # Axios client with JWT interceptors
│   ├── auth.ts
│   ├── users.ts
│   ├── drivers.ts
│   ├── rides.ts
│   ├── payments.ts
│   ├── settlements.ts
│   └── dashboard.ts
├── hooks/                  # Custom React hooks
├── lib/                    # Utilities and constants
│   ├── constants.ts
│   └── utils.ts
├── styles/                 # Global CSS
└── types/                  # TypeScript type definitions
```

## API Endpoints

The admin panel consumes the following backend endpoints:

| Endpoint | Description |
|---|---|
| `POST /admin/auth/login` | Admin login (email/password) |
| `GET /admin/users` | List users |
| `GET /admin/drivers` | List drivers |
| `GET /admin/rides` | List rides |
| `GET /admin/payments` | List payments |
| `GET /admin/settlements` | List settlements |
| `GET /admin/dashboard/stats` | Dashboard statistics |

## License

Part of the Nimbus project.
