import { Knex } from 'knex';
import bcrypt from 'bcryptjs';
import crypto from 'crypto';

function hashOtp(otp: string): string {
  return crypto.createHash('sha256').update(otp).digest('hex');
}

export async function seed(knex: Knex): Promise<void> {
  // Clear existing entries in reverse dependency order
  await knex('audit_logs').del();
  await knex('reviews').del();
  await knex('disputes').del();
  await knex('location_breadcrumbs').del();
  await knex('escrow_ledger').del();
  await knex('shipments').del();
  await knex('bids').del();
  await knex('loads').del();
  await knex('vehicles').del();
  await knex('users').del();

  const defaultPassword = await bcrypt.hash('Password123!', 10);

  // Insert Users
  const [shipper] = await knex('users')
    .insert({
      full_name: 'Abebe Bikila Freight Ltd',
      phone_number: '+251911123456',
      email: 'shipper@habeshafreight.et',
      password_hash: defaultPassword,
      role: 'SHIPPER',
      is_verified: true,
    })
    .returning('*');

  const [driver] = await knex('users')
    .insert({
      full_name: 'Kebede Tadesse',
      phone_number: '+251922654321',
      email: 'driver@habeshafreight.et',
      password_hash: defaultPassword,
      role: 'DRIVER',
      is_verified: true,
    })
    .returning('*');

  await knex('users')
    .insert({
      full_name: 'System Administrator',
      phone_number: '+251900000000',
      email: 'admin@habeshafreight.et',
      password_hash: defaultPassword,
      role: 'ADMIN',
      is_verified: true,
    });

  // Insert Vehicle
  const [vehicle] = await knex('vehicles')
    .insert({
      driver_id: driver.id,
      plate_number: 'ET-3-45892',
      vehicle_type: 'SINO_TRUCK',
      capacity_tons: 25.0,
      is_active: true,
    })
    .returning('*');

  // Insert Loads
  const [load1] = await knex('loads')
    .insert({
      shipper_id: shipper.id,
      cargo_description: 'Construction Materials',
      weight_tons: 15.0,
      origin_city: 'Addis Ababa',
      destination_city: 'Bahir Dar',
      origin_lat: 8.9806,
      origin_lng: 38.7578,
      destination_lat: 11.5942,
      destination_lng: 37.3881,
      status: 'DELIVERED',
      offered_price_etb: 11000.0,
      created_at: new Date('2026-08-05T10:00:00Z'),
    })
    .returning('*');

  const [load2] = await knex('loads')
    .insert({
      shipper_id: shipper.id,
      cargo_description: 'General Goods',
      weight_tons: 20.0,
      origin_city: 'Adama',
      destination_city: 'Dire Dawa',
      origin_lat: 8.5414,
      origin_lng: 39.2689,
      destination_lat: 9.5931,
      destination_lng: 41.8661,
      status: 'DELIVERED',
      offered_price_etb: 28500.0,
      created_at: new Date('2026-07-28T14:30:00Z'),
    })
    .returning('*');

  const [load3] = await knex('loads')
    .insert({
      shipper_id: shipper.id,
      cargo_description: 'Construction Cement Bags (500 Bags)',
      weight_tons: 25.0,
      origin_city: 'Addis Ababa',
      destination_city: 'Hawassa',
      origin_lat: 8.9806,
      origin_lng: 38.7578,
      destination_lat: 7.0621,
      destination_lng: 38.4763,
      status: 'IN_TRANSIT',
      offered_price_etb: 45000.0,
    })
    .returning('*');

  // Insert Bids
  await knex('bids').insert([
    {
      load_id: load1.id,
      driver_id: driver.id,
      bid_amount_etb: 11000.0,
      status: 'ACCEPTED',
    },
    {
      load_id: load2.id,
      driver_id: driver.id,
      bid_amount_etb: 28500.0,
      status: 'ACCEPTED',
    },
    {
      load_id: load3.id,
      driver_id: driver.id,
      bid_amount_etb: 45000.0,
      status: 'ACCEPTED',
    },
  ]);

  // Insert Shipments
  const [shipment1] = await knex('shipments')
    .insert({
      load_id: load1.id,
      carrier_id: driver.id,
      vehicle_id: vehicle.id,
      status: 'DELIVERED',
      pickup_otp_hash: hashOtp('123456'),
      delivery_otp_hash: hashOtp('654321'),
      pickup_verified_at: new Date('2026-08-05T12:00:00Z'),
      delivery_verified_at: new Date('2026-08-06T16:00:00Z'),
      created_at: new Date('2026-08-05T10:00:00Z'),
    })
    .returning('*');

  const [shipment2] = await knex('shipments')
    .insert({
      load_id: load2.id,
      carrier_id: driver.id,
      vehicle_id: vehicle.id,
      status: 'DELIVERED',
      pickup_otp_hash: hashOtp('111111'),
      delivery_otp_hash: hashOtp('222222'),
      pickup_verified_at: new Date('2026-07-28T16:00:00Z'),
      delivery_verified_at: new Date('2026-07-29T18:00:00Z'),
      created_at: new Date('2026-07-28T14:30:00Z'),
    })
    .returning('*');

  await knex('shipments').insert({
    load_id: load3.id,
    carrier_id: driver.id,
    vehicle_id: vehicle.id,
    status: 'IN_TRANSIT',
    pickup_otp_hash: hashOtp('333333'),
    delivery_otp_hash: hashOtp('444444'),
    pickup_verified_at: new Date(),
  });

  const [company] = await knex('users')
    .insert({
      full_name: 'Ethio Transport Solutions',
      phone_number: '+251933998877',
      email: 'company@ethiotransport.et',
      password_hash: defaultPassword,
      role: 'FLEET_OWNER',
      is_verified: true,
    })
    .returning('*');

  // Insert Reviews for Shipment 1 and Shipment 2 (matching Ratings mockup)
  await knex('reviews').insert([
    {
      shipment_id: shipment1.id,
      reviewer_id: shipper.id,
      reviewee_id: driver.id,
      rating: 5,
      comment: 'Excellent driver, delivered on time!',
      created_at: new Date('2026-08-05T10:00:00Z'),
    },
    {
      shipment_id: shipment2.id,
      reviewer_id: shipper.id,
      reviewee_id: company.id,
      rating: 4,
      comment: 'Good coordination across 3 trucks.',
      created_at: new Date('2026-07-28T14:30:00Z'),
    },
  ]);

  console.log('✅ Demo seed data successfully populated with live shipments & ratings.');
}
