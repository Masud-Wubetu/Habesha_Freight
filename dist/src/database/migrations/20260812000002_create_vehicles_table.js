"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.up = up;
exports.down = down;
async function up(knex) {
    return knex.schema.createTable('vehicles', (table) => {
        table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
        table
            .uuid('driver_id')
            .notNullable()
            .references('id')
            .inTable('users')
            .onDelete('CASCADE');
        table.string('plate_number', 50).notNullable().unique();
        table
            .enum('vehicle_type', ['ISUZU_DRY', 'SINO_TRUCK', 'TRAILER', 'VAN'])
            .notNullable();
        table.decimal('capacity_tons', 5, 2).notNullable();
        table.boolean('is_active').notNullable().defaultTo(true);
        table.timestamps(true, true);
    });
}
async function down(knex) {
    return knex.schema.dropTableIfExists('vehicles');
}
