import type { Request, Response } from 'express';
import type { Knex } from 'knex';
import db from '../config/db';
import {
  activateUser,
  approveKyc,
  changeUserRoleByAdmin,
  deleteUserByAdmin,
  getAdminAnalytics,
  getAdminDashboard,
  getDisputeById,
  getKycById,
  getLoadById,
  getShipmentById,
  getSystemHealth,
  getUserById,
  getVehicleById,
  listAuditLogs,
  listCommissions,
  listDisputes,
  listEscrow,
  listKycRequests,
  listLoads,
  listShipments,
  listTransactions,
  listUsers,
  listVehicles,
  rejectDispute,
  rejectKyc,
  rejectVehicle,
  resolveDispute,
  suspendUser,
  updateLoadByAdmin,
  updateShipmentByAdmin,
  updateUserByAdmin,
  verifyVehicle,
} from '../services/adminService';

const toErrorCode = (error: unknown): string => {
  if (error instanceof Error) {
    return error.message.toUpperCase().replace(/\s+/g, '_');
  }
  return 'UNKNOWN_ERROR';
};

const sendError = (res: Response, status: number, message: string, code: string) => {
  return res.status(status).json({ success: false, message, error: { code } });
};

export async function dashboardController(req: Request, res: Response, database: Knex = db) {
  try {
    const result = await getAdminDashboard(database);
    return res.status(200).json(result);
  } catch (error) {
    return sendError(res, 500, 'Unable to load dashboard summary.', toErrorCode(error));
  }
}

export async function listUsersController(req: Request, res: Response, database: Knex = db) {
  try {
    const result = await listUsers(database, req.query as Record<string, string>);
    return res.status(200).json(result);
  } catch (error) {
    return sendError(res, 500, 'Unable to fetch users.', toErrorCode(error));
  }
}

export async function getUserController(req: Request, res: Response, database: Knex = db) {
  try {
    const result = await getUserById(database, req.params.id);
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'INVALID_ID') return sendError(res, 400, 'Invalid user ID.', code);
    if (code === 'USER_NOT_FOUND') return sendError(res, 404, 'User not found.', code);
    return sendError(res, 500, 'Unable to fetch user.', code);
  }
}

export async function updateUserController(req: Request, res: Response, database: Knex = db) {
  try {
    const actorId = (req as { user?: { userId?: string } }).user?.userId ?? null;
    const result = await updateUserByAdmin(database, req.params.id, req.body ?? {}, actorId ?? '');
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'INVALID_ID') return sendError(res, 400, 'Invalid user ID.', code);
    if (code === 'USER_NOT_FOUND') return sendError(res, 404, 'User not found.', code);
    if (code === 'PROHIBITED_FIELD') return sendError(res, 400, 'Attempt to modify a protected field.', code);
    return sendError(res, 500, 'Unable to update user.', code);
  }
}

export async function changeUserRoleController(req: Request, res: Response, database: Knex = db) {
  try {
    const actorId = (req as { user?: { userId?: string } }).user?.userId ?? null;
    const result = await changeUserRoleByAdmin(database, req.params.id, req.body?.role ?? '', actorId ?? '');
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'INVALID_ID') return sendError(res, 400, 'Invalid user ID.', code);
    if (code === 'USER_NOT_FOUND') return sendError(res, 404, 'User not found.', code);
    if (code === 'INVALID_ROLE') return sendError(res, 400, 'Invalid role value provided.', code);
    if (code === 'LAST_ADMIN_PROTECTION') return sendError(res, 400, 'Cannot remove or demote the final remaining administrator.', code);
    return sendError(res, 500, 'Unable to update user role.', code);
  }
}

export async function suspendUserController(req: Request, res: Response, database: Knex = db) {
  try {
    const actorId = (req as { user?: { userId?: string } }).user?.userId ?? null;
    const result = await suspendUser(database, req.params.id, actorId ?? '');
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'INVALID_ID') return sendError(res, 400, 'Invalid user ID.', code);
    if (code === 'USER_NOT_FOUND') return sendError(res, 404, 'User not found.', code);
    if (code === 'LAST_ADMIN_PROTECTION') return sendError(res, 400, 'Cannot suspend the final remaining administrator.', code);
    return sendError(res, 500, 'Unable to suspend user.', code);
  }
}

