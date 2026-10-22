# Habesha Freight — client ↔ API integration notes

## Canonical prefixes

| Domain | Prefer | Legacy alias |
|--------|--------|--------------|
| Drivers | `/api/drivers/*` | `/api/driver/*` (still mounted) |
| Company | `/api/company/*` | — |
| Shipper | `/api/shipper/*` | — |
| Escrow | `/api/escrow/*` | No `/escrow/withdraw` |
| Auth | `/api/auth/*` | — |

## Mobile

- `ApiConfig` lists shipper, drivers, escrow, tracking paths.
- `AuthGate` restores `GET /auth/me` and routes by role.
- Fleet mutations: accept / decline / assign fleet requests; escrow release is shipper/admin-only.

## Web frontend

- Logout calls `POST /auth/logout`.
- Company dashboard Accept/Decline hits fleet-request PATCH endpoints.
- Driver hooks use `/drivers/*`.
- Wallet does not call a non-existent withdraw endpoint.

## Design-only (no backend yet)

Mobile ops screens 35–40, fuel/toll, maintenance — UI/catalog only until APIs exist.
