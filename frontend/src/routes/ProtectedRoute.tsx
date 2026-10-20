import { Navigate, Outlet, useLocation } from 'react-router-dom';
import type { ReactNode } from 'react';
import type { BackendRole } from '../types/person2';
import { useAuth } from '../context/AuthContext';
import { getStoredToken, getStoredUser } from '../services/authService';

interface ProtectedRouteProps {
  allowedRoles: BackendRole[];
  redirectTo?: string;
  children?: ReactNode;
}

export default function ProtectedRoute({
  allowedRoles,
  redirectTo = '/login',
  children,
}: ProtectedRouteProps) {
  const { user: ctxUser, token: ctxToken, isLoading } = useAuth();
  const token = ctxToken ?? getStoredToken();
  const user = ctxUser ?? getStoredUser();
  const location = useLocation();

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[var(--hf-bg,#0b1220)] text-[var(--hf-muted,#94a3b8)]">
        Loading secure session…
      </div>
    );
  }

  if (!token || !user) {
    return <Navigate to={redirectTo} replace state={{ from: location }} />;
  }

  // Determine if driver/fleet owner is approved by Admin
  const isDriverOrFleet = user.role === 'DRIVER' || user.role === 'FLEET_OWNER';
  const isApproved =
    user.kyc_status === 'APPROVED' || user.status === 'ACTIVE';

  const isPendingAdminApproval = isDriverOrFleet && !isApproved;

  if (isPendingAdminApproval && location.pathname !== '/pending-approval') {
    return <Navigate to="/pending-approval" replace />;
  }

  if (!allowedRoles.includes(user.role)) {
    const roleHome: Record<BackendRole, string> = {
      DRIVER: '/driver',
      FLEET_OWNER: '/company',
      ADMIN: '/admin',
      SHIPPER: '/dashboard',
    };
    return <Navigate to={roleHome[user.role] ?? '/'} replace />;
  }

  return children ? <>{children}</> : <Outlet />;
}
