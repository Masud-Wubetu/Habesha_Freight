import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.alterTable('users', (table) => {
    table.string('profile_photo_url', 500).nullable();
    table.string('license_number', 100).nullable();
    table.string('license_photo_url', 500).nullable();
    table.jsonb('settings').nullable();
    table.string('company_logo_url', 500).nullable();
    table.string('company_registration_number', 100).nullable();
    table.text('company_description').nullable();
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.alterTable('users', (table) => {
    table.dropColumn('profile_photo_url');
    table.dropColumn('license_number');
    table.dropColumn('license_photo_url');
    table.dropColumn('settings');
    table.dropColumn('company_logo_url');
    table.dropColumn('company_registration_number');
    table.dropColumn('company_description');
  });
}
