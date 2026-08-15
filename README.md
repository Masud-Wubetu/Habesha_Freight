# 🚚 HabeshaFreight — Digital Freight Marketplace Backend

![Project Status](https://img.shields.io/badge/Status-Active%20Development-brightgreen)
![Language](https://img.shields.io/badge/Language-TypeScript%205.4-blue)
![Framework](https://img.shields.io/badge/Framework-Express%204.19-lightgrey)
![Database](https://img.shields.io/badge/Database-PostgreSQL%20%2B%20PostGIS-blue)
![Test Status](https://img.shields.io/badge/Tests-32%2F32%20Passing-brightgreen)

## Group Member
- 1, Masud Wubetu Hassen  CTC-6562-26
- 2, Ibrahim Kedir Amdela CTC-283-26
- 3, Hiba Abdulhamid Mohammed CTC-2402-26
- 4, Mahlet Tadesse Gebreselasse CTC-1020-26
- 5, Markon Tamirat Hailu CTC-7813-26

## 📌 Overview

**HabeshaFreight** is a digital freight marketplace engine tailored to the operational realities of Ethiopian regional road transport. It connects verified shippers with verified drivers and fleet owners, replacing fragmented phone-based coordination and multi-layer broker chains with a transparent, audited, and secure digital workflow.

The core backend service provides multi-role authentication (OTP + JWT), role-based access control (RBAC), relational database modeling, and a feature-rich Admin Operations Suite.

---

## 📊 Overall Project Implementation Status

Below is the comprehensive analysis of the project's current implementation status based on code audit:

| Subsystem / Module | Functional Status | Details & Progress |
| :--- | :---: | :--- |
| **Authentication & Auth Security** | 🟢 **Complete** | OTP registration, phone verification, bcrypt hashing, JWT issuance (`/api/auth`) |
| **Role-Based Access Control (RBAC)** | 🟢 **Complete** | Role enforcement middleware (`SHIPPER`, `DRIVER`, `FLEET_OWNER`, `ADMIN`) |
| **Database Schema & Migrations** | 🟢 **Complete (Core)** | Knex migrations for `users`, `vehicles`, `loads`, `bids`, `audit_logs` + admin fields |
| **Admin Operations Suite** | 🟢 **Complete** | Dashboard metrics, User CRUD/suspend, KYC queue, Vehicle verification, Load oversight, Audit logs, Health checks |
| **Automated Test Suite** | 🟢 **Complete (32/32 Passed)** | Full API integration test suite covering auth, RBAC, admin suite & health checks |
| **PostGIS Spatial Matching** | 🟡 **In Progress** | Schema & PostGIS extension config ready; corridor spatial matching algorithms pending |
| **Shipment Execution Engine** | 🟡 **In Progress** | Lifecycle defined in architecture; `shipments` table & OTP pickup/delivery transitions in progress |
| **Escrow & Payment Integration** | 🟡 **In Progress** | Payment ledger architecture mapped; Telebirr/Chapa API webhooks in progress |
| **Offline Sync & WebSockets** | ⚪ **Planned** | Offline queue sync endpoints and driver location broadcast planned |

---

## 🧪 API Test Suite & Verification Results

All API routes were verified against the live PostgreSQL + PostGIS database environment using the automated test suite (`src/__tests__/allRoutes.test.ts`).

- **Total Test Cases Executed:** `32`
- **Passed:** `32` (100% Pass Rate)
- **Failed:** `0`
- **Execution Time:** ~4.48s

### 🟢 Test Results Summary

| # | Test Scenario / Endpoint | HTTP Method & URI | Expected Status | Actual Status | Result |
| :---: | :--- | :--- | :---: | :---: | :---: |
| **1** | System Health Check | `GET /health` | `200 OK` | `200 OK` | ✅ **PASS** |
| **2** | User Registration | `POST /api/auth/register` | `201 Created` | `201 Created` | ✅ **PASS** |
| **3** | Duplicate Phone Validation | `POST /api/auth/register` | `409 Conflict` | `409 Conflict` | ✅ **PASS** |
| **4** | Phone OTP Verification | `POST /api/auth/verify-otp` | `200 OK` | `200 OK` | ✅ **PASS** |
| **5** | Invalid OTP Validation | `POST /api/auth/verify-otp` | `400 Bad Request` | `400 Bad Request` | ✅ **PASS** |
| **6** | User Login | `POST /api/auth/login` | `200 OK` | `200 OK` | ✅ **PASS** |
| **7** | Invalid Password Login Check | `POST /api/auth/login` | `401 Unauthorized` | `401 Unauthorized` | ✅ **PASS** |
| **8** | Admin Protection (Unauthenticated) | `GET /api/admin/dashboard` | `401 Unauthorized` | `401 Unauthorized` | ✅ **PASS** |
| **9** | Admin Protection (Non-Admin Role) | `GET /api/admin/dashboard` | `403 Forbidden` | `403 Forbidden` | ✅ **PASS** |
| **10** | Admin Dashboard Summary | `GET /api/admin/dashboard` | `200 OK` | `200 OK` | ✅ **PASS** |
| **11** | Admin User Directory | `GET /api/admin/users` | `200 OK` | `200 OK` | ✅ **PASS** |
| **12** | Admin User Profile Detail | `GET /api/admin/users/:id` | `200 OK` | `200 OK` | ✅ **PASS** |
| **13** | Admin Update User | `PATCH /api/admin/users/:id` | `200 OK` | `200 OK` | ✅ **PASS** |
| **14** | Admin Suspend User | `POST /api/admin/users/:id/suspend` | `200 OK` | `200 OK` | ✅ **PASS** |
| **15** | Admin Activate User | `POST /api/admin/users/:id/activate` | `200 OK` | `200 OK` | ✅ **PASS** |
| **16** | Admin KYC Queue Listing | `GET /api/admin/kyc` | `200 OK` | `200 OK` | ✅ **PASS** |
| **17** | Admin KYC Detail View | `GET /api/admin/kyc/:id` | `200 OK` | `200 OK` | ✅ **PASS** |
| **18** | Admin Approve KYC Request | `POST /api/admin/kyc/:id/approve` | `200 OK` | `200 OK` | ✅ **PASS** |
| **19** | Admin Reject KYC Request | `POST /api/admin/kyc/:id/reject` | `200 OK` | `200 OK` | ✅ **PASS** |
| **20** | Admin Vehicle Fleet Directory | `GET /api/admin/vehicles` | `200 OK` | `200 OK` | ✅ **PASS** |
| **21** | Admin Vehicle Record Detail | `GET /api/admin/vehicles/:id` | `200 OK` | `200 OK` | ✅ **PASS** |
| **22** | Admin Verify Vehicle | `POST /api/admin/vehicles/:id/verify` | `200 OK` | `200 OK` | ✅ **PASS** |
| **23** | Admin Reject Vehicle | `POST /api/admin/vehicles/:id/reject` | `200 OK` | `200 OK` | ✅ **PASS** |
| **24** | Admin Loads Listing | `GET /api/admin/loads` | `200 OK` | `200 OK` | ✅ **PASS** |
| **25** | Admin Load & Bids Detail | `GET /api/admin/loads/:id` | `200 OK` | `200 OK` | ✅ **PASS** |
| **26** | Admin Update Load Listing | `PATCH /api/admin/loads/:id` | `200 OK` | `200 OK` | ✅ **PASS** |
| **27** | Admin Shipments Oversight | `GET /api/admin/shipments` | `200 OK` | `200 OK` | ✅ **PASS** |
| **28** | Admin Escrow Ledger Oversight | `GET /api/admin/escrow` | `200 OK` | `200 OK` | ✅ **PASS** |
| **29** | Admin Transaction History | `GET /api/admin/transactions` | `200 OK` | `200 OK` | ✅ **PASS** |
| **30** | Admin Audit Logs | `GET /api/admin/audit-logs` | `200 OK` | `200 OK` | ✅ **PASS** |
| **31** | Admin Platform Analytics | `GET /api/admin/analytics` | `200 OK` | `200 OK` | ✅ **PASS** |
| **32** | Admin System Health Check | `GET /api/admin/system-health` | `200 OK` | `200 OK` | ✅ **PASS** |

---

## 🛠 Tech Stack & Dependencies

- **Language:** TypeScript 5.4
- **Runtime:** Node.js (v20+)
- **Framework:** Express.js 4.19
- **Database Layer:** PostgreSQL + PostGIS (via Knex.js query builder)
- **Authentication:** JWT (`jsonwebtoken`), Password Hashing (`bcryptjs`), OTP generation
- **Security:** Helmet, CORS, RBAC middleware
- **Development & Testing:** `ts-node-dev`, Node.js native test runner

---

## 📂 Project Directory Structure

```
Habesha_Freight/
├── docs/
│   └── admin-api.md             # Detailed documentation for Admin REST endpoints
├── prompt/                      # AI assistant context & prompts
├── src/
│   ├── __tests__/
│   │   ├── adminRoutes.test.ts  # Admin router unit test suite
│   │   └── allRoutes.test.ts    # Comprehensive 32-endpoint API verification suite
│   ├── config/
│   │   └── db.ts                # PostgreSQL & Knex configuration + PostGIS init
│   ├── controllers/
│   │   ├── adminController.ts   # Express route handlers for Admin features
│   │   └── authController.ts    # Express route handlers for User Auth & OTP
│   ├── database/
│   │   ├── migrations/          # Knex schema migrations (users, vehicles, loads, bids, audit_logs)
│   │   └── seeds/               # Initial demo seed data
│   ├── middleware/
│   │   ├── auth.ts              # Bearer JWT verification middleware
│   │   └── rbac.ts              # Role-based authorization middleware
│   ├── routes/
│   │   ├── adminRoutes.ts       # Admin routes definition (/api/admin/*)
│   │   └── authRoutes.ts        # Auth routes definition (/api/auth/*)
│   ├── services/
│   │   └── adminService.ts      # Core business logic layer for Admin Suite
│   ├── utils/
│   │   ├── crypto.ts            # Password hashing & OTP utilities
│   │   └── jwt.ts               # JWT token creation & verification
│   ├── app.ts                   # Express application setup & middleware stack
│   └── server.ts                # HTTP server bootstrap & DB readiness check
├── .env                         # Environment variables configuration
├── knexfile.ts                  # Knex configuration for dev, test, and production
├── package.json                 # Node dependencies and scripts
└── tsconfig.json                # TypeScript compiler configuration
```

---

## 📡 API Endpoint Overview

### 🔐 Authentication (`/api/auth`)
- `POST /api/auth/register` — Register new user (Shipper, Driver, Fleet Owner) and trigger OTP.
- `POST /api/auth/verify-otp` — Verify 6-digit phone OTP and receive JWT token.
- `POST /api/auth/login` — Authenticate existing user with phone number and password.

### 🛡️ Admin Operations (`/api/admin`) — *(Requires JWT + ADMIN role)*
- **Dashboard & Analytics:**
  - `GET /api/admin/dashboard` — Platform overview metrics & system counts.
  - `GET /api/admin/analytics` — Platform performance and load stats.
  - `GET /api/admin/system-health` — Health status of API, Database, and services.
- **User & KYC Management:**
  - `GET /api/admin/users` — Paginated user directory with filters.
  - `GET /api/admin/users/:id` — Detailed user profile.
  - `PATCH /api/admin/users/:id` — Update user details safely.
  - `POST /api/admin/users/:id/suspend` — Suspend active user account.
  - `POST /api/admin/users/:id/activate` — Reactivate user account.
  - `DELETE /api/admin/users/:id` — Soft-deactivate user account.
  - `GET /api/admin/kyc` — Verification queue.
  - `POST /api/admin/kyc/:id/approve` & `reject` — Review identity documents.
- **Vehicle Verification:**
  - `GET /api/admin/vehicles` — Vehicle fleet directory.
  - `POST /api/admin/vehicles/:id/verify` & `reject` — Manage vehicle compliance.
- **Marketplace Oversight:**
  - `GET /api/admin/loads` & `PATCH /api/admin/loads/:id` — Monitor and manage cargo listings.
  - `GET /api/admin/audit-logs` — Full administrative audit log view.

---

## 🗄️ Database Schema Summary

| Table | Description | Current Status |
| --- | --- | --- |
| `users` | User credentials, roles, status, OTP, and KYC status | 🟢 Active Migration |
| `vehicles` | Fleet assets, plate numbers, capacities, verification status | 🟢 Active Migration |
| `loads` | Cargo listings, origin/destination, weight, offered prices | 🟢 Active Migration |
| `bids` | Driver offers and price bids on cargo listings | 🟢 Active Migration |
| `audit_logs` | System security events and administrative actions | 🟢 Active Migration |
| `shipments` | Delivery execution states and OTP verifications | 🟡 Next Migration |
| `escrow_ledger` | Payment locks, releases, and escrow holds | 🟡 Next Migration |

---

## 👥 Team Role Division & Contribution Architecture

### ⚙️ Backend Team
- **Backend Dev 1 (Core Data, Auth & Geospatial Lead):**
  - Database schema & migration maintenance (`users`, `vehicles`, `loads`, `bids`, `audit_logs`).
  - Multi-factor OTP authentication, JWT token logic, password hashing, and RBAC guards.
  - PostGIS geospatial corridor indexing & spatial query matching.
- **Backend Dev 2 (Business Logic, State Machine & Financial Ledger Lead):**
  - Shipment lifecycle state machine (`POSTED` ➔ `MATCHED` ➔ `DISPATCHED` ➔ `DELIVERED`).
  - Escrow ledger, payment gateway webhooks (Telebirr, Chapa), and commission engine.
  - Sync endpoints for offline event queues and push notifications.

---

## 🚀 Getting Started

### 1. Prerequisites
- Node.js (v18+ or v20+)
- PostgreSQL server with PostGIS extension enabled

### 2. Environment Setup
Create a `.env` file in the root directory:
```env
PORT=5000
NODE_ENV=development
DB_HOST=localhost
DB_PORT=5432
DB_NAME=habesha_freight_db
DB_USER=postgres
DB_PASSWORD=postgres
JWT_SECRET=your_super_secret_jwt_key
```

### 3. Installation & Database Setup
```bash
# Install dependencies
npm install

# Run database migrations
npm run migrate

# Run database seeders (optional demo data)
npm run seed
```

### 4. Running the Application & Tests
```bash
# Start development server with auto-reload
npm run dev

# Type check the codebase
npx tsc --noEmit

# Execute full API test suite (32 endpoints verified)
npm test
```

---
*HabeshaFreight Core Backend API • Version 1.0.0 • Updated August 2026*
