import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.alterTable('users', (table) => {
    table.string('fayda_number', 100).nullable().unique();
    table.boolean('fayda_verified').defaultTo(false);
    table.string('license_status', 50).defaultTo('PENDING');
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.alterTable('users', (table) => {
    table.dropColumn('fayda_number');
    table.dropColumn('fayda_verified');
    table.dropColumn('license_status');
  });
}
