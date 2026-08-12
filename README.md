# HabeshaFreight — Digital Freight Marketplace

## 📌 Overview
HabeshaFreight is a digital freight marketplace designed for the operational realities of Ethiopian regional road transport. It connects verified shippers with verified drivers and fleet owners, replacing fragmented phone-based coordination and multi-layer broker chains with a controlled digital workflow. 

The initial platform focuses on the Addis Ababa corridor (including Adama, Hawassa, Bahir Dar, and Dire Dawa), with future plans to expand into the international Djibouti–Addis Ababa route.

## 🚀 The Problem Domain
HabeshaFreight targets five primary operational challenges in the region:
- **Information Gap:** Connecting available cargo with suitable nearby truck capacity.
- **Empty Backhauls:** Reducing empty return trips by matching vehicles with compatible loads on overlapping corridors.
- **Broker & Coordination Overheads:** Replacing manual phone coordination with a structured digital audit trail.
- **Trust & Verification:** Verifying users and vehicles while enforcing controlled delivery milestones.
- **Financial Assurance:** Securing payments using escrow and local payment gateways.

## 👥 Key Actors
- **Shipper:** Posts loads, compares bids, selects carriers, funds shipments, tracks progress, and rates carriers.
- **Driver:** Discovers loads, bids, executes trips, uses OTPs for pickup/delivery verification, and tracks earnings.
- **Fleet Owner:** Manages corporate fleet profiles, vehicles, driver assignments, and fleet revenue.
- **Administrator:** Manages KYC, resolves disputes, oversees escrow, handles exceptions, and monitors system health.

## 🔄 End-to-End Shipment Lifecycle
Every shipment follows a strict state machine to prevent arbitrary updates:
`POSTED` ➔ `MATCHED/ASSIGNED` ➔ `LOADED & DISPATCHED` ➔ `IN TRANSIT` ➔ `DELIVERED & VERIFIED`

- **Matching & Bidding:** Carriers bid on posted loads. The shipper reviews and selects a carrier.
- **Escrow Lock:** The shipper funds the shipment through a payment gateway (e.g., Chapa, Telebirr), locking the funds in escrow.
- **Pickup & Dispatch:** The driver uses a Pickup OTP. Only upon verification is the shipment marked as dispatched.
- **Tracking:** Drivers send real-time location and milestone updates (cached locally if offline).
- **Delivery & Payout:** Receiver provides a Delivery OTP. Upon successful verification, funds are released to the carrier and the platform commission is collected.

## 🛠 Core Systems & Architecture

### **Geospatial Corridor Matching**
Utilizes PostgreSQL with **PostGIS** to provide sub-300ms spatial queries. Matches loads based on corridor compatibility, distance, vehicle capacity, and carrier verification.

### **Escrow and Payment Architecture**
- Integrates with local gateways (Chapa, Telebirr, ArifPay).
- Maintains a ledger of all financial events (lock, release, dispute).
- Financial controls ensure funds are released only when the system verifies the Delivery OTP.

### **Security & Access Control**
- Role-Based Access Control (RBAC) enforced across API boundaries.
- Passwords hashed with Argon2/bcrypt. OTPs generated cryptographically.
- Data encrypted at rest (AES-256) and in transit (TLS 1.3).

### **Offline & Low-Bandwidth Support**
The mobile application handles intermittent connectivity by queuing location and event updates locally. Updates are synchronized with the backend once connection is restored, prioritizing the server timestamp as the source of truth.

## 🗄️ Example Database Schema
| Table | Responsibility |
| --- | --- |
| `users` | Identity, role, status, verification |
| `vehicles` | Fleet assets and certified capacity |
| `loads` | Freight demand and pickup requirements |
| `bids` | Carrier offers and negotiation |
| `shipments` | Execution state and OTP references |
| `escrow_ledger` | Payment and payout events |
| `audit_logs` | Security and administrative history |

## 👥 Team Role Division & GitHub Contribution Structure

### ⚙️ Backend Team (2 Developers)

#### 1. Backend Dev 1: Core Data, Auth & Geospatial Lead
- **Core Responsibilities:**
  - **Database & Data Layer:** Design relational database schema (`users`, `vehicles`, `loads`, `bids`, `audit_logs`) and setup migrations/seeders.
  - **Auth & Access Control:** Implement multi-factor OTP authentication, JWT token sessions, Argon2/bcrypt hashing, and RBAC middleware.
  - **Geospatial Engine:** Configure PostgreSQL + PostGIS spatial queries for route & radius matching under 300ms.
