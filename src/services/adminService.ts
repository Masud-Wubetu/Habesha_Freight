import type { Knex } from 'knex';
import db from '../config/db';

export const ADMIN_AUDIT_ACTIONS = {
  USER_SUSPENDED: 'USER_SUSPENDED',
  USER_ACTIVATED: 'USER_ACTIVATED',
  USER_DELETED: 'USER_DELETED',
  USER_UPDATED: 'USER_UPDATED',
  KYC_APPROVED: 'KYC_APPROVED',
  KYC_REJECTED: 'KYC_REJECTED',
  VEHICLE_VERIFIED: 'VEHICLE_VERIFIED',
  VEHICLE_REJECTED: 'VEHICLE_REJECTED',
  LOAD_UPDATED: 'LOAD_UPDATED',
  SHIPMENT_UPDATED: 'SHIPMENT_UPDATED',
  DISPUTE_RESOLVED: 'DISPUTE_RESOLVED',
  DISPUTE_REJECTED: 'DISPUTE_REJECTED',
  ESCROW_REVIEWED: 'ESCROW_REVIEWED',
  COMMISSION_REVIEWED: 'COMMISSION_REVIEWED',
} as const;

export type AuditAction = (typeof ADMIN_AUDIT_ACTIONS)[keyof typeof ADMIN_AUDIT_ACTIONS];

export type AdminRole = 'SHIPPER' | 'DRIVER' | 'FLEET_OWNER' | 'ADMIN';

export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface AdminResponse<T> {
  success: boolean;
  message: string;
  data: T;
  error?: { code: string };
}

