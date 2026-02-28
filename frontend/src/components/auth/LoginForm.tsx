import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useAuthStore } from '@/store/authStore';
import { authAPI } from '@/api/auth';
import { Input } from '@/components/common/Input';
import { Button } from '@/components/common/Button';

const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(4, 'Password is required'),
});

type LoginFormData = z.infer<typeof loginSchema>;

export const LoginForm = () => {
  const navigate = useNavigate();
  const { login, setUser } = useAuthStore();
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginFormData) => {
    try {
      setError('');
      setIsLoading(true);

      const response = await authAPI.devLogin({
        email: data.email,
        password: data.password,
      });

      const { access, refresh, user } = response.data;
      login({ access, refresh }, user);
      if (user) setUser(user);

      navigate('/wardrobe');
    } catch (err: any) {
      const msg =
        err.response?.data?.detail ||
        err.response?.data?.error ||
        'Invalid email or password.';
      setError(msg);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <Input
        label="Email"
        type="email"
        placeholder="you@example.com"
        error={errors.email?.message}
        {...register('email')}
      />

      <Input
        label="Password"
        type="password"
        placeholder="••••••••"
        error={errors.password?.message}
        {...register('password')}
      />

      {error && (
        <div className="p-3 bg-red-50 border border-red-200 rounded-lg">
          <p className="text-sm text-red-600">{error}</p>
        </div>
      )}

      <Button type="submit" className="w-full" isLoading={isLoading}>
        Sign In
      </Button>
    </form>
  );
};
