import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useAuthStore } from '@/store/authStore';
import { authAPI } from '@/api/auth';
import type { OTPRequest, OTPVerifyRequest, GoogleAuthRequest } from '@/types/auth.types';

export const useAuth = () => {
  const queryClient = useQueryClient();
  const { user, isAuthenticated, login, logout, setUser, setLoading } = useAuthStore();
  
  const { data: currentUser, isLoading: isLoadingUser } = useQuery({
    queryKey: ['user', 'me'],
    queryFn: async () => {
      const response = await authAPI.getMe();
      return response.data;
    },
    enabled: isAuthenticated && !user,
    retry: false,
  });
  
  const sendOTPMutation = useMutation({
    mutationFn: (data: OTPRequest) => authAPI.sendOTP(data),
  });
  
  const verifyOTPMutation = useMutation({
    mutationFn: (data: OTPVerifyRequest) => authAPI.verifyOTP(data),
    onSuccess: (response) => {
      const { access, refresh, user } = response.data;
      login({ access, refresh }, user);
      if (user) {
        setUser(user);
      }
      queryClient.invalidateQueries({ queryKey: ['user'] });
    },
  });
  
  const googleAuthMutation = useMutation({
    mutationFn: (data: GoogleAuthRequest) => authAPI.googleAuth(data),
    onSuccess: (response) => {
      const { access, refresh, user } = response.data;
      login({ access, refresh }, user);
      if (user) {
        setUser(user);
      }
      queryClient.invalidateQueries({ queryKey: ['user'] });
    },
  });
  
  const logoutMutation = useMutation({
    mutationFn: async () => {
      logout();
      queryClient.clear();
    },
  });
  
  return {
    user: user || currentUser,
    isAuthenticated,
    isLoading: isLoadingUser,
    sendOTP: sendOTPMutation.mutate,
    verifyOTP: verifyOTPMutation.mutate,
    googleAuth: googleAuthMutation.mutate,
    logout: logoutMutation.mutate,
    sendOTPLoading: sendOTPMutation.isPending,
    verifyOTPLoading: verifyOTPMutation.isPending,
    googleAuthLoading: googleAuthMutation.isPending,
  };
};
