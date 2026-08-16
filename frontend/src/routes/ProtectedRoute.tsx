import { Navigate, Outlet } from 'react-router-dom';
import type { BackendRole } from '../types/person2';
import { getStoredToken, getStoredUser } from '../services/authService';

interface ProtectedRouteProps {
  allowedRoles: BackendRole[];
  redirectTo?: string;
}

export default function ProtectedRoute({
  allowedRoles,
  redirectTo = '/login',
}: ProtectedRouteProps) {
  const token = getStoredToken();
  const user = getStoredUser();

  if (!token || !user) {
    return <Navigate to={redirectTo} replace />;
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

  return <Outlet />;
}
