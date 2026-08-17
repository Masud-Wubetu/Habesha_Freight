import { createContext, ReactNode, useState, useContext } from 'react';
import { api } from '../services/api';

interface User {
  id: string;
  full_name: string;
  phone_number: string;
  role: 'shipper' | 'driver' | 'fleet_owner' | 'admin';
  is_verified: boolean;
}

interface AuthContextType {
  user: User | null;
  token: string | null;
  login: (phone_number: string, password: string) => Promise<void>;
  logout: () => void;
}

export const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(() => {
    const saved = localStorage.getItem('user');
    return saved ? JSON.parse(saved) : null;
  });
  const [token, setToken] = useState<string | null>(() => {
    return localStorage.getItem('token') || null;
  });

  const login = async (phone_number: string, password: string) => {
    try {
      const response = await api.post<{
        success: boolean;
        message: string;
        data: {
          token: string;
          user: User;
        };
      }>('/auth/login', { phone_number, password });

      if (response.success && response.data) {
        const { token, user } = response.data;
        setToken(token);
        setUser(user);
        localStorage.setItem('token', token);
        localStorage.setItem('user', JSON.stringify(user));
      } else {
        throw new Error(response.message || 'Login failed');
      }
    } catch (error: any) {
      throw new Error(error.message || 'Login failed. Please try again.');
    }
  };

  const logout = () => {
    setToken(null);
    setUser(null);
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  };

  return (
    <AuthContext.Provider value={{ user, token, login, logout }}>
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