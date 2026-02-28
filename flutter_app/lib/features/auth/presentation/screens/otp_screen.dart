import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OTPScreen extends StatefulWidget {
  final String? email;

  const OTPScreen({super.key, this.email});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _timer;
  int _countdown = 60;
  bool _canResend = false;

  String get _email => widget.email ?? '';

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdown = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: AppTextStyles.h2,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
    );

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is AuthOtpSent) {
          _startCountdown();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New code sent!')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.go('/login'),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  AppStrings.verifyCode,
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppStrings.enterOtp}\n$_email',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),
                // OTP Input
                Center(
                  child: Pinput(
                    controller: _otpController,
                    focusNode: _focusNode,
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.accent,
                          width: 2,
                        ),
                      ),
                    ),
                    submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: BoxDecoration(
                        color: AppColors.accentSurface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onCompleted: (pin) {
                      context.read<AuthBloc>().add(
                            AuthVerifyOtp(email: _email, otp: pin),
                          );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                // Verify Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return PastelButton(
                      text: AppStrings.verifyCode,
                      isLoading: state is AuthLoading,
                      width: double.infinity,
                      onPressed: () {
                        final otp = _otpController.text;
                        if (otp.length == 6) {
                          context.read<AuthBloc>().add(
                                AuthVerifyOtp(email: _email, otp: otp),
                              );
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Resend
                Center(
                  child: _canResend
                      ? TextButton(
                          onPressed: () {
                            context
                                .read<AuthBloc>()
                                .add(AuthSendOtp(_email));
                          },
                          child: const Text(AppStrings.resendCode),
                        )
                      : Text(
                          'Resend code in ${_countdown}s',
                          style: AppTextStyles.bodySmall,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
