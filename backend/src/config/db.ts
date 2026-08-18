import knex, { Knex } from 'knex';
import dotenv from 'dotenv';

dotenv.config();

const environment = process.env.NODE_ENV || 'development';

const config: Record<string, Knex.Config> = {
  development: {
    client: 'pg',
    connection: {
      host: process.env.DB_HOST || 'localhost',
      port: Number(process.env.DB_PORT) || 5432,
      database: process.env.DB_NAME || 'habesha_freight_db',
      user: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD || 'postgres',
    },
    migrations: {
      directory: './src/database/migrations',
      extension: 'ts',
    },
    seeds: {
      directory: './src/database/seeds',
      extension: 'ts',
    },
  },
  production: {
    client: 'pg',
    connection: process.env.DATABASE_URL || {
      host: process.env.DB_HOST || 'localhost',
      port: Number(process.env.DB_PORT) || 5432,
      database: process.env.DB_NAME || 'habesha_freight_db',
      user: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD || 'postgres',
    },
    migrations: {
      directory: './dist/database/migrations',
    },
    seeds: {
      directory: './dist/database/seeds',
    },
  },
};

const db = knex(config[environment] || config.development);

export async function testDbConnection(): Promise<boolean> {
  try {
    await db.raw('SELECT 1+1 AS result');
    console.log('✅ PostgreSQL Connection established successfully.');

    // Attempt to enable PostGIS spatial extension if installed on system
    try {
      await db.raw('CREATE EXTENSION IF NOT EXISTS postgis;');
      console.log('✅ PostGIS spatial extension enabled.');
    } catch {
      console.warn(
        '⚠️ PostGIS extension not installed on system PostgreSQL server. Spatial fallback active.'
      );
    }
    return true;
  } catch (error) {
    console.error('❌ Database connection failure:', error);
    return false;
  }
}

export default db;
