
import { createContext, ReactNode, useState, useEffect, useCallback, useContext } from 'react';
import { get, post } from '../services/api';

export interface User {
  id: string;
  full_name: string;
  phone_number: string;
  email?: string;
  role: 'SHIPPER' | 'DRIVER' | 'FLEET_OWNER' | 'ADMIN';
  is_verified: boolean;
  status: string;
  kyc_status?: string;
}

interface AuthContextType {
  user: User | null;
  token: string | null;
  isLoading: boolean;
  login: (phoneNumber: string, password: string) => Promise<User>;
  register: (fullName: string, phoneNumber: string, password: string, role: string) => Promise<{ user?: any; demo_otp?: string }>;
  verifyOtp: (phoneNumber: string, otpCode: string) => Promise<User>;
  logout: () => void;
}

export const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(() => {
    const raw = localStorage.getItem('hf_user');
    if (!raw) return null;
    try { return JSON.parse(raw) as User; } catch { return null; }
  });
  const [token, setToken] = useState<string | null>(() => localStorage.getItem('hf_token'));
  const [isLoading, setIsLoading] = useState<boolean>(true);

  const fetchUserProfile = useCallback(async () => {
    try {
      // get() unwraps the backend envelope → returns the User directly
      const userData = await get<User>('/auth/me');
      if (userData) {
        setUser(userData);
        localStorage.setItem('hf_user', JSON.stringify(userData));
      }
    } catch {
      localStorage.removeItem('hf_token');
      localStorage.removeItem('hf_user');
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

  const login = async (phoneNumber: string, password: string): Promise<User> => {
    // post() unwraps the envelope → returns { user, token }
    const data = await post<{ user: User; token: string }>('/auth/login', {
      phone_number: phoneNumber,
      password,
    });
    const authToken = data.token;
    localStorage.setItem('hf_token', authToken);
    localStorage.setItem('hf_user', JSON.stringify(data.user));
    setToken(authToken);
    setUser(data.user);
    return data.user;
  };

  const register = async (fullName: string, phoneNumber: string, password: string, role: string) => {
    // The register endpoint returns { user, demo_otp } (no token yet)
    const data = await post<{ user?: any; demo_otp?: string }>('/auth/register', {
      full_name: fullName,
      phone_number: phoneNumber,
      password,
      role,
    });
    return data;
  };

  const verifyOtp = async (phoneNumber: string, otpCode: string): Promise<User> => {
    const data = await post<{ user: User; token: string }>('/auth/verify-otp', {
      phone_number: phoneNumber,
      otp_code: otpCode,
    });
    const authToken = data.token;
    localStorage.setItem('hf_token', authToken);
    localStorage.setItem('hf_user', JSON.stringify(data.user));
    setToken(authToken);
    setUser(data.user);
    return data.user;
  };

  const logout = () => {
    setToken(null);
    setUser(null);
    localStorage.removeItem('hf_token');
    localStorage.removeItem('hf_user');
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