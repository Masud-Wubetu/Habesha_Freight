import { Knex } from 'knex';
import bcrypt from 'bcryptjs';

export async function seed(knex: Knex): Promise<void> {
  // Clear existing entries
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

  const [admin] = await knex('users')
    .insert({
      full_name: 'System Administrator',
      phone_number: '+251900000000',
      email: 'admin@habeshafreight.et',
      password_hash: defaultPassword,
      role: 'ADMIN',
      is_verified: true,
    })
    .returning('*');

  // Insert Vehicle
  await knex('vehicles').insert({
    driver_id: driver.id,
    plate_number: 'ET-3-45892',
    vehicle_type: 'SINO_TRUCK',
    capacity_tons: 25.0,
    is_active: true,
  });

  // Insert Demo Freight Load with PostGIS Geometries for Addis Ababa -> Hawassa Corridor
  await knex.raw(`
    INSERT INTO loads (
      shipper_id, cargo_description, weight_tons, origin_city, destination_city, status, offered_price_etb, origin_geom, destination_geom
    ) VALUES (
      '${shipper.id}',
      'Construction Cement Bags (500 Bags)',
      25.00,
      'Addis Ababa',
      'Hawassa',
      'POSTED',
      45000.00,
      ST_SetSRID(ST_MakePoint(38.7578, 8.9806), 4326)::geography,
      ST_SetSRID(ST_MakePoint(38.4763, 7.0621), 4326)::geography
    );
  `);

  console.log('✅ Demo seed data successfully populated.');
}
