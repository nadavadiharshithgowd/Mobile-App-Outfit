import { apiClient } from './client';
import type {
  OTPRequest,
  OTPVerifyRequest,
  GoogleAuthRequest,
  AuthResponse,
  User,
} from '@/types/auth.types';

export const authAPI = {
  sendOTP: (data: OTPRequest) =>
    apiClient.post('/auth/email/send-otp/', data),

  verifyOTP: (data: OTPVerifyRequest) =>
    apiClient.post<AuthResponse>('/auth/email/verify-otp/', data),

  // DEV ONLY — direct email + password login/register (backend returns 403 in production)
  devLogin: (data: { email: string; password: string }) =>
    apiClient.post<AuthResponse>('/auth/dev-login/', data),

  devRegister: (data: { email: string; password: string }) =>
    apiClient.post<AuthResponse & { created: boolean }>('/auth/dev-register/', data),

  googleAuth: (data: GoogleAuthRequest) =>
    apiClient.post<AuthResponse>('/auth/google/', data),

  getMe: () =>
    apiClient.get<User>('/auth/me/'),

  refreshToken: (refresh: string) =>
    apiClient.post<{ access: string }>('/auth/token/refresh/', { refresh }),
};