export async function activateUserController(req: Request, res: Response, database: Knex = db) {
  try {
    const actorId = (req as { user?: { userId?: string } }).user?.userId ?? null;
    const result = await activateUser(database, req.params.id, actorId ?? '');
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'INVALID_ID') return sendError(res, 400, 'Invalid user ID.', code);
    if (code === 'USER_NOT_FOUND') return sendError(res, 404, 'User not found.', code);
    return sendError(res, 500, 'Unable to activate user.', code);
  }
}

export async function deleteUserController(req: Request, res: Response, database: Knex = db) {
  try {
    const actorId = (req as { user?: { userId?: string } }).user?.userId ?? null;
    const result = await deleteUserByAdmin(database, req.params.id, actorId ?? '');
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'INVALID_ID') return sendError(res, 400, 'Invalid user ID.', code);
    if (code === 'USER_NOT_FOUND') return sendError(res, 404, 'User not found.', code);
    if (code === 'LAST_ADMIN_PROTECTION') return sendError(res, 400, 'Cannot deactivate the final remaining administrator.', code);
    return sendError(res, 500, 'Unable to deactivate user.', code);
  }
}

export async function listKycController(req: Request, res: Response, database: Knex = db) {
  try {
    const result = await listKycRequests(database, req.query as Record<string, string>);
    return res.status(200).json(result);
  } catch (error) {
    return sendError(res, 500, 'Unable to fetch KYC requests.', toErrorCode(error));
  }
}

export async function getKycController(req: Request, res: Response, database: Knex = db) {
  try {
    const result = await getKycById(database, req.params.id);
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'INVALID_ID') return sendError(res, 400, 'Invalid KYC identifier.', code);
    if (code === 'USER_NOT_FOUND') return sendError(res, 404, 'KYC record not found.', code);
    return sendError(res, 500, 'Unable to fetch KYC details.', code);
  }
}

export async function approveKycController(req: Request, res: Response, database: Knex = db) {
  try {
    const actorId = (req as { user?: { userId?: string } }).user?.userId ?? null;
    const result = await approveKyc(database, req.params.id, actorId ?? '', req.body?.reason ?? undefined);
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'INVALID_ID') return sendError(res, 400, 'Invalid KYC identifier.', code);
    if (code === 'USER_NOT_FOUND') return sendError(res, 404, 'KYC record not found.', code);
    return sendError(res, 500, 'Unable to approve KYC.', code);
  }
}

export async function rejectKycController(req: Request, res: Response, database: Knex = db) {
  try {
    const actorId = (req as { user?: { userId?: string } }).user?.userId ?? null;
    const result = await rejectKyc(database, req.params.id, actorId ?? '', req.body?.reason ?? '');
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'INVALID_ID') return sendError(res, 400, 'Invalid KYC identifier.', code);
    if (code === 'USER_NOT_FOUND') return sendError(res, 404, 'KYC record not found.', code);
    if (code === 'REJECTION_REASON_REQUIRED') return sendError(res, 400, 'A rejection reason is required.', code);
    return sendError(res, 500, 'Unable to reject KYC.', code);
  }
}

export async function listVehiclesController(req: Request, res: Response, database: Knex = db) {
  try {
    const result = await listVehicles(database, req.query as Record<string, string>);
    return res.status(200).json(result);
  } catch (error) {
    return sendError(res, 500, 'Unable to fetch vehicles.', toErrorCode(error));
  }
}

export async function getVehicleController(req: Request, res: Response, database: Knex = db) {
  try {
    const result = await getVehicleById(database, req.params.id);
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'INVALID_ID') return sendError(res, 400, 'Invalid vehicle ID.', code);
    if (code === 'VEHICLE_NOT_FOUND') return sendError(res, 404, 'Vehicle not found.', code);
    return sendError(res, 500, 'Unable to fetch vehicle.', code);
  }
}

export async function verifyVehicleController(req: Request, res: Response, database: Knex = db) {
  try {
    const actorId = (req as { user?: { userId?: string } }).user?.userId ?? null;
    const result = await verifyVehicle(database, req.params.id, actorId ?? '');
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'INVALID_ID') return sendError(res, 400, 'Invalid vehicle ID.', code);
    if (code === 'VEHICLE_NOT_FOUND') return sendError(res, 404, 'Vehicle not found.', code);
    return sendError(res, 500, 'Unable to verify vehicle.', code);
  }
}

