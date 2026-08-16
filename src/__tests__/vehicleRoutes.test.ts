import test from 'node:test';
import assert from 'node:assert/strict';
import express from 'express';
import type { AddressInfo } from 'node:net';
import vehicleRoutes from '../routes/vehicleRoutes';
import { generateToken } from '../utils/jwt';

async function startTestServer() {
  const app = express();
  app.use(express.json());
  app.use('/api/vehicles', vehicleRoutes);
  const server = app.listen(0);

  await new Promise<void>((resolve) => {
    server.once('listening', () => resolve());
  });

  return server;
}

test('unauthenticated user cannot access vehicle endpoints', async () => {
  const server = await startTestServer();
  const port = (server.address() as AddressInfo).port;

  const response = await fetch(`http://127.0.0.1:${port}/api/vehicles`);
  const payload = (await response.json()) as Record<string, unknown>;

  assert.equal(response.status, 401);
  assert.equal(payload.success as boolean, false);

  server.close();
});

test('vehicle registration validates required fields', async () => {
  const server = await startTestServer();
  const port = (server.address() as AddressInfo).port;
  const token = generateToken({
    userId: '11111111-1111-4111-8111-111111111111',
    role: 'DRIVER',
    phoneNumber: '+251911223344',
  });

  const response = await fetch(`http://127.0.0.1:${port}/api/vehicles`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      plate_number: 'ET-3-12345',
      // missing vehicle_type and capacity_tons
    }),
  });

  const payload = (await response.json()) as Record<string, unknown>;
  assert.equal(response.status, 400);
  assert.equal(payload.success as boolean, false);

  server.close();
});

test('shipper role is forbidden from registering vehicles', async () => {
  const server = await startTestServer();
  const port = (server.address() as AddressInfo).port;
  const token = generateToken({
    userId: '22222222-2222-4222-8222-222222222222',
    role: 'SHIPPER',
    phoneNumber: '+251911556677',
  });

  const response = await fetch(`http://127.0.0.1:${port}/api/vehicles`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      plate_number: 'ET-3-12345',
      vehicle_type: 'ISUZU_FSR',
      capacity_tons: 10,
    }),
  });

  const payload = (await response.json()) as Record<string, unknown>;
  assert.equal(response.status, 403);
  assert.equal(payload.success as boolean, false);

  server.close();
});
