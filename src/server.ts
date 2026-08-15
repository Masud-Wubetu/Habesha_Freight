import dotenv from 'dotenv';
import db, { testDbConnection } from './config/db';
import { createApp } from './app';

dotenv.config();

const port = Number(process.env.PORT) || 5000;

async function startServer() {
  const connected = await testDbConnection();
  if (!connected) {
    console.warn('⚠️ Starting server without a verified PostgreSQL connection.');
  }

  const app = createApp(db);
  app.listen(port, () => {
    console.log(`🚀 HabeshaFreight API server listening on port ${port}`);
  });
}

startServer().catch((error) => {
  console.error('Failed to start server:', error);
  process.exit(1);
});
