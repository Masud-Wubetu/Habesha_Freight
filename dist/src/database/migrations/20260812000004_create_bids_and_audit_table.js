"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.up = up;
exports.down = down;
async function up(knex) {
    // Create Bids table
    await knex.schema.createTable('bids', (table) => {
        table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
        table
            .uuid('load_id')
            .notNullable()
            .references('id')
            .inTable('loads')
            .onDelete('CASCADE');
        table
            .uuid('driver_id')
            .notNullable()
            .references('id')
            .inTable('users')
            .onDelete('CASCADE');
        table.decimal('bid_amount_etb', 10, 2).notNullable();
        table
            .enum('status', ['PENDING', 'ACCEPTED', 'REJECTED'])
            .notNullable()
            .defaultTo('PENDING');
        table.timestamps(true, true);
    });
    // Create Audit Logs table for security compliance
    await knex.schema.createTable('audit_logs', (table) => {
        table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
        table.uuid('user_id').nullable().references('id').inTable('users');
        table.string('action', 100).notNullable();
        table.string('ip_address', 50).nullable();
        table.jsonb('details').nullable();
        table.timestamp('created_at').defaultTo(knex.fn.now());
    });
}
async function down(knex) {
    await knex.schema.dropTableIfExists('bids');
    await knex.schema.dropTableIfExists('audit_logs');
}
