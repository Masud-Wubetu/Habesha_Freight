import { api } from './api';
import type {
  AdminDashboardStats,
  AdminUser,
  ApiResponse,
  AuditLogRecord,
  KycRecord,
  LoadRecord,
  PaginatedData,
  VehicleRecord,
} from '../types/person2';

type QueryParams = Record<string, string | number | undefined>;

function toQuery(params?: QueryParams): string {
  if (!params) return '';
  const search = new URLSearchParams();
  Object.entries(params).forEach(([key, value]) => {
    if (value !== undefined && value !== '') search.set(key, String(value));
  });
  const q = search.toString();
  return q ? `?${q}` : '';
}

export const adminApi = {
  getDashboard: () =>
    api.get<ApiResponse<AdminDashboardStats>>('/admin/dashboard', true),

  getAnalytics: () => api.get<ApiResponse<Record<string, unknown>>>('/admin/analytics', true),

  getSystemHealth: () =>
    api.get<ApiResponse<Record<string, unknown>>>('/admin/system-health', true),

  listUsers: (params?: QueryParams) =>
    api.get<ApiResponse<PaginatedData<AdminUser>>>(`/admin/users${toQuery(params)}`, true),

  getUser: (id: string) => api.get<ApiResponse<AdminUser>>(`/admin/users/${id}`, true),

  updateUser: (id: string, data: Partial<AdminUser>) =>
    api.patch<ApiResponse<AdminUser>>(`/admin/users/${id}`, data, true),

  changeUserRole: (id: string, role: string) =>
    api.patch<ApiResponse<AdminUser>>(`/admin/users/${id}/role`, { role }, true),

  suspendUser: (id: string) =>
    api.post<ApiResponse<AdminUser>>(`/admin/users/${id}/suspend`, undefined, true),

  activateUser: (id: string) =>
    api.post<ApiResponse<AdminUser>>(`/admin/users/${id}/activate`, undefined, true),

  deleteUser: (id: string) =>
    api.delete<ApiResponse<AdminUser>>(`/admin/users/${id}`, true),

  listKyc: (params?: QueryParams) =>
    api.get<ApiResponse<PaginatedData<KycRecord>>>(`/admin/kyc${toQuery(params)}`, true),

  getKyc: (id: string) => api.get<ApiResponse<KycRecord>>(`/admin/kyc/${id}`, true),

  approveKyc: (id: string) =>
    api.post<ApiResponse<KycRecord>>(`/admin/kyc/${id}/approve`, undefined, true),

  rejectKyc: (id: string, reason: string) =>
    api.post<ApiResponse<KycRecord>>(`/admin/kyc/${id}/reject`, { reason }, true),

  listVehicles: (params?: QueryParams) =>
    api.get<ApiResponse<PaginatedData<VehicleRecord>>>(
      `/admin/vehicles${toQuery(params)}`,
      true
    ),

  getVehicle: (id: string) =>
    api.get<ApiResponse<VehicleRecord>>(`/admin/vehicles/${id}`, true),

  verifyVehicle: (id: string) =>
    api.post<ApiResponse<VehicleRecord>>(`/admin/vehicles/${id}/verify`, undefined, true),

  rejectVehicle: (id: string, reason: string) =>
    api.post<ApiResponse<VehicleRecord>>(
      `/admin/vehicles/${id}/reject`,
      { reason },
      true
    ),

  listLoads: (params?: QueryParams) =>
    api.get<ApiResponse<PaginatedData<LoadRecord>>>(`/admin/loads${toQuery(params)}`, true),

  getLoad: (id: string) => api.get<ApiResponse<LoadRecord>>(`/admin/loads/${id}`, true),

  updateLoad: (id: string, data: Partial<LoadRecord>) =>
    api.patch<ApiResponse<LoadRecord>>(`/admin/loads/${id}`, data, true),

  listAuditLogs: (params?: QueryParams) =>
    api.get<ApiResponse<PaginatedData<AuditLogRecord>>>(
      `/admin/audit-logs${toQuery(params)}`,
      true
    ),

  listEscrow: (params?: QueryParams) =>
    api.get<ApiResponse<PaginatedData<Record<string, unknown>>>>(
      `/admin/escrow${toQuery(params)}`,
      true
    ),

  listTransactions: (params?: QueryParams) =>
    api.get<ApiResponse<PaginatedData<Record<string, unknown>>>>(
      `/admin/transactions${toQuery(params)}`,
      true
    ),

  listDisputes: (params?: QueryParams) =>
    api.get<ApiResponse<PaginatedData<Record<string, unknown>>>>(
      `/admin/disputes${toQuery(params)}`,
      true
    ),
};