- **GitHub Contribution / Commit Prefixes:**
  - `feat(backend/auth)`: OTP, JWT, RBAC guards & session endpoints.
  - `feat(backend/db)`: Schema migrations, PostGIS spatial queries, database models.
  - `feat(backend/matching)`: Corridor matching & spatial query algorithms.

#### 2. Backend Dev 2: Business Logic, State Machine & Financial Ledger Lead
- **Core Responsibilities:**
  - **Shipment Lifecycle Engine:** Implement strict state machine transitions (`POSTED` ➔ `MATCHED` ➔ `DISPATCHED` ➔ `IN TRANSIT` ➔ `DELIVERED`).
  - **Escrow & Payment Architecture:** Integrate local payment gateways (Chapa, Telebirr, ArifPay), manage `escrow_ledger`, and OTP release triggers.
  - **Offline Sync & Notifications:** Develop sync endpoints for offline event queues and push notification/SMS hooks.
- **GitHub Contribution / Commit Prefixes:**
  - `feat(backend/shipment-state)`: State machine guards, OTP validation endpoints.
  - `feat(backend/escrow)`: Payment webhooks, escrow locking & payout release logic.
  - `feat(backend/sync)`: Offline queue sync controllers & WebSocket channels.

---

### 🎨 Frontend Team (3 Developers)

#### 1. Frontend Dev 1: Shipper & Fleet Owner Portal Lead
- **Core Responsibilities:**
  - **Shipper Portal:** Load posting wizard, bid comparison matrix, carrier selection UI, and shipment tracking dashboard.
  - **Fleet Workspace:** Fleet asset management, driver assignment modals, and revenue tracking table.
  - **Escrow Checkout UI:** Payment gateway trigger modals (Chapa/Telebirr) & digital receipt display.
- **GitHub Contribution / Commit Prefixes:**
  - `feat(frontend/shipper)`: Load creation wizard, carrier bidding UI.
  - `feat(frontend/fleet)`: Fleet management screens & driver assignment.
  - `feat(frontend/payment-ui)`: Escrow funding modal & receipt generator.

#### 2. Frontend Dev 2: Driver Mobile View & Offline Sync Lead
- **Core Responsibilities:**
  - **Driver Interface (Mobile View / PWA):** Load discovery feed, bid submission drawer, active trip view.
  - **Verification Flow:** Pickup OTP & Delivery OTP verification input views.
  - **Offline Resilience:** IndexedDB / LocalStorage queue management, offline indicator banner, background sync trigger.
- **GitHub Contribution / Commit Prefixes:**
  - `feat(frontend/driver)`: Load search feed, active trip navigation screen.
  - `feat(frontend/otp)`: Pickup/Delivery OTP verification components.
  - `feat(frontend/offline-cache)`: IndexedDB storage sync & offline banner.

#### 3. Frontend Dev 3: Admin Portal, Design System & App Infrastructure Lead
- **Core Responsibilities:**
  - **Admin Operations Dashboard:** KYC verification queue, dispute resolution panel, audit logs table, system health metrics.
  - **UI Component Library:** Reusable Tailwind / CSS UI kit (Modals, Tables, Status Badges, Maps integration wrappers).
  - **App Architecture:** App routing, navigation shell, role-based route protection, global state management (Auth/Notification context).
- **GitHub Contribution / Commit Prefixes:**
  - `feat(frontend/admin)`: Admin KYC review portal & dispute ticket UI.
  - `feat(frontend/design-system)`: Shared UI components & theme tokens.
  - `feat(frontend/core)`: Routing, app layout shell, auth state providers.

## 🚀 Future Roadmap
- **International Corridor:** Djibouti–Addis Ababa integration, including customs and dry-port documents.
- **IoT Integration:** GPS tracker hardware sync for automated geofencing.
- **Intelligent Matching:** Machine-learning-assisted load matching and dynamic pricing.
- **Localization:** Support for Afaan Oromo, Amharic, and regional dialects.

---
*Version 1.0 • August 2026*

