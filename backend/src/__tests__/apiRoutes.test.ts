import test from 'node:test';
import assert from 'node:assert/strict';
import type { AddressInfo } from 'node:net';
import { createApp } from '../app';
import db from '../config/db';
import { generateToken } from '../utils/jwt';

// ============================================================
// TYPES
// ============================================================

interface ApiResponse<T = unknown> {
  success: boolean;
  message: string;
  data?: T;
  error?: { code: string };
}

interface User {
  id: string;
  full_name: string;
  phone_number: string;
  email: string;
  role: string;
  is_verified: boolean;
  status: string;
  kyc_status: string;
  otp_code: string | null;
  otp_expires_at: string | null;
  created_at: string;
}

interface Load {
  id: string;
  shipper_id: string;
  cargo_description: string;
  weight_tons: number;
  origin_city: string;
  destination_city: string;
  status: string;
  offered_price_etb: number;
  created_at: string;
}

// ============================================================
// START SERVER
// ============================================================

async function startServer() {
  const app = createApp(db);
  const server = app.listen(0);

  await new Promise<void>((resolve) => {
    server.once('listening', () => resolve());
  });

  return server;
}

// ============================================================
// TEST SUITE
// ============================================================

test('API Route Verification Suite', async (t) => {
  const server = await startServer();
  const port = (server.address() as AddressInfo).port;
  const baseUrl = `http://127.0.0.1:${port}`;

  // Fetch an admin user from DB or generate token
  const adminUser = await db('users').where({ role: 'ADMIN' }).first() as User | undefined;
  const adminUserId = adminUser ? adminUser.id : '11111111-1111-4111-8111-111111111111';
  const adminToken = generateToken({
    userId: adminUserId,
    role: 'ADMIN',
    phoneNumber: adminUser ? adminUser.phone_number : '+251900000000',
  });

  const shipperUser = await db('users').where({ role: 'SHIPPER' }).first() as User | undefined;
  const shipperUserId = shipperUser ? shipperUser.id : '22222222-2222-4222-8222-222222222222';
  const shipperToken = generateToken({
    userId: shipperUserId,
    role: 'SHIPPER',
    phoneNumber: shipperUser ? shipperUser.phone_number : '+251911123456',
  });

  const vehicleRecord = await db('vehicles').first() as { id: string } | undefined;
  const vehicleId = vehicleRecord ? vehicleRecord.id : '33333333-3333-4333-8333-333333333333';

  const loadRecord = await db('loads').first() as Load | undefined;
  const loadId = loadRecord ? loadRecord.id : '44444444-4444-4444-8444-444444444444';

  const testPhoneNumber = `+25199${Math.floor(1000000 + Math.random() * 9000000)}`;

  // ============================================================
  // TEST 1: Health Check
  // ============================================================
  await t.test('1. Health Check Endpoint (GET /health)', async () => {
    const res = await fetch(`${baseUrl}/health`);
    const data = (await res.json()) as ApiResponse;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 2: User Registration
  // ============================================================
  await t.test('2. User Registration (POST /api/auth/register)', async () => {
    const res = await fetch(`${baseUrl}/api/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        full_name: 'Test Carrier User',
        phone_number: testPhoneNumber,
        password: 'Password123!',
        role: 'DRIVER',
      }),
    });
    const data = (await res.json()) as ApiResponse;
    assert.equal(res.status, 201);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 3: Duplicate Registration
  // ============================================================
  await t.test('3. User Registration Duplicate Check (POST /api/auth/register)', async () => {
    const res = await fetch(`${baseUrl}/api/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        full_name: 'Test Carrier User',
        phone_number: testPhoneNumber,
        password: 'Password123!',
        role: 'DRIVER',
      }),
    });
    const data = (await res.json()) as ApiResponse;
    assert.equal(res.status, 409);
    assert.equal(data.success, false);
  });

  // ============================================================
  // TEST 4: OTP Verification
  // ============================================================
  await t.test('4. Phone OTP Verification (POST /api/auth/verify-otp)', async () => {
    const createdUser = await db('users').where({ phone_number: testPhoneNumber }).first() as User | undefined;
    const otpCode = createdUser ? createdUser.otp_code : '123456';

    const res = await fetch(`${baseUrl}/api/auth/verify-otp`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        phone_number: testPhoneNumber,
        otp_code: otpCode,
      }),
    });
    const data = (await res.json()) as ApiResponse;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 5: Invalid OTP
  // ============================================================
  await t.test('5. Invalid OTP Verification Check (POST /api/auth/verify-otp)', async () => {
    const res = await fetch(`${baseUrl}/api/auth/verify-otp`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        phone_number: testPhoneNumber,
        otp_code: '000000',
      }),
    });
    const data = (await res.json()) as ApiResponse;
    assert.equal(res.status, 400);
    assert.equal(data.success, false);
  });

  // ============================================================
  // TEST 6: User Login
  // ============================================================
  await t.test('6. User Login Endpoint (POST /api/auth/login)', async () => {
    const res = await fetch(`${baseUrl}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        phone_number: testPhoneNumber,
        password: 'Password123!',
      }),
    });
    const data = (await res.json()) as ApiResponse<{ token: string; user: User }>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
    assert.ok(data.data?.token);
  });

  // ============================================================
  // TEST 7: Invalid Login
  // ============================================================
  await t.test('7. User Login Invalid Password Check (POST /api/auth/login)', async () => {
    const res = await fetch(`${baseUrl}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        phone_number: testPhoneNumber,
        password: 'WrongPassword!',
      }),
    });
    const data = (await res.json()) as ApiResponse;
    assert.equal(res.status, 401);
    assert.equal(data.success, false);
  });

  // ============================================================
  // TEST 8: Unauthenticated Admin Access
  // ============================================================
  await t.test('8. Admin Protection - Unauthenticated Request (GET /api/admin/dashboard)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/dashboard`);
    const data = (await res.json()) as ApiResponse;
    assert.equal(res.status, 401);
    assert.equal(data.success, false);
  });

  // ============================================================
  // TEST 9: Non-Admin Access Denied
  // ============================================================
  await t.test('9. Admin Protection - Non-Admin Role (GET /api/admin/dashboard)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/dashboard`, {
      headers: { Authorization: `Bearer ${shipperToken}` },
    });
    const data = (await res.json()) as ApiResponse;
    assert.equal(res.status, 403);
    assert.equal(data.success, false);
  });

  // ============================================================
  // TEST 10: Admin Dashboard
  // ============================================================
  await t.test('10. Admin Dashboard Summary (GET /api/admin/dashboard)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/dashboard`, {
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    const data = (await res.json()) as ApiResponse;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 11: Admin User Directory
  // ============================================================
  await t.test('11. Admin User Directory Listing (GET /api/admin/users)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/users?page=1&limit=10`, {
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    const data = (await res.json()) as ApiResponse<{
      users: User[];
      pagination: { page: number; limit: number; total: number; totalPages: number };
    }>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
    assert.ok(data.data?.pagination);
  });

  // ============================================================
  // TEST 12: Admin User Detail
  // ============================================================
  await t.test('12. Admin Single User Detail (GET /api/admin/users/:id)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/users/${adminUserId}`, {
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    const data = (await res.json()) as ApiResponse<{ user: User }>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
    assert.ok(data.data?.user);
  });

  // ============================================================
  // TEST 13: Admin Update User
  // ============================================================
  await t.test('13. Admin Update User (PATCH /api/admin/users/:id)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/users/${shipperUserId}`, {
      method: 'PATCH',
      headers: {
        Authorization: `Bearer ${adminToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ full_name: 'Abebe Bikila Logistics Updated' }),
    });
    const data = (await res.json()) as ApiResponse<{ user: User }>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 13b: Admin Update User Role
  // ============================================================
  await t.test('13b. Admin Update User Role (PATCH /api/admin/users/:id/role)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/users/${shipperUserId}/role`, {
      method: 'PATCH',
      headers: {
        Authorization: `Bearer ${adminToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ role: 'SHIPPER' }),
    });
    const data = (await res.json()) as ApiResponse<{ user: User }>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 14: Admin Suspend User
  // ============================================================
  await t.test('14. Admin Suspend User (POST /api/admin/users/:id/suspend)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/users/${shipperUserId}/suspend`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    const data = (await res.json()) as ApiResponse<{ user: User }>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 15: Admin Activate User
  // ============================================================
  await t.test('15. Admin Activate User (POST /api/admin/users/:id/activate)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/users/${shipperUserId}/activate`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    const data = (await res.json()) as ApiResponse<{ user: User }>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 16: Admin KYC Queue
  // ============================================================
  await t.test('16. Admin KYC Queue (GET /api/admin/kyc)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/kyc`, {
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    const data = (await res.json()) as ApiResponse<{
      users: User[];
      pagination: { page: number; limit: number; total: number; totalPages: number };
    }>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 17: Admin KYC Detail
  // ============================================================
  await t.test('17. Admin KYC Detail (GET /api/admin/kyc/:id)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/kyc/${shipperUserId}`, {
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    const data = (await res.json()) as ApiResponse<{ user: User }>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 18: Admin Approve KYC
  // ============================================================
  await t.test('18. Admin Approve KYC (POST /api/admin/kyc/:id/approve)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/kyc/${shipperUserId}/approve`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    const data = (await res.json()) as ApiResponse<{ user: User }>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 19: Admin Reject KYC
  // ============================================================
  await t.test('19. Admin Reject KYC (POST /api/admin/kyc/:id/reject)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/kyc/${shipperUserId}/reject`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${adminToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ reason: 'Documents unreadable' }),
    });
    const data = (await res.json()) as ApiResponse<{ user: User }>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 20: Admin Vehicle List
  // ============================================================
  await t.test('20. Admin Vehicle List (GET /api/admin/vehicles)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/vehicles`, {
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    const data = (await res.json()) as ApiResponse<{
      vehicles: Record<string, unknown>[];
      pagination: { page: number; limit: number; total: number; totalPages: number };
    }>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 21: Admin Vehicle Detail
  // ============================================================
  await t.test('21. Admin Vehicle Detail (GET /api/admin/vehicles/:id)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/vehicles/${vehicleId}`, {
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    const data = (await res.json()) as ApiResponse<{ vehicle: Record<string, unknown> }>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 22: Admin Verify Vehicle
  // ============================================================
  await t.test('22. Admin Verify Vehicle (POST /api/admin/vehicles/:id/verify)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/vehicles/${vehicleId}/verify`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    const data = (await res.json()) as ApiResponse<{ vehicle: Record<string, unknown> }>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 23: Admin Reject Vehicle
  // ============================================================
  await t.test('23. Admin Reject Vehicle (POST /api/admin/vehicles/:id/reject)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/vehicles/${vehicleId}/reject`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${adminToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ reason: 'Expired LIB' }),
    });
    const data = (await res.json()) as ApiResponse<{ vehicle: Record<string, unknown> }>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 24: Admin Loads List
  // ============================================================
  await t.test('24. Admin Loads List (GET /api/admin/loads)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/loads`, {
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    const data = (await res.json()) as ApiResponse<{
      loads: Record<string, unknown>[];
      pagination: { page: number; limit: number; total: number; totalPages: number };
    }>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 25: Admin Load Detail
  // ============================================================
  await t.test('25. Admin Load Detail (GET /api/admin/loads/:id)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/loads/${loadId}`, {
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    const data = (await res.json()) as ApiResponse<{ load: Record<string, unknown> }>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 26: Admin Update Load
  // ============================================================
  await t.test('26. Admin Update Load (PATCH /api/admin/loads/:id)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/loads/${loadId}`, {
      method: 'PATCH',
      headers: {
        Authorization: `Bearer ${adminToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ offered_price_etb: 48000 }),
    });
    const data = (await res.json()) as ApiResponse<{ load: Record<string, unknown> }>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 27: Admin Shipments (501 stub)
  // ============================================================
  await t.test('27. Admin Shipments (GET /api/admin/shipments)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/shipments`, {
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    assert.equal(res.status === 200 || res.status === 501, true);
  });

  // ============================================================
  // TEST 28: Admin Escrow Ledger (501 stub)
  // ============================================================
  await t.test('28. Admin Escrow Ledger (GET /api/admin/escrow)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/escrow`, {
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    assert.equal(res.status === 200 || res.status === 501, true);
  });

  // ============================================================
  // TEST 29: Admin Transactions (501 stub)
  // ============================================================
  await t.test('29. Admin Transactions (GET /api/admin/transactions)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/transactions`, {
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    assert.equal(res.status === 200 || res.status === 501, true);
  });

  // ============================================================
  // TEST 30: Admin Audit Logs
  // ============================================================
  await t.test('30. Admin Audit Logs (GET /api/admin/audit-logs)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/audit-logs`, {
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    const data = (await res.json()) as ApiResponse<{
      auditLogs: Record<string, unknown>[];
      pagination: { page: number; limit: number; total: number; totalPages: number };
    }>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 31: Admin Platform Analytics
  // ============================================================
  await t.test('31. Admin Platform Analytics (GET /api/admin/analytics)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/analytics`, {
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    const data = (await res.json()) as ApiResponse<Record<string, unknown>>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  // ============================================================
  // TEST 32: Admin System Health
  // ============================================================
  await t.test('32. Admin System Health (GET /api/admin/system-health)', async () => {
    const res = await fetch(`${baseUrl}/api/admin/system-health`, {
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    const data = (await res.json()) as ApiResponse<Record<string, unknown>>;
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
  });

  server.close();
});