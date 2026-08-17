"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.up = up;
exports.down = down;
async function up(knex) {
    return knex.schema.createTable('users', (table) => {
        table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
        table.string('full_name', 255).notNullable();
        table.string('phone_number', 50).notNullable().unique();
        table.string('email', 255).nullable().unique();
        table.string('password_hash', 255).notNullable();
        table
            .enum('role', ['SHIPPER', 'DRIVER', 'FLEET_OWNER', 'ADMIN'])
            .notNullable()
            .defaultTo('SHIPPER');
        table.boolean('is_verified').notNullable().defaultTo(false);
        table.string('otp_code', 10).nullable();
        table.timestamp('otp_expires_at').nullable();
        table.timestamps(true, true);
    });
}
async function down(knex) {
    return knex.schema.dropTableIfExists('users');
}
