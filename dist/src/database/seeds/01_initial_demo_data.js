"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.seed = seed;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
async function seed(knex) {
    // Clear existing entries
    await knex('bids').del();
    await knex('loads').del();
    await knex('vehicles').del();
    await knex('users').del();
    const defaultPassword = await bcryptjs_1.default.hash('Password123!', 10);
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
    await knex('vehicles').insert({
        driver_id: driver.id,
        plate_number: 'ET-3-45892',
        vehicle_type: 'SINO_TRUCK',
        capacity_tons: 25.0,
        is_active: true,
    });
    // Insert Demo Freight Load for Addis Ababa -> Hawassa Corridor
    await knex('loads').insert({
        shipper_id: shipper.id,
        cargo_description: 'Construction Cement Bags (500 Bags)',
        weight_tons: 25.0,
        origin_city: 'Addis Ababa',
        destination_city: 'Hawassa',
        origin_lat: 8.9806,
        origin_lng: 38.7578,
        destination_lat: 7.0621,
        destination_lng: 38.4763,
        status: 'POSTED',
        offered_price_etb: 45000.0,
    });
    console.log('✅ Demo seed data successfully populated.');
}
