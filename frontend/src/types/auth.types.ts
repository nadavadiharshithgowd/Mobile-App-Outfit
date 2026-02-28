export interface User {
  id: string;
  email: string;
  full_name: string;
  profile_photo?: string;
  auth_provider: 'email' | 'google';
  date_joined: string;
  wardrobe_count?: number;
  outfit_count?: number;
  tryon_count?: number;
}

export interface AuthTokens {
  access: string;
  refresh: string;
}

export interface OTPRequest {
  email: string;
}

export interface OTPVerifyRequest {
  email: string;
  otp: string;
}

export interface GoogleAuthRequest {
  credential: string;
}

export interface AuthResponse {
  access: string;
  refresh: string;
  user?: User;
}
