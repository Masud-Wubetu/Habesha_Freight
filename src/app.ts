import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import type { Knex } from 'knex';

import db from './config/db';
import authRoutes from './routes/authRoutes';
import vehicleRoutes from './routes/vehicleRoutes';
import loadRoutes from './routes/loadRoutes';
import bidRoutes from './routes/bidRoutes';
import { createAdminRouter } from './routes/adminRoutes';

dotenv.config();

export function createApp(database: Knex = db): Express {
  const app = express();

  app.use(helmet());
  app.use(cors());
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));

  app.get('/health', (_req: Request, res: Response) => {
    res.status(200).json({ success: true, message: 'API is healthy.', data: { status: 'ok' } });
  });

  app.use('/api/auth', authRoutes);
  app.use('/api/vehicles', vehicleRoutes);
  app.use('/api/loads', loadRoutes);
  app.use('/api/bids', bidRoutes);
  app.use('/api/admin', createAdminRouter(database));

  app.use((error: unknown, _req: Request, res: Response, _next: NextFunction) => {
    if (error instanceof Error) {
      return res.status(500).json({
        success: false,
        message: 'Internal server error.',
        error: { code: error.name.toUpperCase() },
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Internal server error.',
      error: { code: 'UNKNOWN_ERROR' },
    });
  });

  return app;
}

export default createApp();
