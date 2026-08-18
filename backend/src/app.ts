import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import type { Knex } from 'knex';

import db from './config/db';
import authRoutes from './routes/authRoutes';
import { createAdminRouter } from './routes/adminRoutes';
import loadRoutes from './routes/loadRoutes';
import bidRoutes from './routes/bidRoutes';
import vehicleRoutes from './routes/vehicleRoutes';
import shipmentRoutes from './routes/shipmentRoutes';
import escrowRoutes from './routes/escrowRoutes';
import trackingRoutes from './routes/trackingRoutes';
import disputeRoutes from './routes/disputeRoutes';
import reviewRoutes from './routes/reviewRoutes';

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

  // Mount API Endpoints
  app.use('/api/auth', authRoutes);
  app.use('/api/admin', createAdminRouter(database));
  app.use('/api/loads', loadRoutes);
  app.use('/api/bids', bidRoutes);
  app.use('/api/vehicles', vehicleRoutes);
  app.use('/api/shipments', shipmentRoutes);
  app.use('/api/escrow', escrowRoutes);
  app.use('/api/tracking', trackingRoutes);
  app.use('/api/disputes', disputeRoutes);
  app.use('/api/reviews', reviewRoutes);

  // Global Error Handler
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
