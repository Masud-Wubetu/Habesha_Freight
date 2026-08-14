import test from 'node:test';
import assert from 'node:assert/strict';
import express from 'express';
import type { AddressInfo } from 'node:net';
import type { Knex } from 'knex';
import { createAdminRouter } from '../routes/adminRoutes';
import { generateToken } from '../utils/jwt';

function createFakeDb() {
  const users = [
    {
      id: '11111111-1111-4111-8111-111111111111',
      full_name: 'Admin User',
      phone_number: '+251900000001',
      email: 'admin@habeshafreight.et',
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
  ];

  const vehicles = [
    {
      id: '33333333-3333-4333-8333-333333333333',
      driver_id: users[1].id,
      plate_number: 'ET-3-45892',
      vehicle_type: 'SINO_TRUCK',
      capacity_tons: 25,
      is_active: true,
      verification_status: 'PENDING',
      created_at: new Date().toISOString(),
    },
  ];

  const loads = [
    {
      id: '44444444-4444-4444-8444-444444444444',
      shipper_id: users[1].id,
      cargo_description: 'Construction cement',
      weight_tons: 15,
      origin_city: 'Addis Ababa',
      destination_city: 'Hawassa',
      status: 'POSTED',
      offered_price_etb: 42000,
      created_at: new Date().toISOString(),
    },
  ];

  const tableData: Record<string, Array<Record<string, unknown>>> = {
    users,
    vehicles,
    loads,
    bids: [],
    audit_logs: [
      {
        id: '55555555-5555-4555-8555-555555555555',
        user_id: users[0].id,
        action: 'USER_UPDATED',
        ip_address: '127.0.0.1',
        details: { updatedFields: ['full_name'] },
        created_at: new Date().toISOString(),
      },
    ],
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
  };

  const createQueryBuilder = (tableName: string) => {
    const rows = tableData[tableName] ?? [];

    const queryBuilder = {
      where: function () { return this; },
      whereILike: function () { return this; },
      orderBy: function () { return this; },
      offset: function () { return this; },
      limit: function () { return rows; },
      clone: function () { return this; },
      select: function () { return this; },
      groupBy: function () { return this; },
      count: function () { return { first: async () => ({ count: String(rows.length) }) }; },
      columnInfo: async () => columns[tableName] ?? {},
      first: async () => (rows.length > 0 ? [rows[0]] : []),
      insert: async () => [],
      update: async () => 1,
    };

    return queryBuilder;
  };

  const db = (tableName: string) => createQueryBuilder(tableName);

  db.schema = {
    hasTable: async (table: string) => tableData[table] !== undefined,
  };

  db.raw = async () => [{ result: 1 }];

  return db as unknown as Knex;
}

async function startTestServer(fakeDb: Knex) {
  const app = express();
  app.use(express.json());
  app.use('/api/admin', createAdminRouter(fakeDb));
  const server = app.listen(0);

  await new Promise<void>((resolve) => {
    server.once('listening', () => resolve());
  });

  return server;
}

test('admin can access dashboard', async () => {
  const db = createFakeDb();
  const server = await startTestServer(db);
  const port = (server.address() as AddressInfo).port;
  const token = generateToken({ userId: '11111111-1111-4111-8111-111111111111', role: 'ADMIN', phoneNumber: '+251900000001' });

  const response = await fetch(`http://127.0.0.1:${port}/api/admin/dashboard`, {
    headers: { Authorization: `Bearer ${token}` },
  });

  const payload = (await response.json()) as Record<string, unknown>;
  assert.equal(response.status, 200);
  assert.equal(payload.success as boolean, true);
  assert.equal(payload.message as string, 'Dashboard summary retrieved successfully.');

  server.close();
});

test('non-admin user cannot access admin APIs', async () => {
  const db = createFakeDb();
  const server = await startTestServer(db);
  const port = (server.address() as AddressInfo).port;
  const token = generateToken({ userId: '22222222-2222-4222-8222-222222222222', role: 'SHIPPER', phoneNumber: '+251911111111' });

  const response = await fetch(`http://127.0.0.1:${port}/api/admin/users`, {
    headers: { Authorization: `Bearer ${token}` },
  });

  const payload = (await response.json()) as Record<string, unknown>;
  assert.equal(response.status, 403);
  assert.equal(payload.success as boolean, false);

  server.close();
});

test('unauthenticated user cannot access admin APIs', async () => {
  const db = createFakeDb();
  const server = await startTestServer(db);
  const port = (server.address() as AddressInfo).port;

  const response = await fetch(`http://127.0.0.1:${port}/api/admin/users`);
  const payload = (await response.json()) as Record<string, unknown>;

  assert.equal(response.status, 401);
  assert.equal(payload.success as boolean, false);

  server.close();
});

test('admin can list users and pagination metadata is present', async () => {
  const db = createFakeDb();
  const server = await startTestServer(db);
  const port = (server.address() as AddressInfo).port;
  const token = generateToken({ userId: '11111111-1111-4111-8111-111111111111', role: 'ADMIN', phoneNumber: '+251900000001' });

  const response = await fetch(`http://127.0.0.1:${port}/api/admin/users?page=1&limit=20`, {
    headers: { Authorization: `Bearer ${token}` },
  });

  const payload = (await response.json()) as Record<string, unknown>;
  const data = payload.data as Record<string, unknown>;
  const pagination = data.pagination as Record<string, unknown>;
  const users = data.users as Array<Record<string, unknown>>;

  assert.equal(response.status, 200);
  assert.equal(payload.success as boolean, true);
  assert.ok(pagination);
  assert.equal(users.length >= 1, true);

  server.close();
});

test('invalid user id returns a validation error', async () => {
  const db = createFakeDb();
  const server = await startTestServer(db);
  const port = (server.address() as AddressInfo).port;
  const token = generateToken({ userId: '11111111-1111-4111-8111-111111111111', role: 'ADMIN', phoneNumber: '+251900000001' });

  const response = await fetch(`http://127.0.0.1:${port}/api/admin/users/not-a-valid-id`, {
    headers: { Authorization: `Bearer ${token}` },
  });

  const payload = (await response.json()) as Record<string, unknown>;
  const error = payload.error as Record<string, unknown>;

  assert.equal(response.status, 400);
  assert.equal(payload.success as boolean, false);
  assert.equal(error.code as string, 'INVALID_ID');

  server.close();
});
