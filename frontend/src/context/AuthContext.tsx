import {
  createContext,
  ReactNode,
  useState,
  useEffect,
  useCallback,
  useContext,
} from 'react';
import { api } from '../services/api';

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

interface AuthResponse {
  success: boolean;
  message: string;
  data: {
    user: User;
    token: string;
  };
}

interface UserProfileResponse {
  success: boolean;
  data: User;
}

interface AuthContextType {
  user: User | null;
  token: string | null;
  isLoading: boolean;
  login: (phoneNumber: string, password: string) => Promise<void>;
  register: (
    fullName: string,
    phoneNumber: string,
    password: string,
    role: string
  ) => Promise<void>;
  logout: () => void;
}

export const AuthContext = createContext<AuthContextType | undefined>(
  undefined
);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);

  const [token, setToken] = useState<string | null>(() =>
    localStorage.getItem('authToken')
  );

  const [isLoading, setIsLoading] = useState<boolean>(true);

  const fetchUserProfile = useCallback(async () => {
    try {
      const res = await api.get<UserProfileResponse>('/auth/me');

      if (res.success && res.data) {
        setUser(res.data);
      }
    } catch {
      // Token is invalid or expired.
      localStorage.removeItem('authToken');
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

  const login = async (
    phoneNumber: string,
    password: string
  ): Promise<void> => {
    const res = await api.post<AuthResponse>('/auth/login', {
      phone_number: phoneNumber,
      password,
    });

    if (res.success && res.data) {
      const authToken = res.data.token;

      localStorage.setItem('authToken', authToken);

      setToken(authToken);
      setUser(res.data.user);
    }
  };

  const register = async (
    fullName: string,
    phoneNumber: string,
    password: string,
    role: string
  ): Promise<void> => {
    const res = await api.post<AuthResponse>('/auth/register', {
      full_name: fullName,
      phone_number: phoneNumber,
      password,
      role,
    });

    if (res.success && res.data) {
      const authToken = res.data.token;

      localStorage.setItem('authToken', authToken);

      setToken(authToken);
      setUser(res.data.user);
    }
  };

  const logout = (): void => {
    setToken(null);
    setUser(null);

    localStorage.removeItem('authToken');
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        isLoading,
        login,
        register,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth(): AuthContextType {
  const context = useContext(AuthContext);

  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }

  return context;
}