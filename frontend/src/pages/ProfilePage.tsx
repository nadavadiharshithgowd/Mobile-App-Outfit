import { useState } from 'react';
import { User, Mail, Camera, Save, Shield, Bell, LogOut } from 'lucide-react';
import { useAuth } from '@/hooks/useAuth';
import { Button } from '@/components/common/Button';
import { Input } from '@/components/common/Input';
import { useToast } from '@/components/common/Toast';
import { useNavigate } from 'react-router-dom';
import { apiClient } from '@/api/client';

export const ProfilePage = () => {
  const { user, logout } = useAuth();
  const { success, error } = useToast();
  const navigate = useNavigate();

  const [displayName, setDisplayName] = useState(user?.full_name || '');
  const [isSaving, setIsSaving] = useState(false);

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);
    try {
      await apiClient.patch('/auth/me/', { full_name: displayName });
      success('Profile updated!');
    } catch {
      error('Failed to update profile.');
    } finally {
      setIsSaving(false);
    }
  };

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  const avatar = user?.email?.charAt(0).toUpperCase() || 'U';

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <h1 className="text-3xl font-bold text-gray-900">Profile</h1>
          <p className="text-gray-500 mt-1">Manage your account settings</p>
        </div>
      </div>

      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-6">
        {/* Avatar + basic info */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
          <div className="flex items-center gap-5 mb-6">
            <div className="relative">
              <div className="w-20 h-20 rounded-full bg-gradient-to-br from-primary-400 to-purple-500 flex items-center justify-center text-3xl font-bold text-white">
                {avatar}
              </div>
            </div>
            <div>
              <h2 className="text-xl font-bold text-gray-900">
                {user?.full_name || user?.email?.split('@')[0]}
              </h2>
              <p className="text-gray-500 flex items-center gap-1.5 mt-0.5">
                <Mail className="h-4 w-4" />
                {user?.email}
              </p>
              {user?.auth_provider === 'google' && (
                <span className="mt-1.5 inline-flex items-center gap-1 text-xs bg-blue-50 text-blue-600 px-2.5 py-0.5 rounded-full font-medium">
                  Google Account
                </span>
              )}
            </div>
          </div>

          <form onSubmit={handleSave} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Display Name
              </label>
              <Input
                value={displayName}
                onChange={(e) => setDisplayName(e.target.value)}
                placeholder="Your display name"
                leftIcon={<User className="h-4 w-4 text-gray-400" />}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Email Address
              </label>
              <Input
                value={user?.email || ''}
                disabled
                className="bg-gray-50 text-gray-500"
                leftIcon={<Mail className="h-4 w-4 text-gray-400" />}
              />
              <p className="text-xs text-gray-400 mt-1">Email cannot be changed.</p>
            </div>
            <div className="flex justify-end">
              <Button type="submit" isLoading={isSaving}>
                <Save className="h-4 w-4 mr-2" />
                Save Changes
              </Button>
            </div>
          </form>
        </div>

        {/* Account stats */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
          <h3 className="font-semibold text-gray-900 mb-4">Account Stats</h3>
          <div className="grid grid-cols-3 gap-4 text-center">
            {[
              { label: 'Wardrobe Items', value: user?.wardrobe_count ?? '—' },
              { label: 'Outfits', value: user?.outfit_count ?? '—' },
              { label: 'Try-Ons', value: user?.tryon_count ?? '—' },
            ].map(({ label, value }) => (
              <div key={label} className="bg-gray-50 rounded-xl p-4">
                <p className="text-2xl font-bold text-gray-900">{value}</p>
                <p className="text-xs text-gray-500 mt-1">{label}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Security */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
          <h3 className="font-semibold text-gray-900 mb-4 flex items-center gap-2">
            <Shield className="h-4 w-4 text-gray-400" />
            Security
          </h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between py-3 border-b border-gray-50">
              <div>
                <p className="text-sm font-medium text-gray-700">Authentication</p>
                <p className="text-xs text-gray-400">
                  {user?.auth_provider === 'google'
                    ? 'Signed in with Google OAuth'
                    : 'Email OTP authentication'}
                </p>
              </div>
              <span className="text-xs bg-green-100 text-green-700 px-2.5 py-1 rounded-full font-medium">
                Active
              </span>
            </div>
            <div className="flex items-center justify-between py-3">
              <div>
                <p className="text-sm font-medium text-gray-700">Member since</p>
                <p className="text-xs text-gray-400">
                  {user?.date_joined
                    ? new Date(user.date_joined).toLocaleDateString('en-US', {
                        month: 'long',
                        year: 'numeric',
                      })
                    : '—'}
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Danger zone */}
        <div className="bg-white rounded-2xl border border-red-100 shadow-sm p-6">
          <h3 className="font-semibold text-gray-900 mb-4">Account Actions</h3>
          <Button
            variant="ghost"
            className="text-red-600 hover:bg-red-50 border border-red-200"
            onClick={handleLogout}
          >
            <LogOut className="h-4 w-4 mr-2" />
            Sign Out
          </Button>
        </div>
      </div>
    </div>
  );
};