export async function rejectVehicleController(req: Request, res: Response, database: Knex = db) {
  try {
    const actorId = (req as { user?: { userId?: string } }).user?.userId ?? null;
    const result = await rejectVehicle(database, req.params.id, actorId ?? '', req.body?.reason ?? '');
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'INVALID_ID') return sendError(res, 400, 'Invalid vehicle ID.', code);
    if (code === 'VEHICLE_NOT_FOUND') return sendError(res, 404, 'Vehicle not found.', code);
    return sendError(res, 500, 'Unable to reject vehicle.', code);
  }
}

export async function listLoadsController(req: Request, res: Response, database: Knex = db) {
  try {
    const result = await listLoads(database, req.query as Record<string, string>);
    return res.status(200).json(result);
  } catch (error) {
    return sendError(res, 500, 'Unable to fetch loads.', toErrorCode(error));
  }
}

export async function getLoadController(req: Request, res: Response, database: Knex = db) {
  try {
    const result = await getLoadById(database, req.params.id);
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'INVALID_ID') return sendError(res, 400, 'Invalid load ID.', code);
    if (code === 'LOAD_NOT_FOUND') return sendError(res, 404, 'Load not found.', code);
    if (code === 'LOADS_NOT_CONFIGURED') return sendError(res, 501, 'Load management is not configured in the current database schema.', code);
    return sendError(res, 500, 'Unable to fetch load.', code);
  }
}

export async function updateLoadController(req: Request, res: Response, database: Knex = db) {
  try {
    const actorId = (req as { user?: { userId?: string } }).user?.userId ?? null;
    const result = await updateLoadByAdmin(database, req.params.id, req.body ?? {}, actorId ?? '');
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'INVALID_ID') return sendError(res, 400, 'Invalid load ID.', code);
    if (code === 'LOAD_NOT_FOUND') return sendError(res, 404, 'Load not found.', code);
    if (code === 'PROHIBITED_FIELD') return sendError(res, 400, 'Attempt to modify a protected field.', code);
    if (code === 'LOADS_NOT_CONFIGURED') return sendError(res, 501, 'Load management is not configured in the current database schema.', code);
    return sendError(res, 500, 'Unable to update load.', code);
  }
}

export async function listShipmentsController(req: Request, res: Response, database: Knex = db) {
  try {
    const result = await listShipments(database, req.query as Record<string, string>);
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'SHIPMENTS_NOT_CONFIGURED') return sendError(res, 501, 'Shipments are not configured in the current database schema.', code);
    return sendError(res, 500, 'Unable to fetch shipments.', code);
  }
}

export async function getShipmentController(req: Request, res: Response, database: Knex = db) {
  try {
    const result = await getShipmentById(database, req.params.id);
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'INVALID_ID') return sendError(res, 400, 'Invalid shipment ID.', code);
    if (code === 'SHIPMENT_NOT_FOUND') return sendError(res, 404, 'Shipment not found.', code);
    if (code === 'SHIPMENTS_NOT_CONFIGURED') return sendError(res, 501, 'Shipments are not configured in the current database schema.', code);
    return sendError(res, 500, 'Unable to fetch shipment.', code);
  }
}

export async function updateShipmentController(req: Request, res: Response, database: Knex = db) {
  try {
    const actorId = (req as { user?: { userId?: string } }).user?.userId ?? null;
    const result = await updateShipmentByAdmin(database, req.params.id, req.body ?? {}, actorId ?? '');
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'INVALID_ID') return sendError(res, 400, 'Invalid shipment ID.', code);
    if (code === 'SHIPMENT_NOT_FOUND') return sendError(res, 404, 'Shipment not found.', code);
    if (code === 'SHIPMENTS_NOT_CONFIGURED') return sendError(res, 501, 'Shipments are not configured in the current database schema.', code);
    return sendError(res, 500, 'Unable to update shipment.', code);
  }
}

export async function listEscrowController(req: Request, res: Response, database: Knex = db) {
  try {
    const result = await listEscrow(database, req.query as Record<string, string>);
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'ESCROW_NOT_CONFIGURED') return sendError(res, 501, 'Escrow ledger is not configured in the current database schema.', code);
    return sendError(res, 500, 'Unable to fetch escrow records.', code);
  }
}

