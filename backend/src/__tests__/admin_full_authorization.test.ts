import test from 'node:test';
import assert from 'node:assert/strict';
import express from 'express';
import type { AddressInfo } from 'node:net';
import { createAdminRouter } from '../routes/adminRoutes';
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
  password_hash: string;
  otp_code: string | null;
  otp_expires_at: string | null;
  created_at: string;
}

interface Vehicle {
  id: string;
  driver_id: string;
  plate_number: string;
  vehicle_type: string;
  capacity_tons: number;
  is_active: boolean;
  verification_status: string;
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

interface AuditLog {
  id: string;
  user_id: string;
  action: string;
  ip_address: string;
  details: Record<string, unknown>;
  created_at: string;
}

interface Shipment {
  id: string;
  status: string;
  created_at: string;
}

interface Dispute {
  id: string;
  status: string;
  created_at: string;
}

// ============================================================
// FAKE DATABASE
// ============================================================

function createFakeDb() {
  const users: User[] = [
    {
      id: '11111111-1111-4111-8111-111111111111',
      full_name: 'Admin User 1',
      phone_number: '+251900000001',
      email: 'admin1@habeshafreight.et',
      role: 'ADMIN',
      is_verified: true,
      status: 'ACTIVE',
      kyc_status: 'APPROVED',
      password_hash: 'hashed_password',
      otp_code: null,
      otp_expires_at: null,
      created_at: new Date().toISOString(),
    },
    {
      id: '99999999-9999-4999-8999-999999999999',
      full_name: 'Admin User 2',
      phone_number: '+251900000002',
      email: 'admin2@habeshafreight.et',
      role: 'ADMIN',
      is_verified: true,
      status: 'ACTIVE',
      kyc_status: 'APPROVED',
      password_hash: 'hashed_password',
      otp_code: null,
      otp_expires_at: null,
      created_at: new Date().toISOString(),
    },
    {
      id: '22222222-2222-4222-8222-222222222222',
      full_name: 'Shipper User',
      phone_number: '+251911111111',
      email: 'shipper@habeshafreight.et',
      role: 'SHIPPER',
      is_verified: true,
      status: 'ACTIVE',
      kyc_status: 'APPROVED',
      password_hash: 'hashed_password',
      otp_code: null,
      otp_expires_at: null,
      created_at: new Date().toISOString(),
    },
    {
      id: '66666666-6666-4666-8666-666666666666',
      full_name: 'Driver User',
      phone_number: '+251922222222',
      email: 'driver@habeshafreight.et',
      role: 'DRIVER',
      is_verified: true,
      status: 'ACTIVE',
      kyc_status: 'APPROVED',
      password_hash: 'hashed_password',
      otp_code: null,
      otp_expires_at: null,
      created_at: new Date().toISOString(),
    },
    {
      id: '77777777-7777-4777-8777-777777777777',
      full_name: 'Fleet Owner',
      phone_number: '+251933333333',
      email: 'fleet@habeshafreight.et',
      role: 'FLEET_OWNER',
      is_verified: true,
      status: 'ACTIVE',
      kyc_status: 'APPROVED',
      password_hash: 'hashed_password',
      otp_code: null,
      otp_expires_at: null,
      created_at: new Date().toISOString(),
    },
    {
      id: '88888888-8888-4888-8888-888888888888',
      full_name: 'Pending KYC User',
      phone_number: '+251944444444',
      email: 'pending@habeshafreight.et',
      role: 'DRIVER',
      is_verified: false,
      status: 'ACTIVE',
      kyc_status: 'PENDING',
      password_hash: 'hashed_password',
      otp_code: null,
      otp_expires_at: null,
      created_at: new Date().toISOString(),
    },
  ];

  const vehicles: Vehicle[] = [
    {
      id: '33333333-3333-4333-8333-333333333333',
      driver_id: users[3].id,
      plate_number: 'ET-3-45892',
      vehicle_type: 'SINO_TRUCK',
      capacity_tons: 25,
      is_active: true,
      verification_status: 'PENDING',
      created_at: new Date().toISOString(),
    },
    {
      id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      driver_id: users[3].id,
      plate_number: 'ET-4-12345',
      vehicle_type: 'ISUZU_DRY',
      capacity_tons: 15,
      is_active: true,
      verification_status: 'VERIFIED',
      created_at: new Date().toISOString(),
    },
  ];

  const loads: Load[] = [
    {
      id: '44444444-4444-4444-8444-444444444444',
      shipper_id: users[2].id,
      cargo_description: 'Construction cement',
      weight_tons: 15,
      origin_city: 'Addis Ababa',
      destination_city: 'Hawassa',
      status: 'POSTED',
      offered_price_etb: 42000,
      created_at: new Date().toISOString(),
    },
  ];

  const disputes: Dispute[] = [
    {
      id: 'ffffffff-ffff-4fff-8fff-ffffffffffff',
      status: 'OPEN',
      created_at: new Date().toISOString(),
    },
  ];

  const shipments: Shipment[] = [
    {
      id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      status: 'IN_TRANSIT',
      created_at: new Date().toISOString(),
    },
  ];

  const auditLogs: AuditLog[] = [
    {
      id: '55555555-5555-4555-8555-555555555555',
      user_id: users[0].id,
      action: 'USER_UPDATED',
      ip_address: '127.0.0.1',
      details: { updatedFields: ['full_name'] },
      created_at: new Date().toISOString(),
    },
  ];

  // Use Record<string, unknown>[] for all tables
  const tableData: Record<string, Record<string, unknown>[]> = {
    users: users.map(u => u as unknown as Record<string, unknown>),
    vehicles: vehicles.map(v => v as unknown as Record<string, unknown>),
    loads: loads.map(l => l as unknown as Record<string, unknown>),
    bids: [],
    audit_logs: auditLogs.map(a => a as unknown as Record<string, unknown>),
    shipments: shipments.map(s => s as unknown as Record<string, unknown>),
    disputes: disputes.map(d => d as unknown as Record<string, unknown>),
    escrow_ledger: [],
    transactions: [],
    commission_ledger: [],
  };

  const columns: Record<string, Record<string, boolean>> = {
    users: {
      status: true,
      kyc_status: true,
      password_hash: true,
      otp_code: true,
      otp_expires_at: true,
    },
    vehicles: { verification_status: true },
    audit_logs: { target_type: true, target_id: true },
    loads: {},
    bids: {},
    shipments: {},
    disputes: {},
    escrow_ledger: {},
    transactions: {},
    commission_ledger: {},
  };

  const createQueryBuilder = (tableName: string) => {
    const getRows = (): Record<string, unknown>[] => {
      let rows = tableData[tableName] || [];
      if (tableName === 'users') {
        rows = rows.filter((row: Record<string, unknown>) => row.status !== 'DELETED');
      }
      return rows;
    };

    const queryBuilder = {
      where: function (condition: Record<string, unknown> | string, value?: unknown) {
        const rows = getRows();
        let filtered = rows;
        if (typeof condition === 'object') {
          for (const [key, val] of Object.entries(condition)) {
            filtered = filtered.filter((row: Record<string, unknown>) => row[key] === val);
          }
        } else if (typeof condition === 'string' && value !== undefined) {
          filtered = filtered.filter((row: Record<string, unknown>) => row[condition] === value);
        }
        return {
          ...queryBuilder,
          _rows: filtered,
          then: function (resolve: (value: Record<string, unknown>[]) => void) {
            resolve(filtered);
          },
          first: async function (): Promise<Record<string, unknown> | undefined> {
            return filtered.length > 0 ? filtered[0] : undefined;
          },
          count: function () {
            return {
              first: async () => ({ count: String(filtered.length) }),
            };
          },
        };
      },
      whereILike: function (field: string, pattern: string) {
        const rows = getRows();
        const filtered = rows.filter((row: Record<string, unknown>) => {
          const val = String(row[field] || '').toLowerCase();
          const search = pattern.toLowerCase().replace(/%/g, '');
          return val.includes(search);
        });
        return {
          ...queryBuilder,
          _rows: filtered,
          then: function (resolve: (value: Record<string, unknown>[]) => void) {
            resolve(filtered);
          },
          first: async function (): Promise<Record<string, unknown> | undefined> {
            return filtered.length > 0 ? filtered[0] : undefined;
          },
          count: function () {
            return {
              first: async () => ({ count: String(filtered.length) }),
            };
          },
        };
      },
      whereNull: function (field: string) {
        const rows = getRows();
        const filtered = rows.filter((row: Record<string, unknown>) => row[field] === null || row[field] === undefined);
        return {
          ...queryBuilder,
          _rows: filtered,
          then: function (resolve: (value: Record<string, unknown>[]) => void) {
            resolve(filtered);
          },
          first: async function (): Promise<Record<string, unknown> | undefined> {
            return filtered.length > 0 ? filtered[0] : undefined;
          },
          count: function () {
            return {
              first: async () => ({ count: String(filtered.length) }),
            };
          },
        };
      },
      whereNot: function (field: string, value: unknown) {
        const rows = getRows();
        const filtered = rows.filter((row: Record<string, unknown>) => row[field] !== value);
        return {
          ...queryBuilder,
          _rows: filtered,
          then: function (resolve: (value: Record<string, unknown>[]) => void) {
            resolve(filtered);
          },
          first: async function (): Promise<Record<string, unknown> | undefined> {
            return filtered.length > 0 ? filtered[0] : undefined;
          },
          count: function () {
            return {
              first: async () => ({ count: String(filtered.length) }),
            };
          },
        };
      },
      whereIn: function (field: string, values: unknown[]) {
        if (values.length === 0) return queryBuilder;
        const rows = getRows();
        const filtered = rows.filter((row: Record<string, unknown>) => values.includes(row[field]));
        return {
          ...queryBuilder,
          _rows: filtered,
          then: function (resolve: (value: Record<string, unknown>[]) => void) {
            resolve(filtered);
          },
          first: async function (): Promise<Record<string, unknown> | undefined> {
            return filtered.length > 0 ? filtered[0] : undefined;
          },
          count: function () {
            return {
              first: async () => ({ count: String(filtered.length) }),
            };
          },
        };
      },
      orderBy: function (field: string, direction: 'asc' | 'desc' = 'desc') {
        const rows = getRows();
        const sorted = [...rows].sort((a: Record<string, unknown>, b: Record<string, unknown>) => {
          const aVal = String(a[field] || '');
          const bVal = String(b[field] || '');
          if (direction === 'asc') {
            return aVal > bVal ? 1 : -1;
          } else {
            return aVal < bVal ? 1 : -1;
          }
        });
        return {
          ...queryBuilder,
          _rows: sorted,
          then: function (resolve: (value: Record<string, unknown>[]) => void) {
            resolve(sorted);
          },
          first: async function (): Promise<Record<string, unknown> | undefined> {
            return sorted.length > 0 ? sorted[0] : undefined;
          },
          count: function () {
            return {
              first: async () => ({ count: String(sorted.length) }),
            };
          },
        };
      },
      offset: function (value: number) {
        const rows = getRows();
        const sliced = rows.slice(value);
        return {
          ...queryBuilder,
          _rows: sliced,
          then: function (resolve: (value: Record<string, unknown>[]) => void) {
            resolve(sliced);
          },
          first: async function (): Promise<Record<string, unknown> | undefined> {
            return sliced.length > 0 ? sliced[0] : undefined;
          },
          count: function () {
            return {
              first: async () => ({ count: String(sliced.length) }),
            };
          },
        };
      },
      limit: function (value: number) {
        const rows = getRows();
        const sliced = rows.slice(0, value);
        return {
          ...queryBuilder,
          _rows: sliced,
          then: function (resolve: (value: Record<string, unknown>[]) => void) {
            resolve(sliced);
          },
          first: async function (): Promise<Record<string, unknown> | undefined> {
            return sliced.length > 0 ? sliced[0] : undefined;
          },
          count: function () {
            return {
              first: async () => ({ count: String(sliced.length) }),
            };
          },
        };
      },
      clone: function () {
        return this;
      },
      select: function (..._fields: string[]) {
        return this;
      },
      groupBy: function (..._fields: string[]) {
        return this;
      },
      count: function (_field: string = '*') {
        const rows = getRows();
        return {
          first: async (): Promise<{ count: string }> => ({
            count: String(rows.length),
          }),
        };
      },
      columnInfo: async (): Promise<Record<string, boolean>> => columns[tableName] || {},
      first: async function (): Promise<Record<string, unknown> | undefined> {
        const rows = getRows();
        return rows.length > 0 ? rows[0] : undefined;
      },
      then: function (resolve: (value: Record<string, unknown>[]) => void) {
        const rows = getRows();
        resolve(rows);
      },
      insert: async function (data: Record<string, unknown>): Promise<Record<string, unknown>[]> {
        const newRow = { ...data, id: `new-${Date.now()}` };
        if (tableData[tableName]) {
          tableData[tableName].push(newRow);
        }
        return [newRow];
      },
      update: async function (data: Record<string, unknown>): Promise<number> {
        const rows = getRows();
        let count = 0;
        for (const row of rows) {
          Object.assign(row, data);
          count++;
        }
        return count;
      },
    };

    return queryBuilder;
  };

  const db = (tableName: string) => createQueryBuilder(tableName);

  (db as any).schema = {
    hasTable: async (table: string): Promise<boolean> => {
      return tableData[table] !== undefined;
    },
  };

  (db as any).raw = async (): Promise<Array<{ result: number }>> => {
    return [{ result: 1 }];
  };

  (db as any).transaction = async <T>(cb: (trx: any) => Promise<T>): Promise<T> => {
    return await cb(db);
  };

  return db;
}

async function startTestServer(fakeDb: any) {
  const app = express();
  app.use(express.json());
  app.use('/api/admin', createAdminRouter(fakeDb));
  const server = app.listen(0);

  await new Promise<void>((resolve) => {
    server.once('listening', () => resolve());
  });

  return server;
}

// ============================================================
// TEST HELPERS
// ============================================================

const ADMIN = { userId: '11111111-1111-4111-8111-111111111111', role: 'ADMIN' as const, phoneNumber: '+251900000001' };
const SHIPPER = { userId: '22222222-2222-4222-8222-222222222222', role: 'SHIPPER' as const, phoneNumber: '+251911111111' };
const DRIVER = { userId: '66666666-6666-4666-8666-666666666666', role: 'DRIVER' as const, phoneNumber: '+251922222222' };
const FLEET = { userId: '77777777-7777-4777-8777-777777777777', role: 'FLEET_OWNER' as const, phoneNumber: '+251933333333' };

function makeRequest(port: number, method: string, path: string, token?: string, body?: any) {
  const url = `http://127.0.0.1:${port}/api/admin${path}`;
  const opts: any = { method, headers: {} };
  if (token) opts.headers.Authorization = `Bearer ${token}`;
  if (body) {
    opts.headers['Content-Type'] = 'application/json';
    opts.body = JSON.stringify(body);
  }
  return fetch(url, opts);
}

async function parseResponse(res: Response): Promise<ApiResponse> {
  try {
    const data = await res.json();
    return data as ApiResponse;
  } catch {
    return { success: false, message: 'Invalid JSON response' };
  }
}

// ============================================================
// ENDPOINT DEFINITIONS - All working endpoints with fake DB
// ============================================================

const endpoints = [
  // Dashboard
  { method: 'GET', path: '/dashboard' },
  // Users
  { method: 'GET', path: '/users' },
  { method: 'GET', path: '/users/11111111-1111-4111-8111-111111111111' },
  { method: 'PATCH', path: '/users/11111111-1111-4111-8111-111111111111', body: { full_name: 'Admin Updated' } },
  { method: 'PATCH', path: '/users/11111111-1111-4111-8111-111111111111/role', body: { role: 'SHIPPER' } },
  { method: 'POST', path: '/users/11111111-1111-4111-8111-111111111111/suspend' },
  { method: 'POST', path: '/users/11111111-1111-4111-8111-111111111111/activate' },
  { method: 'DELETE', path: '/users/11111111-1111-4111-8111-111111111111' },
  // KYC
  { method: 'GET', path: '/kyc' },
  { method: 'GET', path: '/kyc/11111111-1111-4111-8111-111111111111' },
  { method: 'POST', path: '/kyc/11111111-1111-4111-8111-111111111111/approve' },
  { method: 'POST', path: '/kyc/22222222-2222-4222-8222-222222222222/reject', body: { reason: 'Invalid docs' } },
  // Vehicles
  { method: 'GET', path: '/vehicles' },
  { method: 'GET', path: '/vehicles/33333333-3333-4333-8333-333333333333' },
  { method: 'POST', path: '/vehicles/33333333-3333-4333-8333-333333333333/verify' },
  { method: 'POST', path: '/vehicles/33333333-3333-4333-8333-333333333333/reject', body: { reason: 'Docs missing' } },
  // Loads
  { method: 'GET', path: '/loads' },
  { method: 'GET', path: '/loads/44444444-4444-4444-8444-444444444444' },
  { method: 'PATCH', path: '/loads/44444444-4444-4444-8444-444444444444', body: { status: 'CANCELLED' } },
  // Shipments (501 stubs - should pass)
  { method: 'GET', path: '/shipments' },
  { method: 'GET', path: '/shipments/aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa' },
  { method: 'PATCH', path: '/shipments/aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', body: { status: 'DELIVERED' } },
  // Financials (501 stubs)
  { method: 'GET', path: '/escrow' },
  { method: 'GET', path: '/transactions' },
  { method: 'GET', path: '/commissions' },
  // Disputes
  { method: 'GET', path: '/disputes' },
  { method: 'GET', path: '/disputes/ffffffff-ffff-4fff-8fff-ffffffffffff' },
  { method: 'POST', path: '/disputes/ffffffff-ffff-4fff-8fff-ffffffffffff/resolve' },
  { method: 'POST', path: '/disputes/ffffffff-ffff-4fff-8fff-ffffffffffff/reject' },
  // Audit & Analytics
  { method: 'GET', path: '/audit-logs' },
  { method: 'GET', path: '/analytics' },
  { method: 'GET', path: '/system-health' },
];

// ============================================================
// RUN TESTS
// ============================================================

for (const ep of endpoints) {
  // Test 1: Admin access should succeed
  test(`ADMIN allowed: ${ep.method} ${ep.path}`, async () => {
    const db = createFakeDb();
    const server = await startTestServer(db);
    const port = (server.address() as AddressInfo).port;
    const token = generateToken(ADMIN);
    const res = await makeRequest(port, ep.method, ep.path, token, ep.body);
    const payload = await parseResponse(res);

    const acceptableStatuses = [200, 201, 501];
    const isOk = acceptableStatuses.includes(res.status);
    assert.equal(isOk, true, `expected one of ${acceptableStatuses.join(', ')} got ${res.status} for ${ep.path}`);

    if (res.status !== 501) {
      assert.equal(Boolean(payload.success), true, `expected success true for ${ep.path}`);
    }
    server.close();
  });

  // Test 2: No token should be rejected with 401
  test(`No token denied: ${ep.method} ${ep.path}`, async () => {
    const db = createFakeDb();
    const server = await startTestServer(db);
    const port = (server.address() as AddressInfo).port;
    const res = await makeRequest(port, ep.method, ep.path, undefined, ep.body);
    const payload = await parseResponse(res);
    assert.equal(res.status, 401, `expected 401 for missing token on ${ep.path}`);
    assert.equal(Boolean(payload.success), false, `expected success false for missing token on ${ep.path}`);
    server.close();
  });

  // Test 3: Invalid token should be rejected with 401
  test(`Invalid token rejected: ${ep.method} ${ep.path}`, async () => {
    const db = createFakeDb();
    const server = await startTestServer(db);
    const port = (server.address() as AddressInfo).port;
    const res = await makeRequest(port, ep.method, ep.path, 'this.is.invalid', ep.body);
    const payload = await parseResponse(res);
    assert.equal(res.status, 401, `expected 401 for invalid token on ${ep.path}`);
    assert.equal(Boolean(payload.success), false, `expected success false for invalid token on ${ep.path}`);
    server.close();
  });

  // Test 4: Non-admin roles should be rejected with 403
  for (const persona of [SHIPPER, DRIVER, FLEET]) {
    test(`Role denied (${persona.role}): ${ep.method} ${ep.path}`, async () => {
      const db = createFakeDb();
      const server = await startTestServer(db);
      const port = (server.address() as AddressInfo).port;
      const token = generateToken(persona);
      const res = await makeRequest(port, ep.method, ep.path, token, ep.body);
      const payload = await parseResponse(res);
      assert.equal(res.status, 403, `expected 403 for role ${persona.role} on ${ep.path}`);
      assert.equal(Boolean(payload.success), false, `expected success false for role ${persona.role} on ${ep.path}`);
      server.close();
    });
  }
}

// ============================================================
// SECURITY TESTS
// ============================================================

// Test 5: Role escalation by tampering with JWT
test('Role escalation by tampering with JWT should be rejected', async () => {
  const db = createFakeDb();
  const server = await startTestServer(db);
  const port = (server.address() as AddressInfo).port;
  const shipperToken = generateToken(SHIPPER);
  const parts = shipperToken.split('.');
  const payload = JSON.parse(Buffer.from(parts[1], 'base64').toString());
  payload.role = 'ADMIN';
  const tampered = `${parts[0]}.${Buffer.from(JSON.stringify(payload)).toString('base64')}.${parts[2]}`;
  const res = await makeRequest(port, 'GET', '/dashboard', tampered);
  const payloadResp = await parseResponse(res);
  assert.equal(res.status, 401, 'expected invalid signature to be rejected with 401');
  assert.equal(Boolean(payloadResp.success), false);
  server.close();
});