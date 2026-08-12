import knex from 'knex';
import config from '../../knexfile';

const environment = process.env.NODE_ENV || 'development';
const db = knex(config[environment]);

export async function testDbConnection(): Promise<boolean> {
  try {
    await db.raw('SELECT 1+1 AS result');
    console.log('✅ PostgreSQL Connection established successfully.');
    
    // Ensure PostGIS extension is available
    await db.raw('CREATE EXTENSION IF NOT EXISTS postgis;');
    console.log('✅ PostGIS spatial extension enabled.');
    return true;
  } catch (error) {
    console.error('❌ Database connection failure:', error);
    return false;
  }
}

export default db;
