import { createContext, ReactNode, useState, useEffect, useCallback, useContext } from 'react';
import { get, post } from '../services/api';
import {
  clearSession,
  getStoredToken,
  getStoredUser,
  logoutUser,
  persistSession,
} from '../services/authService';
import type { AuthUser } from '../types/person2';

export type User = AuthUser;

interface AuthContextType {
  user: User | null;
  token: string | null;
  isLoading: boolean;
  login: (identifier: string, password: string) => Promise<User>;
  register: (payload: FormData | Record<string, any>) => Promise<{ user?: any }>;
  verifyOtp: (identifier: string, otpCode: string) => Promise<User>;
  logout: () => void;
}

export const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(() => getStoredUser());
  const [token, setToken] = useState<string | null>(() => getStoredToken());
  const [isLoading, setIsLoading] = useState<boolean>(true);

  const fetchUserProfile = useCallback(async () => {
    try {
      const userData = await get<User>('/auth/me');
      if (userData) {
        const currentToken = getStoredToken() ?? '';
        persistSession(currentToken, userData);
        setUser(userData);
      }
    } catch {
      clearSession();
      setToken(null);
      setUser(null);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    if (token) {
      fetchUserProfile();
    } else {
      setIsLoading(false);
    }
  }, [token, fetchUserProfile]);

  const login = async (identifier: string, password: string): Promise<User> => {
    const isEmail = identifier.includes('@');
    const body = isEmail ? { email: identifier, password } : { phone_number: identifier, password };
    const data = await post<{ user: User; token: string }>('/auth/login', body);
    persistSession(data.token, data.user);
    setToken(data.token);
    setUser(data.user);
    return data.user;
  };

  const register = async (payload: FormData | Record<string, any>) => {
    let data: { user?: any; token?: string; demo_otp?: string };
    if (payload instanceof FormData) {
      const apiBase = import.meta.env.VITE_API_URL || '/api';
      const token = localStorage.getItem('hf_token');
      const response = await fetch(`${apiBase}/auth/register`, {
        method: 'POST',
        headers: {
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
        body: payload,
      });
      const json = await response.json();
      if (!response.ok) {
        throw new Error(json.message || 'Registration failed.');
      }
      data = json.data || json;
    } else {
      data = await post<{ user?: any; token?: string; demo_otp?: string }>(
        '/auth/register',
        payload
      );
    }
    if (data.token && data.user) {
      persistSession(data.token, data.user);
      setToken(data.token);
      setUser(data.user);
    }
    return data;
  };

  const verifyOtp = async (identifier: string, otpCode: string): Promise<User> => {
    const isEmail = identifier.includes('@');
    const body = isEmail
      ? { email: identifier, otp_code: otpCode }
      : { phone_number: identifier, otp_code: otpCode };
    const data = await post<{ user: User; token: string }>('/auth/verify-otp', body);
    persistSession(data.token, data.user);
    setToken(data.token);
    setUser(data.user);
    return data.user;
  };

  const logout = () => {
    void logoutUser().catch(() => undefined);
    clearSession();
    setToken(null);
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, token, isLoading, login, register, verifyOtp, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}