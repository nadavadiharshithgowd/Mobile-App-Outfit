import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/cached_s3_image.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar
                GestureDetector(
                  onTap: () => context.go('/profile/edit'),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.accentSurface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accent,
                            width: 3,
                          ),
                        ),
                        child: user?.profilePhoto != null
                            ? ClipOval(
                                child: CachedS3Image(
                                  imageUrl: user!.profilePhoto,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 48,
                                color: AppColors.accent,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: AppColors.background,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? 'User',
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 32),

                // Stats row
                Row(
                  children: [
                    _StatCard(
                      icon: Icons.checkroom,
                      label: AppStrings.totalItems,
                      value: '0',
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      icon: Icons.style,
                      label: AppStrings.outfitsCreated,
                      value: '0',
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      icon: Icons.auto_awesome,
                      label: AppStrings.tryOns,
                      value: '0',
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Menu items
                _MenuItem(
                  icon: Icons.person_outline,
                  label: AppStrings.editProfile,
                  onTap: () => context.go('/profile/edit'),
                ),
                _MenuItem(
                  icon: Icons.history,
                  label: AppStrings.outfitHistory,
                  onTap: () => context.go('/profile/history'),
                ),
                _MenuItem(
                  icon: Icons.favorite_outline,
                  label: 'Saved Outfits',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                _MenuItem(
                  icon: Icons.logout,
                  label: AppStrings.logout,
                  isDestructive: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text('Logout'),
                        content: const Text(
                          'Are you sure you want to logout?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              context
                                  .read<AuthBloc>()
                                  .add(const AuthLogout());
                            },
                            child: Text(
                              'Logout',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accent, size: 24),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDestructive ? AppColors.error : AppColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDestructive ? AppColors.error : null,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
