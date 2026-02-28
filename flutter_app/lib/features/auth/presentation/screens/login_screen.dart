import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/google_sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          context.go('/login/otp', extra: state.email);
        } else if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  // Logo
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.accentSurface,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.checkroom_rounded,
                        size: 40,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    AppStrings.getStarted,
                    style: AppTextStyles.h1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.appTagline,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  // Email Input
                  Text(
                    'Email',
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    decoration: const InputDecoration(
                      hintText: AppStrings.enterEmail,
                      prefixIcon: Icon(
                        Icons.mail_outline_rounded,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Send Code Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return PastelButton(
                        text: AppStrings.sendCode,
                        isLoading: state is AuthLoading,
                        width: double.infinity,
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            context.read<AuthBloc>().add(
                                  AuthSendOtp(_emailController.text.trim()),
                                );
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.divider)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppStrings.orContinueWith,
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.divider)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Google Sign In
                  GoogleSignInButton(
                    onPressed: () {
                      context
                          .read<AuthBloc>()
                          .add(const AuthGoogleSignIn());
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
