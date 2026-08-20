import { Navigate, Outlet } from 'react-router-dom';
import type { ReactNode } from 'react';
import type { BackendRole } from '../types/person2';
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

  // Support both patterns:
  //  1. <ProtectedRoute ...><SomeComponent /></ProtectedRoute>  (children prop)
  //  2. <ProtectedRoute .../>  inside a Route element prop (Outlet pattern)
  return children ? <>{children}</> : <Outlet />;
}