export interface UserQueryInput {
  page?: string;
  limit?: string;
  search?: string;
  role?: string;
  status?: string;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

export interface VehicleQueryInput {
  page?: string;
  limit?: string;
  search?: string;
  verification?: string;
  owner?: string;
  vehicleType?: string;
}

export interface LoadQueryInput {
  page?: string;
  limit?: string;
  status?: string;
  origin?: string;
  destination?: string;
  shipper?: string;
  from?: string;
  to?: string;
}

export function isValidUuid(value: string): boolean {
  return /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$/.test(value);
}

export async function tableExists(dbClient: Knex, tableName: string): Promise<boolean> {
  const exists = await dbClient.schema.hasTable(tableName);
  return exists;
}

export async function hasColumn(dbClient: Knex, tableName: string, columnName: string): Promise<boolean> {
  const result = await dbClient(tableName).columnInfo();
  return Boolean(result[columnName]);
}

export function sanitizeUserRecord(record: Record<string, unknown>): Record<string, unknown> {
  const { password_hash, otp_code, otp_expires_at, ...safeRecord } = record;
  return safeRecord;
}

export function buildPagination(page: number, limit: number, total: number): PaginationMeta {
  const totalPages = total === 0 ? 0 : Math.ceil(total / limit);

  return {
    page,
    limit,
    total,
    totalPages,
  };
}

export async function logAudit(
  dbClient: Knex,
  actorId: string | null,
  action: AuditAction,
  targetType: string,
  targetId: string | null,
  metadata: Record<string, unknown> = {},
  ipAddress?: string | null
): Promise<void> {
  await dbClient('audit_logs').insert({
    user_id: actorId,
    action,
    ip_address: ipAddress ?? null,
    details: metadata,
    target_type: targetType,
    target_id: targetId,
  });
}

export async function getAdminDashboard(dbClient: Knex = db): Promise<AdminResponse<Record<string, unknown>>> {
  const usersTable = await tableExists(dbClient, 'users');
  const vehiclesTable = await tableExists(dbClient, 'vehicles');
  const loadsTable = await tableExists(dbClient, 'loads');
  const bidsTable = await tableExists(dbClient, 'bids');
  const auditTable = await tableExists(dbClient, 'audit_logs');

  const dashboard: Record<string, unknown> = {
    totalUsers: 0,
    totalShippers: 0,
    totalDrivers: 0,
    totalFleetOwners: 0,
    totalVehicles: 0,
    totalLoads: 0,
    activeShipments: 'not configured - no shipments table found',
    completedShipments: 'not configured - no shipments table found',
    cancelledShipments: 'not configured - no shipments table found',
    pendingKyc: 'not configured - no KYC status column found',
    pendingVehicleVerification: 'not configured - no verification_status column found',
    activeDisputes: 'not configured - no disputes table found',
    escrowBalance: 'not configured - no escrow table found',
    totalTransactionAmount: 'not configured - no transactions table found',
    platformCommission: 'not configured - no commission ledger found',
  };

  if (usersTable) {
    const [userStats] = await dbClient('users')
      .select(
        dbClient.raw('COUNT(*)::int as "totalUsers"'),
        dbClient.raw('COUNT(*) FILTER (WHERE role = ?)::int as "totalShippers"', ['SHIPPER']),
        dbClient.raw('COUNT(*) FILTER (WHERE role = ?)::int as "totalDrivers"', ['DRIVER']),
        dbClient.raw('COUNT(*) FILTER (WHERE role = ?)::int as "totalFleetOwners"', ['FLEET_OWNER'])
      )
      .first();

    dashboard.totalUsers = Number(userStats?.totalUsers ?? 0);
    dashboard.totalShippers = Number(userStats?.totalShippers ?? 0);
    dashboard.totalDrivers = Number(userStats?.totalDrivers ?? 0);
    dashboard.totalFleetOwners = Number(userStats?.totalFleetOwners ?? 0);

    const hasKycStatus = await hasColumn(dbClient, 'users', 'kyc_status');
    if (hasKycStatus) {
      const [kycStats] = await dbClient('users')
        .select(dbClient.raw('COUNT(*) FILTER (WHERE kyc_status = ?) as "pendingKyc"', ['PENDING']))
        .first();
      dashboard.pendingKyc = Number(kycStats?.pendingKyc ?? 0);
    } else {
      dashboard.pendingKyc = Number(
        (await dbClient('users').where({ is_verified: false }).count<{ count: string }[]>('* as count').first())?.count ?? 0
      );
    }
  }

  if (vehiclesTable) {
    const [vehicleStats] = await dbClient('vehicles')
      .select(dbClient.raw('COUNT(*)::int as "totalVehicles"'))
      .first();
    dashboard.totalVehicles = Number(vehicleStats?.totalVehicles ?? 0);

    const hasVerificationStatus = await hasColumn(dbClient, 'vehicles', 'verification_status');
    if (hasVerificationStatus) {
      const [verificationStats] = await dbClient('vehicles')
        .select(dbClient.raw('COUNT(*) FILTER (WHERE verification_status = ?) as "pendingVehicleVerification"', ['PENDING']))
        .first();
      dashboard.pendingVehicleVerification = Number(verificationStats?.pendingVehicleVerification ?? 0);
    }
  }

  if (loadsTable) {
    const [loadStats] = await dbClient('loads')
      .select(dbClient.raw('COUNT(*)::int as "totalLoads"'))
      .first();
    dashboard.totalLoads = Number(loadStats?.totalLoads ?? 0);
  }

  if (bidsTable && await tableExists(dbClient, 'bids')) {
    dashboard.platformCommission = 'not configured - no payment ledger exists';
  }

  if (auditTable) {
    const [auditStats] = await dbClient('audit_logs')
      .select(dbClient.raw('COUNT(*)::int as "auditCount"'))
      .first();
    dashboard.auditLogCount = Number(auditStats?.auditCount ?? 0);
  }

  return {
    success: true,
    message: 'Dashboard summary retrieved successfully.',
    data: dashboard,
  };
}

export async function listUsers(dbClient: Knex = db, query: UserQueryInput = {}): Promise<AdminResponse<{ users: Record<string, unknown>[]; pagination: PaginationMeta }>> {
  const page = Math.max(1, Number(query.page ?? '1'));
  const limit = Math.min(100, Math.max(1, Number(query.limit ?? '20')));
  const search = (query.search ?? '').trim();
  const role = (query.role ?? '').trim().toUpperCase();
  const status = (query.status ?? '').trim().toUpperCase();
  const sortBy = query.sortBy ?? 'created_at';
  const sortOrder = query.sortOrder ?? 'desc';

  let queryBuilder = dbClient('users').select('*');

  if (search) {
    queryBuilder = queryBuilder.where((builder) => {
      builder.whereILike('full_name', `%${search}%`);
      builder.orWhereILike('phone_number', `%${search}%`);
      builder.orWhereILike('email', `%${search}%`);
    });
  }

  if (role) {
    queryBuilder = queryBuilder.where('role', role);
  }

  if (status) {
    const hasStatusColumn = await hasColumn(dbClient, 'users', 'status');
    if (hasStatusColumn) {
      queryBuilder = queryBuilder.where('status', status);
    } else {
      const normalizedStatus = status === 'ACTIVE' || status === 'VERIFIED' ? true : false;
      queryBuilder = queryBuilder.where('is_verified', normalizedStatus);
    }
  }

  const totalCount = await queryBuilder.clone().count<{ count: string }[]>('* as count').first();
  const total = Number(totalCount?.count ?? 0);

  const users = await queryBuilder
    .orderBy(sortBy, sortOrder)
    .offset((page - 1) * limit)
    .limit(limit);

  return {
    success: true,
    message: 'Users retrieved successfully.',
    data: {
      users: users.map((user) => sanitizeUserRecord(user as Record<string, unknown>)),
      pagination: buildPagination(page, limit, total),
    },
  };
}

export async function getUserById(dbClient: Knex = db, userId: string): Promise<AdminResponse<Record<string, unknown>>> {
  if (!isValidUuid(userId)) {
    throw new Error('INVALID_ID');
  }

  const user = await dbClient('users').where({ id: userId }).first();
  if (!user) {
    throw new Error('USER_NOT_FOUND');
  }

  return {
    success: true,
    message: 'User retrieved successfully.',
    data: sanitizeUserRecord(user as Record<string, unknown>),
  };
}

export async function updateUserByAdmin(
  dbClient: Knex = db,
  userId: string,
  payload: Record<string, unknown>,
  actorId: string
): Promise<AdminResponse<Record<string, unknown>>> {
  if (!isValidUuid(userId)) {
    throw new Error('INVALID_ID');
  }

  const existingUser = await dbClient('users').where({ id: userId }).first();
  if (!existingUser) {
    throw new Error('USER_NOT_FOUND');
  }

  const forbiddenFields = ['password_hash', 'otp_code', 'otp_expires_at', 'token', 'refresh_token'];
  for (const field of forbiddenFields) {
    if (field in payload) {
      throw new Error('PROHIBITED_FIELD');
    }
  }

  const allowedUpdates: Record<string, unknown> = {};
  const permittedFields = ['full_name', 'email', 'phone_number', 'role', 'is_verified', 'status', 'kyc_status'];

  for (const field of permittedFields) {
    if (payload[field] !== undefined) {
      allowedUpdates[field] = payload[field];
    }
  }

  if (Object.keys(allowedUpdates).length === 0) {
    return {
      success: true,
      message: 'No valid admin updates provided.',
      data: sanitizeUserRecord(existingUser as Record<string, unknown>),
    };
  }

  if (allowedUpdates.role && !['SHIPPER', 'DRIVER', 'FLEET_OWNER', 'ADMIN'].includes(String(allowedUpdates.role).toUpperCase())) {
    throw new Error('INVALID_ROLE');
  }

  await dbClient('users').where({ id: userId }).update(allowedUpdates);
  await logAudit(dbClient, actorId, ADMIN_AUDIT_ACTIONS.USER_UPDATED, 'User', userId, { updatedFields: Object.keys(allowedUpdates) });

  const updatedUser = await dbClient('users').where({ id: userId }).first();

  return {
    success: true,
    message: 'User updated successfully.',
    data: sanitizeUserRecord(updatedUser as Record<string, unknown>),
  };
}

export async function suspendUser(dbClient: Knex = db, userId: string, actorId: string): Promise<AdminResponse<Record<string, unknown>>> {
  if (!isValidUuid(userId)) {
    throw new Error('INVALID_ID');
  }

  const user = await dbClient('users').where({ id: userId }).first();
  if (!user) {
    throw new Error('USER_NOT_FOUND');
  }

  const hasStatusColumn = await hasColumn(dbClient, 'users', 'status');
  const nextState = hasStatusColumn ? 'SUSPENDED' : false;

  await dbClient('users').where({ id: userId }).update(hasStatusColumn ? { status: 'SUSPENDED' } : { is_verified: false });
  await logAudit(dbClient, actorId, ADMIN_AUDIT_ACTIONS.USER_SUSPENDED, 'User', userId, { previousState: user.status ?? user.is_verified ?? null });

  const updatedUser = await dbClient('users').where({ id: userId }).first();

  return {
    success: true,
    message: 'User suspended successfully.',
    data: sanitizeUserRecord(updatedUser as Record<string, unknown>),
  };
}

export async function activateUser(dbClient: Knex = db, userId: string, actorId: string): Promise<AdminResponse<Record<string, unknown>>> {
  if (!isValidUuid(userId)) {
    throw new Error('INVALID_ID');
  }

  const user = await dbClient('users').where({ id: userId }).first();
  if (!user) {
    throw new Error('USER_NOT_FOUND');
  }

  const hasStatusColumn = await hasColumn(dbClient, 'users', 'status');
  await dbClient('users').where({ id: userId }).update(hasStatusColumn ? { status: 'ACTIVE' } : { is_verified: true });
  await logAudit(dbClient, actorId, ADMIN_AUDIT_ACTIONS.USER_ACTIVATED, 'User', userId, { previousState: user.status ?? user.is_verified ?? null });

  const updatedUser = await dbClient('users').where({ id: userId }).first();

  return {
    success: true,
    message: 'User activated successfully.',
    data: sanitizeUserRecord(updatedUser as Record<string, unknown>),
  };
}

export async function deleteUserByAdmin(dbClient: Knex = db, userId: string, actorId: string): Promise<AdminResponse<Record<string, unknown>>> {
  if (!isValidUuid(userId)) {
    throw new Error('INVALID_ID');
  }

  const user = await dbClient('users').where({ id: userId }).first();
  if (!user) {
    throw new Error('USER_NOT_FOUND');
  }

  const hasDeletedAtColumn = await hasColumn(dbClient, 'users', 'deleted_at');
  if (hasDeletedAtColumn) {
    await dbClient('users').where({ id: userId }).update({ deleted_at: new Date() });
  } else {
    await dbClient('users').where({ id: userId }).update({ is_verified: false, status: 'INACTIVE' });
  }

  await logAudit(dbClient, actorId, ADMIN_AUDIT_ACTIONS.USER_DELETED, 'User', userId, { softDelete: !hasDeletedAtColumn, previousState: user.status ?? user.is_verified ?? null });

  const updatedUser = await dbClient('users').where({ id: userId }).first();

  return {
    success: true,
    message: 'User deactivated successfully. Physical deletion was avoided to preserve historical records.',
    data: sanitizeUserRecord(updatedUser as Record<string, unknown>),
  };
}

export async function listKycRequests(dbClient: Knex = db, query: UserQueryInput = {}): Promise<AdminResponse<{ users: Record<string, unknown>[]; pagination: PaginationMeta }>> {
  const hasKycStatusColumn = await hasColumn(dbClient, 'users', 'kyc_status');

  if (!hasKycStatusColumn) {
    const users = await dbClient('users').select('*').where({ is_verified: false });
    return {
      success: true,
      message: 'KYC queue retrieved from the current user verification state.',
      data: {
        users: users.map((user) => ({
          ...sanitizeUserRecord(user as Record<string, unknown>),
          kyc_status: user.is_verified ? 'APPROVED' : 'PENDING',
        })),
        pagination: buildPagination(1, users.length || 1, users.length),
      },
    };
  }

  const page = Math.max(1, Number(query.page ?? '1'));
  const limit = Math.min(100, Math.max(1, Number(query.limit ?? '20')));
  const status = (query.status ?? '').trim().toUpperCase();
  const role = (query.role ?? '').trim().toUpperCase();

  let queryBuilder = dbClient('users').select('*');
  if (status) queryBuilder = queryBuilder.where('kyc_status', status);
  if (role) queryBuilder = queryBuilder.where('role', role);

  const total = Number((await queryBuilder.clone().count<{ count: string }[]>('* as count').first())?.count ?? 0);
  const users = await queryBuilder.orderBy('created_at', 'desc').offset((page - 1) * limit).limit(limit);

  return {
    success: true,
    message: 'KYC requests retrieved successfully.',
    data: {
      users: users.map((user) => sanitizeUserRecord(user as Record<string, unknown>)),
      pagination: buildPagination(page, limit, total),
    },
  };
}

export async function getKycById(dbClient: Knex = db, userId: string): Promise<AdminResponse<Record<string, unknown>>> {
  const user = await getUserById(dbClient, userId);
  const response = user.data as Record<string, unknown>;
  const hasKycStatusColumn = await hasColumn(dbClient, 'users', 'kyc_status');

  if (hasKycStatusColumn) {
    return {
      success: true,
      message: 'KYC details retrieved successfully.',
      data: response,
    };
  }

  return {
    success: true,
    message: 'KYC details retrieved successfully from user verification data.',
    data: {
      ...response,
      kyc_status: response.is_verified ? 'APPROVED' : 'PENDING',
    },
  };
}

export async function approveKyc(dbClient: Knex = db, userId: string, actorId: string, rejectionReason?: string): Promise<AdminResponse<Record<string, unknown>>> {
  const user = await getUserById(dbClient, userId);
  const hasKycStatusColumn = await hasColumn(dbClient, 'users', 'kyc_status');

  if (hasKycStatusColumn) {
    await dbClient('users').where({ id: userId }).update({
      kyc_status: 'APPROVED',
      is_verified: true,
      kyc_reviewed_by: actorId,
      kyc_reviewed_at: new Date(),
      kyc_rejection_reason: rejectionReason ?? null,
    });
  } else {
    await dbClient('users').where({ id: userId }).update({ is_verified: true });
  }

  await logAudit(dbClient, actorId, ADMIN_AUDIT_ACTIONS.KYC_APPROVED, 'User', userId, { reason: rejectionReason ?? null, currentStatus: 'APPROVED' });

  const updatedUser = await dbClient('users').where({ id: userId }).first();

  return {
    success: true,
    message: 'KYC approved successfully.',
    data: sanitizeUserRecord(updatedUser as Record<string, unknown>),
  };
}

export async function rejectKyc(dbClient: Knex = db, userId: string, actorId: string, reason: string): Promise<AdminResponse<Record<string, unknown>>> {
  if (!reason || !reason.trim()) {
    throw new Error('REJECTION_REASON_REQUIRED');
  }

  const user = await getUserById(dbClient, userId);
  const hasKycStatusColumn = await hasColumn(dbClient, 'users', 'kyc_status');

  if (hasKycStatusColumn) {
    await dbClient('users').where({ id: userId }).update({
      kyc_status: 'REJECTED',
      is_verified: false,
      kyc_reviewed_by: actorId,
      kyc_reviewed_at: new Date(),
      kyc_rejection_reason: reason,
    });
  } else {
    await dbClient('users').where({ id: userId }).update({ is_verified: false });
  }

  await logAudit(dbClient, actorId, ADMIN_AUDIT_ACTIONS.KYC_REJECTED, 'User', userId, { reason, currentStatus: 'REJECTED' });

  const updatedUser = await dbClient('users').where({ id: userId }).first();

  return {
    success: true,
    message: 'KYC rejected successfully.',
    data: sanitizeUserRecord(updatedUser as Record<string, unknown>),
  };
}

export async function listVehicles(dbClient: Knex = db, query: VehicleQueryInput = {}): Promise<AdminResponse<{ vehicles: Record<string, unknown>[]; pagination: PaginationMeta }>> {
  const page = Math.max(1, Number(query.page ?? '1'));
  const limit = Math.min(100, Math.max(1, Number(query.limit ?? '20')));
  const search = (query.search ?? '').trim();
  const verification = (query.verification ?? '').trim().toUpperCase();
  const vehicleType = (query.vehicleType ?? '').trim();
  const owner = (query.owner ?? '').trim();

  let queryBuilder = dbClient('vehicles').select('*');

  if (search) {
    queryBuilder = queryBuilder.where((builder) => {
      builder.whereILike('plate_number', `%${search}%`);
      builder.orWhereILike('vehicle_type', `%${search}%`);
    });
  }

  if (verification && (await hasColumn(dbClient, 'vehicles', 'verification_status'))) {
    queryBuilder = queryBuilder.where('verification_status', verification);
  }

  if (vehicleType) {
    queryBuilder = queryBuilder.where('vehicle_type', vehicleType);
  }

  if (owner && (await hasColumn(dbClient, 'vehicles', 'driver_id'))) {
    queryBuilder = queryBuilder.where('driver_id', owner);
  }

  const total = Number((await queryBuilder.clone().count<{ count: string }[]>('* as count').first())?.count ?? 0);
  const vehicles = await queryBuilder.orderBy('created_at', 'desc').offset((page - 1) * limit).limit(limit);

  return {
    success: true,
    message: 'Vehicles retrieved successfully.',
    data: {
      vehicles: vehicles.map((vehicle) => vehicle as Record<string, unknown>),
      pagination: buildPagination(page, limit, total),
    },
  };
}

export async function getVehicleById(dbClient: Knex = db, vehicleId: string): Promise<AdminResponse<Record<string, unknown>>> {
  if (!isValidUuid(vehicleId)) {
    throw new Error('INVALID_ID');
  }

  const vehicle = await dbClient('vehicles').where({ id: vehicleId }).first();
  if (!vehicle) {
    throw new Error('VEHICLE_NOT_FOUND');
  }

  return {
    success: true,
    message: 'Vehicle retrieved successfully.',
    data: vehicle as Record<string, unknown>,
  };
}

export async function verifyVehicle(dbClient: Knex = db, vehicleId: string, actorId: string): Promise<AdminResponse<Record<string, unknown>>> {
  const vehicle = await getVehicleById(dbClient, vehicleId);
  const hasVerificationStatus = await hasColumn(dbClient, 'vehicles', 'verification_status');

  if (hasVerificationStatus) {
    await dbClient('vehicles').where({ id: vehicleId }).update({
      verification_status: 'VERIFIED',
      verified_by: actorId,
      verified_at: new Date(),
      verification_reason: null,
    });
  } else {
    await dbClient('vehicles').where({ id: vehicleId }).update({ is_active: true });
  }

  await logAudit(dbClient, actorId, ADMIN_AUDIT_ACTIONS.VEHICLE_VERIFIED, 'Vehicle', vehicleId, { verificationStatus: 'VERIFIED' });
  const updatedVehicle = await dbClient('vehicles').where({ id: vehicleId }).first();

  return {
    success: true,
    message: 'Vehicle verification updated successfully.',
    data: updatedVehicle as Record<string, unknown>,
  };
}

export async function rejectVehicle(dbClient: Knex = db, vehicleId: string, actorId: string, reason: string): Promise<AdminResponse<Record<string, unknown>>> {
  const vehicle = await getVehicleById(dbClient, vehicleId);
  const hasVerificationStatus = await hasColumn(dbClient, 'vehicles', 'verification_status');

  if (hasVerificationStatus) {
    await dbClient('vehicles').where({ id: vehicleId }).update({
      verification_status: 'REJECTED',
      verified_by: actorId,
      verified_at: new Date(),
      verification_reason: reason,
    });
  } else {
    await dbClient('vehicles').where({ id: vehicleId }).update({ is_active: false });
  }

  await logAudit(dbClient, actorId, ADMIN_AUDIT_ACTIONS.VEHICLE_REJECTED, 'Vehicle', vehicleId, { reason, verificationStatus: 'REJECTED' });
  const updatedVehicle = await dbClient('vehicles').where({ id: vehicleId }).first();

  return {
    success: true,
    message: 'Vehicle rejected successfully.',
    data: updatedVehicle as Record<string, unknown>,
  };
}

export async function listLoads(dbClient: Knex = db, query: LoadQueryInput = {}): Promise<AdminResponse<{ loads: Record<string, unknown>[]; pagination: PaginationMeta }>> {
  if (!(await tableExists(dbClient, 'loads'))) {
    return {
      success: true,
      message: 'Load monitoring is not configured in the current database schema.',
      data: {
        loads: [],
        pagination: buildPagination(1, 20, 0),
      },
    };
  }

  const page = Math.max(1, Number(query.page ?? '1'));
  const limit = Math.min(100, Math.max(1, Number(query.limit ?? '20')));
  const status = (query.status ?? '').trim().toUpperCase();
  const origin = (query.origin ?? '').trim();
  const destination = (query.destination ?? '').trim();
  const shipper = (query.shipper ?? '').trim();

  let queryBuilder = dbClient('loads').select('*');
  if (status) queryBuilder = queryBuilder.where('status', status);
  if (origin) queryBuilder = queryBuilder.whereILike('origin_city', `%${origin}%`);
  if (destination) queryBuilder = queryBuilder.whereILike('destination_city', `%${destination}%`);
  if (shipper) queryBuilder = queryBuilder.where('shipper_id', shipper);

  const total = Number((await queryBuilder.clone().count<{ count: string }[]>('* as count').first())?.count ?? 0);
  const loads = await queryBuilder.orderBy('created_at', 'desc').offset((page - 1) * limit).limit(limit);

  return {
    success: true,
    message: 'Loads retrieved successfully.',
    data: {
      loads: loads.map((load) => load as Record<string, unknown>),
      pagination: buildPagination(page, limit, total),
    },
  };
}

export async function getLoadById(dbClient: Knex = db, loadId: string): Promise<AdminResponse<Record<string, unknown>>> {
  if (!(await tableExists(dbClient, 'loads'))) {
    throw new Error('LOADS_NOT_CONFIGURED');
  }

  if (!isValidUuid(loadId)) {
    throw new Error('INVALID_ID');
  }

  const load = await dbClient('loads').where({ id: loadId }).first();
  if (!load) {
    throw new Error('LOAD_NOT_FOUND');
  }

  const bids = await dbClient('bids').where({ load_id: loadId }).select('*');

  return {
    success: true,
    message: 'Load retrieved successfully.',
    data: {
      ...(load as Record<string, unknown>),
      bids: bids.map((bid) => bid as Record<string, unknown>),
    },
  };
}

export async function updateLoadByAdmin(dbClient: Knex = db, loadId: string, payload: Record<string, unknown>, actorId: string): Promise<AdminResponse<Record<string, unknown>>> {
  if (!(await tableExists(dbClient, 'loads'))) {
    throw new Error('LOADS_NOT_CONFIGURED');
  }

  const load = await dbClient('loads').where({ id: loadId }).first();
  if (!load) {
    throw new Error('LOAD_NOT_FOUND');
  }

  const permittedFields = ['cargo_description', 'weight_tons', 'origin_city', 'destination_city', 'status', 'offered_price_etb'];
  const updates: Record<string, unknown> = {};
  for (const field of permittedFields) {
    if (payload[field] !== undefined) {
      updates[field] = payload[field];
    }
  }

  if (Object.keys(updates).length === 0) {
    return { success: true, message: 'No eligible admin changes supplied.', data: load as Record<string, unknown> };
  }

  await dbClient('loads').where({ id: loadId }).update(updates);
  await logAudit(dbClient, actorId, ADMIN_AUDIT_ACTIONS.LOAD_UPDATED, 'Load', loadId, { updatedFields: Object.keys(updates) });

  const updated = await dbClient('loads').where({ id: loadId }).first();
  return {
    success: true,
    message: 'Load updated successfully.',
    data: updated as Record<string, unknown>,
  };
}

export async function listShipments(dbClient: Knex = db, query: Record<string, unknown> = {}): Promise<AdminResponse<{ shipments: Record<string, unknown>[]; pagination: PaginationMeta }>> {
  const hasShipmentsTable = await tableExists(dbClient, 'shipments');
  if (!hasShipmentsTable) {
    return {
      success: true,
      message: 'Shipment records are not configured in the current schema.',
      data: {
        shipments: [],
        pagination: buildPagination(1, Number(query.limit ?? 20), 0),
      },
    };
  }

  const page = Math.max(1, Number(query.page ?? '1'));
  const limit = Math.min(100, Math.max(1, Number(query.limit ?? '20')));

  const total = Number((await dbClient('shipments').count<{ count: string }[]>('* as count').first())?.count ?? 0);
  const shipments = await dbClient('shipments').select('*').orderBy('created_at', 'desc').offset((page - 1) * limit).limit(limit);

  return {
    success: true,
    message: 'Shipments retrieved successfully.',
    data: {
      shipments: shipments.map((shipment) => shipment as Record<string, unknown>),
      pagination: buildPagination(page, limit, total),
    },
  };
}

export async function getShipmentById(dbClient: Knex = db, shipmentId: string): Promise<AdminResponse<Record<string, unknown>>> {
  const hasShipmentsTable = await tableExists(dbClient, 'shipments');
  if (!hasShipmentsTable) {
    throw new Error('SHIPMENTS_NOT_CONFIGURED');
  }

  const shipment = await dbClient('shipments').where({ id: shipmentId }).first();
  if (!shipment) {
    throw new Error('SHIPMENT_NOT_FOUND');
  }

  return {
    success: true,
    message: 'Shipment retrieved successfully.',
    data: shipment as Record<string, unknown>,
  };
}

export async function updateShipmentByAdmin(dbClient: Knex = db, shipmentId: string, payload: Record<string, unknown>, actorId: string): Promise<AdminResponse<Record<string, unknown>>> {
  const hasShipmentsTable = await tableExists(dbClient, 'shipments');
  if (!hasShipmentsTable) {
    throw new Error('SHIPMENTS_NOT_CONFIGURED');
  }

  const shipment = await dbClient('shipments').where({ id: shipmentId }).first();
  if (!shipment) {
    throw new Error('SHIPMENT_NOT_FOUND');
  }

  const allowedFields = ['status'];
  const updates: Record<string, unknown> = {};
  for (const field of allowedFields) {
    if (payload[field] !== undefined) {
      updates[field] = payload[field];
    }
  }

  if (Object.keys(updates).length === 0) {
    return { success: true, message: 'No eligible shipment admin changes supplied.', data: shipment as Record<string, unknown> };
  }

  await dbClient('shipments').where({ id: shipmentId }).update(updates);
  await logAudit(dbClient, actorId, ADMIN_AUDIT_ACTIONS.SHIPMENT_UPDATED, 'Shipment', shipmentId, { updatedFields: Object.keys(updates) });

  const updated = await dbClient('shipments').where({ id: shipmentId }).first();
  return {
    success: true,
    message: 'Shipment updated successfully.',
    data: updated as Record<string, unknown>,
  };
}

export async function listEscrow(dbClient: Knex = db, query: Record<string, unknown> = {}): Promise<AdminResponse<{ escrow: Record<string, unknown>[]; pagination: PaginationMeta }>> {
  const hasEscrowTable = await tableExists(dbClient, 'escrow_ledger');
  if (!hasEscrowTable) {
    return {
      success: true,
      message: 'Escrow ledger is not configured in the current schema.',
      data: {
        escrow: [],
        pagination: buildPagination(1, Number(query.limit ?? 20), 0),
      },
    };
  }

  const page = Math.max(1, Number(query.page ?? '1'));
  const limit = Math.min(100, Math.max(1, Number(query.limit ?? '20')));
  const total = Number((await dbClient('escrow_ledger').count<{ count: string }[]>('* as count').first())?.count ?? 0);
  const escrow = await dbClient('escrow_ledger').select('*').orderBy('created_at', 'desc').offset((page - 1) * limit).limit(limit);

  return {
    success: true,
    message: 'Escrow records retrieved successfully.',
    data: {
      escrow: escrow.map((record) => record as Record<string, unknown>),
      pagination: buildPagination(page, limit, total),
    },
  };
}

export async function listTransactions(dbClient: Knex = db, query: Record<string, unknown> = {}): Promise<AdminResponse<{ transactions: Record<string, unknown>[]; pagination: PaginationMeta }>> {
  const hasTransactionsTable = await tableExists(dbClient, 'transactions');
  if (!hasTransactionsTable) {
    return {
      success: true,
      message: 'Transaction ledger is not configured in the current schema.',
      data: {
        transactions: [],
        pagination: buildPagination(1, Number(query.limit ?? 20), 0),
      },
    };
  }

  const page = Math.max(1, Number(query.page ?? '1'));
  const limit = Math.min(100, Math.max(1, Number(query.limit ?? '20')));
  const total = Number((await dbClient('transactions').count<{ count: string }[]>('* as count').first())?.count ?? 0);
  const transactions = await dbClient('transactions').select('*').orderBy('created_at', 'desc').offset((page - 1) * limit).limit(limit);

  return {
    success: true,
    message: 'Transaction history retrieved successfully.',
    data: {
      transactions: transactions.map((record) => record as Record<string, unknown>),
      pagination: buildPagination(page, limit, total),
    },
  };
}

export async function listCommissions(dbClient: Knex = db, query: Record<string, unknown> = {}): Promise<AdminResponse<{ commissions: Record<string, unknown>[]; pagination: PaginationMeta }>> {
  const hasTable = await tableExists(dbClient, 'commission_ledger');
  if (!hasTable) {
    return {
      success: true,
      message: 'Platform commission ledger is not configured in the current schema.',
      data: {
        commissions: [],
        pagination: buildPagination(1, Number(query.limit ?? 20), 0),
      },
    };
  }

  const page = Math.max(1, Number(query.page ?? '1'));
  const limit = Math.min(100, Math.max(1, Number(query.limit ?? '20')));
  const total = Number((await dbClient('commission_ledger').count<{ count: string }[]>('* as count').first())?.count ?? 0);
  const commissions = await dbClient('commission_ledger').select('*').orderBy('created_at', 'desc').offset((page - 1) * limit).limit(limit);

  return {
    success: true,
    message: 'Commission information retrieved successfully.',
    data: {
      commissions: commissions.map((record) => record as Record<string, unknown>),
      pagination: buildPagination(page, limit, total),
    },
  };
}

export async function listDisputes(dbClient: Knex = db, query: Record<string, unknown> = {}): Promise<AdminResponse<{ disputes: Record<string, unknown>[]; pagination: PaginationMeta }>> {
  const hasTable = await tableExists(dbClient, 'disputes');
  if (!hasTable) {
    return {
      success: true,
      message: 'Dispute records are not configured in the current schema.',
      data: {
        disputes: [],
        pagination: buildPagination(1, Number(query.limit ?? 20), 0),
      },
    };
  }

  const page = Math.max(1, Number(query.page ?? '1'));
  const limit = Math.min(100, Math.max(1, Number(query.limit ?? '20')));
  const total = Number((await dbClient('disputes').count<{ count: string }[]>('* as count').first())?.count ?? 0);
  const disputes = await dbClient('disputes').select('*').orderBy('created_at', 'desc').offset((page - 1) * limit).limit(limit);

  return {
    success: true,
    message: 'Disputes retrieved successfully.',
    data: {
      disputes: disputes.map((record) => record as Record<string, unknown>),
      pagination: buildPagination(page, limit, total),
    },
  };
}

export async function getDisputeById(dbClient: Knex = db, disputeId: string): Promise<AdminResponse<Record<string, unknown>>> {
  const hasTable = await tableExists(dbClient, 'disputes');
  if (!hasTable) {
    throw new Error('DISPUTES_NOT_CONFIGURED');
  }

  const dispute = await dbClient('disputes').where({ id: disputeId }).first();
  if (!dispute) {
    throw new Error('DISPUTE_NOT_FOUND');
  }

  return {
    success: true,
    message: 'Dispute retrieved successfully.',
    data: dispute as Record<string, unknown>,
  };
}

export async function resolveDispute(dbClient: Knex = db, disputeId: string, actorId: string): Promise<AdminResponse<Record<string, unknown>>> {
  const hasTable = await tableExists(dbClient, 'disputes');
  if (!hasTable) {
    throw new Error('DISPUTES_NOT_CONFIGURED');
  }

  const dispute = await dbClient('disputes').where({ id: disputeId }).first();
  if (!dispute) {
    throw new Error('DISPUTE_NOT_FOUND');
  }

  await dbClient('disputes').where({ id: disputeId }).update({ status: 'RESOLVED', resolved_by: actorId, resolved_at: new Date() });
  await logAudit(dbClient, actorId, ADMIN_AUDIT_ACTIONS.DISPUTE_RESOLVED, 'Dispute', disputeId, { disputeStatus: 'RESOLVED' });

  const updated = await dbClient('disputes').where({ id: disputeId }).first();
  return {
    success: true,
    message: 'Dispute resolved successfully.',
    data: updated as Record<string, unknown>,
  };
}

export async function rejectDispute(dbClient: Knex = db, disputeId: string, actorId: string): Promise<AdminResponse<Record<string, unknown>>> {
  const hasTable = await tableExists(dbClient, 'disputes');
  if (!hasTable) {
    throw new Error('DISPUTES_NOT_CONFIGURED');
  }

  const dispute = await dbClient('disputes').where({ id: disputeId }).first();
  if (!dispute) {
    throw new Error('DISPUTE_NOT_FOUND');
  }

  await dbClient('disputes').where({ id: disputeId }).update({ status: 'REJECTED', resolved_by: actorId, resolved_at: new Date() });
  await logAudit(dbClient, actorId, ADMIN_AUDIT_ACTIONS.DISPUTE_REJECTED, 'Dispute', disputeId, { disputeStatus: 'REJECTED' });

  const updated = await dbClient('disputes').where({ id: disputeId }).first();
  return {
    success: true,
    message: 'Dispute rejected successfully.',
    data: updated as Record<string, unknown>,
  };
}

export async function listAuditLogs(dbClient: Knex = db, query: Record<string, unknown> = {}): Promise<AdminResponse<{ auditLogs: Record<string, unknown>[]; pagination: PaginationMeta }>> {
  const page = Math.max(1, Number(query.page ?? '1'));
  const limit = Math.min(100, Math.max(1, Number(query.limit ?? '20')));
  const userId = typeof query.userId === 'string' ? query.userId : undefined;
  const action = typeof query.action === 'string' ? query.action : undefined;

  let queryBuilder = dbClient('audit_logs').select('*');
  if (userId) queryBuilder = queryBuilder.where('user_id', userId);
  if (action) queryBuilder = queryBuilder.where('action', action);

  const total = Number((await queryBuilder.clone().count<{ count: string }[]>('* as count').first())?.count ?? 0);
  const auditLogs = await queryBuilder.orderBy('created_at', 'desc').offset((page - 1) * limit).limit(limit);

  return {
    success: true,
    message: 'Audit logs retrieved successfully.',
    data: {
      auditLogs: auditLogs.map((record) => record as Record<string, unknown>),
      pagination: buildPagination(page, limit, total),
    },
  };
}

export async function getAdminAnalytics(dbClient: Knex = db, from?: string, to?: string): Promise<AdminResponse<Record<string, unknown>>> {
  const userStatus = await dbClient('users').select('role', 'is_verified').select(dbClient.raw('COUNT(*)::int as "count"')).groupBy('role', 'is_verified');
  const loadsStatus = await tableExists(dbClient, 'loads') ? dbClient('loads').select('status').select(dbClient.raw('COUNT(*)::int as "count"')).groupBy('status') : [];
  const vehiclesCount = await tableExists(dbClient, 'vehicles') ? dbClient('vehicles').count<{ count: string }[]>('* as count').first() : { count: '0' };

  const analytics: Record<string, unknown> = {
    usersByRole: userStatus,
    usersByStatus: [
      { status: 'ACTIVE', count: Number((await dbClient('users').where({ is_verified: true }).count<{ count: string }[]>('* as count').first())?.count ?? 0) },
      { status: 'INACTIVE', count: Number((await dbClient('users').where({ is_verified: false }).count<{ count: string }[]>('* as count').first())?.count ?? 0) },
    ],
    loadsByStatus: loadsStatus,
    totalVehicles: Number(vehiclesCount?.count ?? 0),
    totalUsers: Number((await dbClient('users').count<{ count: string }[]>('* as count').first())?.count ?? 0),
  };

  if (from || to) {
    analytics.dateRange = { from: from ?? null, to: to ?? null };
  }

  return {
    success: true,
    message: 'Analytics retrieved successfully.',
    data: analytics,
  };
}

export async function getSystemHealth(dbClient: Knex = db): Promise<AdminResponse<Record<string, unknown>>> {
  let databaseStatus = 'not configured';

  try {
    await dbClient.raw('SELECT 1');
    databaseStatus = 'healthy';
  } catch {
    databaseStatus = 'unavailable';
  }

  return {
    success: true,
    message: 'System health retrieved successfully.',
    data: {
      api: 'healthy',
      database: databaseStatus,
      redis: 'not configured',
      socketIo: 'not configured',
      paymentGateway: 'not configured',
    },
  };
}
