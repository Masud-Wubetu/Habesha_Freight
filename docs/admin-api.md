# HabeshaFreight Admin API

Base path: `/api/admin`

Authentication: required via Bearer JWT.
Required role: `ADMIN`.

## Common behavior

All admin endpoints return a consistent payload format:

Success:

```json
{
  "success": true,
  "message": "Users retrieved successfully.",
  "data": {}
}
```

Error:

```json
{
  "success": false,
  "message": "User not found.",
  "error": {
    "code": "USER_NOT_FOUND"
  }
}
```

## GET /api/admin/dashboard

- Authentication: required
- Role: `ADMIN`
- Query: none
- Response: summary counts for `users`, `vehicles`, `loads`, and a clear `not configured` payload for tables not yet implemented in the current schema.

## GET /api/admin/users

- Authentication: required
- Role: `ADMIN`
- Query: `page`, `limit`, `search`, `role`, `status`, `sortBy`, `sortOrder`
- Response: `{ users, pagination }`

## GET /api/admin/users/:id

- Authentication: required
- Role: `ADMIN`
- Response: full user record without password hashes, OTP data, or tokens.

## PATCH /api/admin/users/:id

- Authentication: required
- Role: `ADMIN`
- Body: permitted admin update fields such as `full_name`, `email`, `phone_number`, `role`, `status`, `kyc_status`
- Response: updated user
- Sensitive fields rejected: `password_hash`, `otp_code`, `otp_expires_at`, tokens

## POST /api/admin/users/:id/suspend

- Authentication: required
- Role: `ADMIN`
- Response: suspended user record

## POST /api/admin/users/:id/activate

- Authentication: required
- Role: `ADMIN`
- Response: activated user record

## DELETE /api/admin/users/:id

- Authentication: required
- Role: `ADMIN`
- Response: user deactivated safely without hard deletion to preserve historical records.

## GET /api/admin/kyc

- Authentication: required
- Role: `ADMIN`
- Query: `page`, `limit`, `status`, `role`
- Response: KYC queue built from the current schema; if `kyc_status` is not present, it falls back to the user verification state.

## GET /api/admin/kyc/:id

- Authentication: required
- Role: `ADMIN`
- Response: KYC details mapped from the existing user model.

## POST /api/admin/kyc/:id/approve

- Authentication: required
- Role: `ADMIN`
- Body: optional `reason`
- Response: approved user verification state

## POST /api/admin/kyc/:id/reject

- Authentication: required
- Role: `ADMIN`
- Body: required `reason`
- Response: rejected KYC update

## GET /api/admin/vehicles

- Authentication: required
- Role: `ADMIN`
- Query: `page`, `limit`, `search`, `verification`, `owner`, `vehicleType`
- Response: paginated vehicle list

## GET /api/admin/vehicles/:id

- Authentication: required
- Role: `ADMIN`
- Response: vehicle details

## POST /api/admin/vehicles/:id/verify

- Authentication: required
- Role: `ADMIN`
- Response: verification status update

## POST /api/admin/vehicles/:id/reject

- Authentication: required
- Role: `ADMIN`
- Body: optional `reason`
- Response: rejection update

## GET /api/admin/loads

- Authentication: required
- Role: `ADMIN`
- Query: `page`, `limit`, `status`, `origin`, `destination`, `shipper`, `from`, `to`
- Response: paginated loads

## GET /api/admin/loads/:id

- Authentication: required
- Role: `ADMIN`
- Response: full load record and associated bids when available

## PATCH /api/admin/loads/:id

- Authentication: required
- Role: `ADMIN`
- Body: limited administrative updates such as `status`, `cargo_description`, `weight_tons`, `origin_city`, `destination_city`, `offered_price_etb`

## GET /api/admin/shipments

- Authentication: required
- Role: `ADMIN`
- Response: empty list with clear schema warning when shipment tracking is not yet implemented.

## GET /api/admin/shipments/:id

- Authentication: required
- Role: `ADMIN`
- Response: same schema warning when the table is not configured.

## PATCH /api/admin/shipments/:id

- Authentication: required
- Role: `ADMIN`
- Response: same schema warning unless a shipment table is present.

## GET /api/admin/escrow

- Authentication: required
- Role: `ADMIN`
- Response: empty list with clear message if `escrow_ledger` is not configured.

## GET /api/admin/transactions

- Authentication: required
- Role: `ADMIN`
- Response: empty list with clear message if `transactions` is not configured.

## GET /api/admin/commissions

- Authentication: required
- Role: `ADMIN`
- Response: empty list with clear message if `commission_ledger` is not configured.

## GET /api/admin/disputes

- Authentication: required
- Role: `ADMIN`
- Response: empty list with clear message if `disputes` is not configured.

## GET /api/admin/disputes/:id

- Authentication: required
- Role: `ADMIN`
- Response: empty list or a schema warning if `disputes` is not configured.

## POST /api/admin/disputes/:id/resolve

- Authentication: required
- Role: `ADMIN`
- Response: dispute resolution update when the table exists.

## POST /api/admin/disputes/:id/reject

- Authentication: required
- Role: `ADMIN`
- Response: dispute rejection update when the table exists.

## GET /api/admin/audit-logs

- Authentication: required
- Role: `ADMIN`
- Query: `page`, `limit`, `userId`, `action`
- Response: log list with actor IDs, actions, target type, target ID, metadata, and IP address when present.

## GET /api/admin/analytics

- Authentication: required
- Role: `ADMIN`
- Query: `from`, `to`
- Response: simple aggregate data from `users` and `loads` tables.

## GET /api/admin/system-health

- Authentication: required
- Role: `ADMIN`
- Response example:

```json
{
  "success": true,
  "data": {
    "api": "healthy",
    "database": "healthy",
    "redis": "not configured",
    "socketIo": "not configured",
    "paymentGateway": "not configured"
  }
}
```
