'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';
import { User } from '@/types';
import { api } from '@/lib/api';

interface AuthContextType {
  user: User | null;
  token: string | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<User>;
  register: (data: any) => Promise<User>;
  logout: () => Promise<void>;
  updateUser: (updatedData: Partial<User>) => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Initialize session from stored token
  useEffect(() => {
    async function loadUser() {
      const storedToken = localStorage.getItem('vbrs_access_token');
      if (storedToken) {
        setToken(storedToken);
        try {
          const profile = await api.get<User>('/auth/me');
          setUser(profile);
        } catch (err) {
          console.error('Session restoration failed:', err);
          localStorage.removeItem('vbrs_access_token');
          localStorage.removeItem('vbrs_refresh_token');
          setUser(null);
          setToken(null);
        }
      }
      setIsLoading(false);
    }

    loadUser();
  }, []);

  const login = async (email: string, password: string): Promise<User> => {
    setIsLoading(true);
    try {
      const response = await api.post<{ user: User; tokens: { accessToken: string; refreshToken: string } }>(
        '/auth/login',
        { email, password }
      );

      localStorage.setItem('vbrs_access_token', response.tokens.accessToken);
      localStorage.setItem('vbrs_refresh_token', response.tokens.refreshToken);
      setToken(response.tokens.accessToken);
      setUser(response.user);
      return response.user;
    } finally {
      setIsLoading(false);
    }
  };

  const register = async (data: any): Promise<User> => {
    setIsLoading(true);
    try {
      const response = await api.post<{ user: User; tokens: { accessToken: string; refreshToken: string } }>(
        '/auth/register',
        data
      );

      localStorage.setItem('vbrs_access_token', response.tokens.accessToken);
      localStorage.setItem('vbrs_refresh_token', response.tokens.refreshToken);
      setToken(response.tokens.accessToken);
      setUser(response.user);
      return response.user;
    } finally {
      setIsLoading(false);
    }
  };

  const logout = async () => {
    try {
      const refreshToken = localStorage.getItem('vbrs_refresh_token');
      await api.post('/auth/logout', { refreshToken }).catch(() => {});
    } finally {
      localStorage.removeItem('vbrs_access_token');
      localStorage.removeItem('vbrs_refresh_token');
      setUser(null);
      setToken(null);
      window.location.href = '/login';
    }
  };

  const updateUser = (updatedData: Partial<User>) => {
    if (user) {
      setUser({ ...user, ...updatedData });
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        isLoading,
        isAuthenticated: !!user,
        login,
        register,
        logout,
        updateUser,
      }}
    >
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
