"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.dashboardController = dashboardController;
exports.listUsersController = listUsersController;
exports.getUserController = getUserController;
exports.updateUserController = updateUserController;
exports.changeUserRoleController = changeUserRoleController;
exports.suspendUserController = suspendUserController;
exports.activateUserController = activateUserController;
exports.deleteUserController = deleteUserController;
exports.listKycController = listKycController;
exports.getKycController = getKycController;
exports.approveKycController = approveKycController;
exports.rejectKycController = rejectKycController;
exports.listVehiclesController = listVehiclesController;
exports.getVehicleController = getVehicleController;
exports.verifyVehicleController = verifyVehicleController;
exports.rejectVehicleController = rejectVehicleController;
exports.listLoadsController = listLoadsController;
exports.getLoadController = getLoadController;
exports.updateLoadController = updateLoadController;
exports.listShipmentsController = listShipmentsController;
exports.getShipmentController = getShipmentController;
exports.updateShipmentController = updateShipmentController;
exports.listEscrowController = listEscrowController;
exports.listTransactionsController = listTransactionsController;
exports.listCommissionsController = listCommissionsController;
exports.listDisputesController = listDisputesController;
exports.getDisputeController = getDisputeController;
exports.resolveDisputeController = resolveDisputeController;
exports.rejectDisputeController = rejectDisputeController;
exports.listAuditLogsController = listAuditLogsController;
exports.analyticsController = analyticsController;
exports.systemHealthController = systemHealthController;
const db_1 = __importDefault(require("../config/db"));
const adminService_1 = require("../services/adminService");
const toErrorCode = (error) => {
    if (error instanceof Error) {
        return error.message.toUpperCase().replace(/\s+/g, '_');
    }
    return 'UNKNOWN_ERROR';
};
const sendError = (res, status, message, code) => {
    return res.status(status).json({ success: false, message, error: { code } });
};
async function dashboardController(req, res, database = db_1.default) {
    try {
        const result = await (0, adminService_1.getAdminDashboard)(database);
        return res.status(200).json(result);
    }
    catch (error) {
        return sendError(res, 500, 'Unable to load dashboard summary.', toErrorCode(error));
    }
}
async function listUsersController(req, res, database = db_1.default) {
    try {
        const result = await (0, adminService_1.listUsers)(database, req.query);
        return res.status(200).json(result);
    }
    catch (error) {
        return sendError(res, 500, 'Unable to fetch users.', toErrorCode(error));
    }
}
async function getUserController(req, res, database = db_1.default) {
    try {
        const result = await (0, adminService_1.getUserById)(database, req.params.id);
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'INVALID_ID')
            return sendError(res, 400, 'Invalid user ID.', code);
        if (code === 'USER_NOT_FOUND')
            return sendError(res, 404, 'User not found.', code);
        return sendError(res, 500, 'Unable to fetch user.', code);
    }
}
async function updateUserController(req, res, database = db_1.default) {
    try {
        const actorId = req.user?.userId ?? null;
        const result = await (0, adminService_1.updateUserByAdmin)(database, req.params.id, req.body ?? {}, actorId ?? '');
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'INVALID_ID')
            return sendError(res, 400, 'Invalid user ID.', code);
        if (code === 'USER_NOT_FOUND')
            return sendError(res, 404, 'User not found.', code);
        if (code === 'PROHIBITED_FIELD')
            return sendError(res, 400, 'Attempt to modify a protected field.', code);
        return sendError(res, 500, 'Unable to update user.', code);
    }
}
async function changeUserRoleController(req, res, database = db_1.default) {
    try {
        const actorId = req.user?.userId ?? null;
        const result = await (0, adminService_1.changeUserRoleByAdmin)(database, req.params.id, req.body?.role ?? '', actorId ?? '');
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'INVALID_ID')
            return sendError(res, 400, 'Invalid user ID.', code);
        if (code === 'USER_NOT_FOUND')
            return sendError(res, 404, 'User not found.', code);
        if (code === 'INVALID_ROLE')
            return sendError(res, 400, 'Invalid role value provided.', code);
        if (code === 'LAST_ADMIN_PROTECTION')
            return sendError(res, 400, 'Cannot remove or demote the final remaining administrator.', code);
        return sendError(res, 500, 'Unable to update user role.', code);
    }
}
async function suspendUserController(req, res, database = db_1.default) {
    try {
        const actorId = req.user?.userId ?? null;
        const result = await (0, adminService_1.suspendUser)(database, req.params.id, actorId ?? '');
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'INVALID_ID')
            return sendError(res, 400, 'Invalid user ID.', code);
        if (code === 'USER_NOT_FOUND')
            return sendError(res, 404, 'User not found.', code);
        if (code === 'LAST_ADMIN_PROTECTION')
            return sendError(res, 400, 'Cannot suspend the final remaining administrator.', code);
        return sendError(res, 500, 'Unable to suspend user.', code);
    }
}
async function activateUserController(req, res, database = db_1.default) {
    try {
        const actorId = req.user?.userId ?? null;
        const result = await (0, adminService_1.activateUser)(database, req.params.id, actorId ?? '');
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'INVALID_ID')
            return sendError(res, 400, 'Invalid user ID.', code);
        if (code === 'USER_NOT_FOUND')
            return sendError(res, 404, 'User not found.', code);
        return sendError(res, 500, 'Unable to activate user.', code);
    }
}
async function deleteUserController(req, res, database = db_1.default) {
    try {
        const actorId = req.user?.userId ?? null;
        const result = await (0, adminService_1.deleteUserByAdmin)(database, req.params.id, actorId ?? '');
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'INVALID_ID')
            return sendError(res, 400, 'Invalid user ID.', code);
        if (code === 'USER_NOT_FOUND')
            return sendError(res, 404, 'User not found.', code);
        if (code === 'LAST_ADMIN_PROTECTION')
            return sendError(res, 400, 'Cannot deactivate the final remaining administrator.', code);
        return sendError(res, 500, 'Unable to deactivate user.', code);
    }
}
async function listKycController(req, res, database = db_1.default) {
    try {
        const result = await (0, adminService_1.listKycRequests)(database, req.query);
        return res.status(200).json(result);
    }
    catch (error) {
        return sendError(res, 500, 'Unable to fetch KYC requests.', toErrorCode(error));
    }
}
async function getKycController(req, res, database = db_1.default) {
    try {
        const result = await (0, adminService_1.getKycById)(database, req.params.id);
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'INVALID_ID')
            return sendError(res, 400, 'Invalid KYC identifier.', code);
        if (code === 'USER_NOT_FOUND')
            return sendError(res, 404, 'KYC record not found.', code);
        return sendError(res, 500, 'Unable to fetch KYC details.', code);
    }
}
async function approveKycController(req, res, database = db_1.default) {
    try {
        const actorId = req.user?.userId ?? null;
        const result = await (0, adminService_1.approveKyc)(database, req.params.id, actorId ?? '', req.body?.reason ?? undefined);
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'INVALID_ID')
            return sendError(res, 400, 'Invalid KYC identifier.', code);
        if (code === 'USER_NOT_FOUND')
            return sendError(res, 404, 'KYC record not found.', code);
        return sendError(res, 500, 'Unable to approve KYC.', code);
    }
}
async function rejectKycController(req, res, database = db_1.default) {
    try {
        const actorId = req.user?.userId ?? null;
        const result = await (0, adminService_1.rejectKyc)(database, req.params.id, actorId ?? '', req.body?.reason ?? '');
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'INVALID_ID')
            return sendError(res, 400, 'Invalid KYC identifier.', code);
        if (code === 'USER_NOT_FOUND')
            return sendError(res, 404, 'KYC record not found.', code);
        if (code === 'REJECTION_REASON_REQUIRED')
            return sendError(res, 400, 'A rejection reason is required.', code);
        return sendError(res, 500, 'Unable to reject KYC.', code);
    }
}
async function listVehiclesController(req, res, database = db_1.default) {
    try {
        const result = await (0, adminService_1.listVehicles)(database, req.query);
        return res.status(200).json(result);
    }
    catch (error) {
        return sendError(res, 500, 'Unable to fetch vehicles.', toErrorCode(error));
    }
}
async function getVehicleController(req, res, database = db_1.default) {
    try {
        const result = await (0, adminService_1.getVehicleById)(database, req.params.id);
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'INVALID_ID')
            return sendError(res, 400, 'Invalid vehicle ID.', code);
        if (code === 'VEHICLE_NOT_FOUND')
            return sendError(res, 404, 'Vehicle not found.', code);
        return sendError(res, 500, 'Unable to fetch vehicle.', code);
    }
}
async function verifyVehicleController(req, res, database = db_1.default) {
    try {
        const actorId = req.user?.userId ?? null;
        const result = await (0, adminService_1.verifyVehicle)(database, req.params.id, actorId ?? '');
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'INVALID_ID')
            return sendError(res, 400, 'Invalid vehicle ID.', code);
        if (code === 'VEHICLE_NOT_FOUND')
            return sendError(res, 404, 'Vehicle not found.', code);
        return sendError(res, 500, 'Unable to verify vehicle.', code);
    }
}
async function rejectVehicleController(req, res, database = db_1.default) {
    try {
        const actorId = req.user?.userId ?? null;
        const result = await (0, adminService_1.rejectVehicle)(database, req.params.id, actorId ?? '', req.body?.reason ?? '');
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'INVALID_ID')
            return sendError(res, 400, 'Invalid vehicle ID.', code);
        if (code === 'VEHICLE_NOT_FOUND')
            return sendError(res, 404, 'Vehicle not found.', code);
        return sendError(res, 500, 'Unable to reject vehicle.', code);
    }
}
async function listLoadsController(req, res, database = db_1.default) {
    try {
        const result = await (0, adminService_1.listLoads)(database, req.query);
        return res.status(200).json(result);
    }
    catch (error) {
        return sendError(res, 500, 'Unable to fetch loads.', toErrorCode(error));
    }
}
async function getLoadController(req, res, database = db_1.default) {
    try {
        const result = await (0, adminService_1.getLoadById)(database, req.params.id);
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'INVALID_ID')
            return sendError(res, 400, 'Invalid load ID.', code);
        if (code === 'LOAD_NOT_FOUND')
            return sendError(res, 404, 'Load not found.', code);
        if (code === 'LOADS_NOT_CONFIGURED')
            return sendError(res, 501, 'Load management is not configured in the current database schema.', code);
        return sendError(res, 500, 'Unable to fetch load.', code);
    }
}
async function updateLoadController(req, res, database = db_1.default) {
    try {
        const actorId = req.user?.userId ?? null;
        const result = await (0, adminService_1.updateLoadByAdmin)(database, req.params.id, req.body ?? {}, actorId ?? '');
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'INVALID_ID')
            return sendError(res, 400, 'Invalid load ID.', code);
        if (code === 'LOAD_NOT_FOUND')
            return sendError(res, 404, 'Load not found.', code);
        if (code === 'PROHIBITED_FIELD')
            return sendError(res, 400, 'Attempt to modify a protected field.', code);
        if (code === 'LOADS_NOT_CONFIGURED')
            return sendError(res, 501, 'Load management is not configured in the current database schema.', code);
        return sendError(res, 500, 'Unable to update load.', code);
    }
}
async function listShipmentsController(req, res, database = db_1.default) {
    try {
        const result = await (0, adminService_1.listShipments)(database, req.query);
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'SHIPMENTS_NOT_CONFIGURED')
            return sendError(res, 501, 'Shipments are not configured in the current database schema.', code);
        return sendError(res, 500, 'Unable to fetch shipments.', code);
    }
}
async function getShipmentController(req, res, database = db_1.default) {
    try {
        const result = await (0, adminService_1.getShipmentById)(database, req.params.id);
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'INVALID_ID')
            return sendError(res, 400, 'Invalid shipment ID.', code);
        if (code === 'SHIPMENT_NOT_FOUND')
            return sendError(res, 404, 'Shipment not found.', code);
        if (code === 'SHIPMENTS_NOT_CONFIGURED')
            return sendError(res, 501, 'Shipments are not configured in the current database schema.', code);
        return sendError(res, 500, 'Unable to fetch shipment.', code);
    }
}
async function updateShipmentController(req, res, database = db_1.default) {
    try {
        const actorId = req.user?.userId ?? null;
        const result = await (0, adminService_1.updateShipmentByAdmin)(database, req.params.id, req.body ?? {}, actorId ?? '');
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'INVALID_ID')
            return sendError(res, 400, 'Invalid shipment ID.', code);
        if (code === 'SHIPMENT_NOT_FOUND')
            return sendError(res, 404, 'Shipment not found.', code);
        if (code === 'SHIPMENTS_NOT_CONFIGURED')
            return sendError(res, 501, 'Shipments are not configured in the current database schema.', code);
        return sendError(res, 500, 'Unable to update shipment.', code);
    }
}
async function listEscrowController(req, res, database = db_1.default) {
    try {
        const result = await (0, adminService_1.listEscrow)(database, req.query);
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'ESCROW_NOT_CONFIGURED')
            return sendError(res, 501, 'Escrow ledger is not configured in the current database schema.', code);
        return sendError(res, 500, 'Unable to fetch escrow records.', code);
    }
}
async function listTransactionsController(req, res, database = db_1.default) {
    try {
        const result = await (0, adminService_1.listTransactions)(database, req.query);
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'TRANSACTIONS_NOT_CONFIGURED')
            return sendError(res, 501, 'Transactions are not configured in the current database schema.', code);
        return sendError(res, 500, 'Unable to fetch transactions.', code);
    }
}
async function listCommissionsController(req, res, database = db_1.default) {
    try {
        const result = await (0, adminService_1.listCommissions)(database, req.query);
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'COMMISSIONS_NOT_CONFIGURED')
            return sendError(res, 501, 'Commissions ledger is not configured in the current database schema.', code);
        return sendError(res, 500, 'Unable to fetch commission details.', code);
    }
}
async function listDisputesController(req, res, database = db_1.default) {
    try {
        const result = await (0, adminService_1.listDisputes)(database, req.query);
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'DISPUTES_NOT_CONFIGURED')
            return sendError(res, 501, 'Disputes are not configured in the current database schema.', code);
        return sendError(res, 500, 'Unable to fetch disputes.', code);
    }
}
async function getDisputeController(req, res, database = db_1.default) {
    try {
        const result = await (0, adminService_1.getDisputeById)(database, req.params.id);
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'INVALID_ID')
            return sendError(res, 400, 'Invalid dispute ID.', code);
        if (code === 'DISPUTE_NOT_FOUND')
            return sendError(res, 404, 'Dispute not found.', code);
        if (code === 'DISPUTES_NOT_CONFIGURED')
            return sendError(res, 501, 'Disputes are not configured in the current database schema.', code);
        return sendError(res, 500, 'Unable to fetch dispute.', code);
    }
}
async function resolveDisputeController(req, res, database = db_1.default) {
    try {
        const actorId = req.user?.userId ?? null;
        const result = await (0, adminService_1.resolveDispute)(database, req.params.id, actorId ?? '');
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'INVALID_ID')
            return sendError(res, 400, 'Invalid dispute ID.', code);
        if (code === 'DISPUTE_NOT_FOUND')
            return sendError(res, 404, 'Dispute not found.', code);
        if (code === 'DISPUTES_NOT_CONFIGURED')
            return sendError(res, 501, 'Disputes are not configured in the current database schema.', code);
        return sendError(res, 500, 'Unable to resolve dispute.', code);
    }
}
async function rejectDisputeController(req, res, database = db_1.default) {
    try {
        const actorId = req.user?.userId ?? null;
        const result = await (0, adminService_1.rejectDispute)(database, req.params.id, actorId ?? '');
        return res.status(200).json(result);
    }
    catch (error) {
        const code = toErrorCode(error);
        if (code === 'INVALID_ID')
            return sendError(res, 400, 'Invalid dispute ID.', code);
        if (code === 'DISPUTE_NOT_FOUND')
            return sendError(res, 404, 'Dispute not found.', code);
        if (code === 'DISPUTES_NOT_CONFIGURED')
            return sendError(res, 501, 'Disputes are not configured in the current database schema.', code);
        return sendError(res, 500, 'Unable to reject dispute.', code);
    }
}
async function listAuditLogsController(req, res, database = db_1.default) {
    try {
        const result = await (0, adminService_1.listAuditLogs)(database, req.query);
        return res.status(200).json(result);
    }
    catch (error) {
        return sendError(res, 500, 'Unable to fetch audit logs.', toErrorCode(error));
    }
}
async function analyticsController(req, res, database = db_1.default) {
    try {
        const from = typeof req.query.from === 'string' ? req.query.from : undefined;
        const to = typeof req.query.to === 'string' ? req.query.to : undefined;
        const result = await (0, adminService_1.getAdminAnalytics)(database, from, to);
        return res.status(200).json(result);
    }
    catch (error) {
        return sendError(res, 500, 'Unable to fetch analytics.', toErrorCode(error));
    }
}
async function systemHealthController(req, res, database = db_1.default) {
    try {
        const result = await (0, adminService_1.getSystemHealth)(database);
        return res.status(200).json(result);
    }
    catch (error) {
        return sendError(res, 500, 'Unable to fetch system health.', toErrorCode(error));
    }
}
