import test from 'node:test';
import assert from 'node:assert/strict';
import express from 'express';
import type { AddressInfo } from 'node:net';
import loadRoutes from '../routes/loadRoutes';
import bidRoutes from '../routes/bidRoutes';
import { generateToken } from '../utils/jwt';

async function startTestServer() {
  const app = express();
  app.use(express.json());
  app.use('/api/loads', loadRoutes);
  app.use('/api/bids', bidRoutes);
  const server = app.listen(0);

  await new Promise<void>((resolve) => {
    server.once('listening', () => resolve());
  });

  return server;
}

test('unauthenticated user cannot access load endpoints', async () => {
  const server = await startTestServer();
  const port = (server.address() as AddressInfo).port;

  const response = await fetch(`http://127.0.0.1:${port}/api/loads`);
  const payload = (await response.json()) as Record<string, unknown>;

  assert.equal(response.status, 401);
  assert.equal(payload.success as boolean, false);

  server.close();
});

test('driver role is forbidden from posting a load', async () => {
  const server = await startTestServer();
  const port = (server.address() as AddressInfo).port;
  const token = generateToken({
    userId: '33333333-3333-4333-8333-333333333333',
    role: 'DRIVER',
    phoneNumber: '+251911334455',
  });

  const response = await fetch(`http://127.0.0.1:${port}/api/loads`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      cargo_description: 'Teff grain sacks',
      weight_tons: 20,
      origin_city: 'Bahr Dar',
      destination_city: 'Addis Ababa',
      origin_lat: 11.5742,
      origin_lng: 37.3614,
      destination_lat: 8.9806,
      destination_lng: 38.7578,
      offered_price_etb: 65000,
    }),
  });

  const payload = (await response.json()) as Record<string, unknown>;
  assert.equal(response.status, 403);
  assert.equal(payload.success as boolean, false);

  server.close();
});

test('posting load validates required parameters', async () => {
  const server = await startTestServer();
  const port = (server.address() as AddressInfo).port;
  const token = generateToken({
    userId: '22222222-2222-4222-8222-222222222222',
    role: 'SHIPPER',
    phoneNumber: '+251911556677',
  });

  const response = await fetch(`http://127.0.0.1:${port}/api/loads`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      cargo_description: 'Coffee beans',
      // missing coordinates and price
    }),
  });

  const payload = (await response.json()) as Record<string, unknown>;
  assert.equal(response.status, 400);
  assert.equal(payload.success as boolean, false);

  server.close();
});

test('shipper is forbidden from placing a bid', async () => {
  const server = await startTestServer();
  const port = (server.address() as AddressInfo).port;
  const token = generateToken({
    userId: '22222222-2222-4222-8222-222222222222',
    role: 'SHIPPER',
    phoneNumber: '+251911556677',
  });

  const response = await fetch(`http://127.0.0.1:${port}/api/bids`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      load_id: '44444444-4444-4444-8444-444444444444',
      bid_amount_etb: 40000,
    }),
  });

  const payload = (await response.json()) as Record<string, unknown>;
  assert.equal(response.status, 403);
  assert.equal(payload.success as boolean, false);

  server.close();
});
