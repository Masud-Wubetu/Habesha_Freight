import { api } from './api';
import type { ApiResponse, AuthUser } from '../types/person2';

const TOKEN_KEY = 'hf_token';
const USER_KEY = 'hf_user';

export function getStoredToken(): string | null {
  return localStorage.getItem(TOKEN_KEY);
}

export function getStoredUser(): AuthUser | null {
  const raw = localStorage.getItem(USER_KEY);
  if (!raw) return null;
  try {
    return JSON.parse(raw) as AuthUser;
  } catch {
    return null;
  }
}

export function persistSession(token: string, user: AuthUser): void {
  localStorage.setItem(TOKEN_KEY, token);
  localStorage.setItem(USER_KEY, JSON.stringify(user));
}

export function clearSession(): void {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(USER_KEY);
}

export async function loginWithPhone(
  phone_number: string,
  password: string
): Promise<{ token: string; user: AuthUser }> {
  const response = await api.post<ApiResponse<{ token: string; user: AuthUser }>>(
    '/auth/login',
    { phone_number, password }
  );
  persistSession(response.data.token, response.data.user);
  return response.data;
}

export async function fetchCurrentUser(): Promise<AuthUser> {
  const response = await api.get<ApiResponse<AuthUser>>('/auth/me', true);
  persistSession(getStoredToken() ?? '', response.data);
  return response.data;
}

export async function updateUserProfile(data: {
  full_name?: string;
  email?: string;
}): Promise<AuthUser> {
  const response = await api.patch<ApiResponse<AuthUser>>('/auth/profile', data, true);
  const token = getStoredToken();
  if (token) persistSession(token, response.data);
  return response.data;
}

export async function logoutUser(): Promise<void> {
  try {
    await api.post('/auth/logout', undefined, true);
  } finally {
    clearSession();
  }
}
