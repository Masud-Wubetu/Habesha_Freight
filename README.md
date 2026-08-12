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

## 🚀 Future Roadmap
- **International Corridor:** Djibouti–Addis Ababa integration, including customs and dry-port documents.
- **IoT Integration:** GPS tracker hardware sync for automated geofencing.
- **Intelligent Matching:** Machine-learning-assisted load matching and dynamic pricing.
- **Localization:** Support for Afaan Oromo, Amharic, and regional dialects.

---
*Version 1.0 • August 2026*