export async function listTransactionsController(req: Request, res: Response, database: Knex = db) {
  try {
    const result = await listTransactions(database, req.query as Record<string, string>);
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'TRANSACTIONS_NOT_CONFIGURED') return sendError(res, 501, 'Transactions are not configured in the current database schema.', code);
    return sendError(res, 500, 'Unable to fetch transactions.', code);
  }
}

export async function listCommissionsController(req: Request, res: Response, database: Knex = db) {
  try {
    const result = await listCommissions(database, req.query as Record<string, string>);
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'COMMISSIONS_NOT_CONFIGURED') return sendError(res, 501, 'Commissions ledger is not configured in the current database schema.', code);
    return sendError(res, 500, 'Unable to fetch commission details.', code);
  }
}

export async function listDisputesController(req: Request, res: Response, database: Knex = db) {
  try {
    const result = await listDisputes(database, req.query as Record<string, string>);
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'DISPUTES_NOT_CONFIGURED') return sendError(res, 501, 'Disputes are not configured in the current database schema.', code);
    return sendError(res, 500, 'Unable to fetch disputes.', code);
  }
}

export async function getDisputeController(req: Request, res: Response, database: Knex = db) {
  try {
    const result = await getDisputeById(database, req.params.id);
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'INVALID_ID') return sendError(res, 400, 'Invalid dispute ID.', code);
    if (code === 'DISPUTE_NOT_FOUND') return sendError(res, 404, 'Dispute not found.', code);
    if (code === 'DISPUTES_NOT_CONFIGURED') return sendError(res, 501, 'Disputes are not configured in the current database schema.', code);
    return sendError(res, 500, 'Unable to fetch dispute.', code);
  }
}

export async function resolveDisputeController(req: Request, res: Response, database: Knex = db) {
  try {
    const actorId = (req as { user?: { userId?: string } }).user?.userId ?? null;
    const result = await resolveDispute(database, req.params.id, actorId ?? '');
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'INVALID_ID') return sendError(res, 400, 'Invalid dispute ID.', code);
    if (code === 'DISPUTE_NOT_FOUND') return sendError(res, 404, 'Dispute not found.', code);
    if (code === 'DISPUTES_NOT_CONFIGURED') return sendError(res, 501, 'Disputes are not configured in the current database schema.', code);
    return sendError(res, 500, 'Unable to resolve dispute.', code);
  }
}

export async function rejectDisputeController(req: Request, res: Response, database: Knex = db) {
  try {
    const actorId = (req as { user?: { userId?: string } }).user?.userId ?? null;
    const result = await rejectDispute(database, req.params.id, actorId ?? '');
    return res.status(200).json(result);
  } catch (error) {
    const code = toErrorCode(error);
    if (code === 'INVALID_ID') return sendError(res, 400, 'Invalid dispute ID.', code);
    if (code === 'DISPUTE_NOT_FOUND') return sendError(res, 404, 'Dispute not found.', code);
    if (code === 'DISPUTES_NOT_CONFIGURED') return sendError(res, 501, 'Disputes are not configured in the current database schema.', code);
    return sendError(res, 500, 'Unable to reject dispute.', code);
  }
}

export async function listAuditLogsController(req: Request, res: Response, database: Knex = db) {
  try {
    const result = await listAuditLogs(database, req.query as Record<string, string>);
    return res.status(200).json(result);
  } catch (error) {
    return sendError(res, 500, 'Unable to fetch audit logs.', toErrorCode(error));
  }
}

export async function analyticsController(req: Request, res: Response, database: Knex = db) {
  try {
    const from = typeof req.query.from === 'string' ? req.query.from : undefined;
    const to = typeof req.query.to === 'string' ? req.query.to : undefined;
    const result = await getAdminAnalytics(database, from, to);
    return res.status(200).json(result);
  } catch (error) {
    return sendError(res, 500, 'Unable to fetch analytics.', toErrorCode(error));
  }
}

export async function systemHealthController(req: Request, res: Response, database: Knex = db) {
  try {
    const result = await getSystemHealth(database);
    return res.status(200).json(result);
  } catch (error) {
    return sendError(res, 500, 'Unable to fetch system health.', toErrorCode(error));
  }
}
