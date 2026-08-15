import { Router } from 'express';
import type { Knex } from 'knex';
import db from '../config/db';
import { authenticateToken } from '../middleware/auth';
import { authorizeRoles } from '../middleware/rbac';
import {
  activateUserController,
  analyticsController,
  approveKycController,
  changeUserRoleController,
  dashboardController,
  deleteUserController,
  getDisputeController,
  getKycController,
  getLoadController,
  getShipmentController,
  getUserController,
  getVehicleController,
  listAuditLogsController,
  listCommissionsController,
  listDisputesController,
  listEscrowController,
  listKycController,
  listLoadsController,
  listShipmentsController,
  listTransactionsController,
  listUsersController,
  listVehiclesController,
  rejectDisputeController,
  rejectKycController,
  rejectVehicleController,
  resolveDisputeController,
  suspendUserController,
  systemHealthController,
  updateLoadController,
  updateShipmentController,
  updateUserController,
  verifyVehicleController,
} from '../controllers/adminController';

export function createAdminRouter(database: Knex = db) {
  const router = Router();

  router.use(authenticateToken);
  router.use(authorizeRoles('ADMIN'));

  router.get('/dashboard', (req, res) => dashboardController(req, res, database));
  router.get('/users', (req, res) => listUsersController(req, res, database));
  router.get('/users/:id', (req, res) => getUserController(req, res, database));
  router.patch('/users/:id', (req, res) => updateUserController(req, res, database));
  router.patch('/users/:id/role', (req, res) => changeUserRoleController(req, res, database));
  router.post('/users/:id/suspend', (req, res) => suspendUserController(req, res, database));
  router.post('/users/:id/activate', (req, res) => activateUserController(req, res, database));
  router.delete('/users/:id', (req, res) => deleteUserController(req, res, database));

  router.get('/kyc', (req, res) => listKycController(req, res, database));
  router.get('/kyc/:id', (req, res) => getKycController(req, res, database));
  router.post('/kyc/:id/approve', (req, res) => approveKycController(req, res, database));
  router.post('/kyc/:id/reject', (req, res) => rejectKycController(req, res, database));

  router.get('/vehicles', (req, res) => listVehiclesController(req, res, database));
  router.get('/vehicles/:id', (req, res) => getVehicleController(req, res, database));
  router.post('/vehicles/:id/verify', (req, res) => verifyVehicleController(req, res, database));
  router.post('/vehicles/:id/reject', (req, res) => rejectVehicleController(req, res, database));

  router.get('/loads', (req, res) => listLoadsController(req, res, database));
  router.get('/loads/:id', (req, res) => getLoadController(req, res, database));
  router.patch('/loads/:id', (req, res) => updateLoadController(req, res, database));

  router.get('/shipments', (req, res) => listShipmentsController(req, res, database));
  router.get('/shipments/:id', (req, res) => getShipmentController(req, res, database));
  router.patch('/shipments/:id', (req, res) => updateShipmentController(req, res, database));

  router.get('/escrow', (req, res) => listEscrowController(req, res, database));
  router.get('/transactions', (req, res) => listTransactionsController(req, res, database));
  router.get('/commissions', (req, res) => listCommissionsController(req, res, database));

  router.get('/disputes', (req, res) => listDisputesController(req, res, database));
  router.get('/disputes/:id', (req, res) => getDisputeController(req, res, database));
  router.post('/disputes/:id/resolve', (req, res) => resolveDisputeController(req, res, database));
  router.post('/disputes/:id/reject', (req, res) => rejectDisputeController(req, res, database));

  router.get('/audit-logs', (req, res) => listAuditLogsController(req, res, database));
  router.get('/analytics', (req, res) => analyticsController(req, res, database));
  router.get('/system-health', (req, res) => systemHealthController(req, res, database));

  return router;
}

export default createAdminRouter();
