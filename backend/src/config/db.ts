import knex from 'knex';
import config from '../../knexfile';

const environment = process.env.NODE_ENV || 'development';
const db = knex(config[environment]);

export async function testDbConnection(): Promise<boolean> {
  try {
    await db.raw('SELECT 1+1 AS result');
    console.log('✅ PostgreSQL Connection established successfully.');
    
    // Attempt to enable PostGIS spatial extension if installed on system
    try {
      await db.raw('CREATE EXTENSION IF NOT EXISTS postgis;');
      console.log('✅ PostGIS spatial extension enabled.');
    } catch (spatialErr) {
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
