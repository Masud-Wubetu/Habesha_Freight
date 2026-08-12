import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('loads', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table
      .uuid('shipper_id')
      .notNullable()
      .references('id')
      .inTable('users')
      .onDelete('CASCADE');
    table.string('cargo_description', 255).notNullable();
    table.decimal('weight_tons', 5, 2).notNullable();
    table.string('origin_city', 100).notNullable();
    table.string('destination_city', 100).notNullable();
    table
      .enum('status', [
        'POSTED',
        'MATCHED',
        'DISPATCHED',
        'IN_TRANSIT',
        'DELIVERED',
        'CANCELLED',
      ])
      .notNullable()
      .defaultTo('POSTED');
    table.decimal('offered_price_etb', 10, 2).notNullable();
    table.timestamps(true, true);
  });

  // Add PostGIS Geography geometry columns for origin and destination coordinates
  await knex.raw(
    `ALTER TABLE loads ADD COLUMN origin_geom geography(Point, 4326);`
  );
  await knex.raw(
    `ALTER TABLE loads ADD COLUMN destination_geom geography(Point, 4326);`
  );
  
  // Spatial Index for sub-300ms spatial corridor matching queries
  await knex.raw(`CREATE INDEX loads_origin_geom_idx ON loads USING GIST(origin_geom);`);
  await knex.raw(`CREATE INDEX loads_destination_geom_idx ON loads USING GIST(destination_geom);`);
}

export async function down(knex: Knex): Promise<void> {
  return knex.schema.dropTableIfExists('loads');
}
