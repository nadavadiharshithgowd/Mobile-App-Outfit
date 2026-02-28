import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/hooks/useAuth';
import { Input } from '@/components/common/Input';
import { Button } from '@/components/common/Button';

interface OTPVerificationProps {
  email: string;
}

export const OTPVerification = ({ email }: OTPVerificationProps) => {
  const navigate = useNavigate();
  const { verifyOTP, verifyOTPLoading } = useAuth();
  const [otp, setOtp] = useState('');
  const [error, setError] = useState('');
  
  const handleVerify = async () => {
    try {
      setError('');
      
      await verifyOTP(
        { email, otp },
        {
          onSuccess: () => {
            navigate('/wardrobe');
          },
          onError: (err: any) => {
            console.error('OTP verification error:', err.response?.data);
            const errorMessage = err.response?.data?.detail || 
                               err.response?.data?.error?.message || 
                               err.response?.data?.message ||
                               'Invalid or expired OTP';
            setError(errorMessage);
          },
        }
      );
    } catch (err) {
      console.error('Unexpected error:', err);
      setError('An unexpected error occurred');
    }
  };
  
  return (
    <div className="space-y-4">
      <div className="text-center">
        <h3 className="text-lg font-semibold text-gray-900 mb-2">
          Verify Your Email
        </h3>
        <p className="text-sm text-gray-600">
          We've sent a verification code to <strong>{email}</strong>
        </p>
      </div>
      
      <Input
        label="Verification Code"
        type="text"
        placeholder="Enter 6-digit code"
        value={otp}
        onChange={(e) => setOtp(e.target.value)}
        maxLength={6}
      />
      
      {error && (
        <div className="p-3 bg-red-50 border border-red-200 rounded-lg">
          <p className="text-sm text-red-600">{error}</p>
        </div>
      )}
      
      <Button
        onClick={handleVerify}
        className="w-full"
        isLoading={verifyOTPLoading}
        disabled={otp.length !== 6}
      >
        Verify Email
      </Button>
    </div>
  );
};
