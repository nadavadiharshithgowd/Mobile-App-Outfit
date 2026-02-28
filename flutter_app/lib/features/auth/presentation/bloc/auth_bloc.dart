import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final GoogleSignIn _googleSignIn;

  AuthBloc({
    required AuthRepository authRepository,
    GoogleSignIn? googleSignIn,
  })  : _authRepository = authRepository,
        _googleSignIn = googleSignIn ?? _createGoogleSignIn(),
        super(const AuthInitial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthSendOtp>(_onSendOtp);
    on<AuthVerifyOtp>(_onVerifyOtp);
    on<AuthGoogleSignIn>(_onGoogleSignIn);
    on<AuthLogout>(_onLogout);
    on<AuthUpdateProfile>(_onUpdateProfile);
  }

  static GoogleSignIn _createGoogleSignIn() {
    if (kIsWeb) {
      // On web: clientId is set via meta tag in index.html
      // serverClientId is NOT supported on web
      return GoogleSignIn(scopes: ['email', 'profile']);
    } else {
      // On mobile: use serverClientId to get idToken
      return GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: AppConfig.googleWebClientId,
      );
    }
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        final user = await _authRepository.getCurrentUser();
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSendOtp(
    AuthSendOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.sendOtp(event.email);
      emit(AuthOtpSent(event.email));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('Failed to send verification code'));
    }
  }

  Future<void> _onVerifyOtp(
    AuthVerifyOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.verifyOtp(event.email, event.otp);
      emit(AuthAuthenticated(user));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('Invalid verification code'));
    }
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignIn event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      final auth = await account.authentication;
      // On web, idToken comes from the Google Identity Services flow
      // On mobile, idToken comes from serverClientId exchange
      final idToken = auth.idToken ?? auth.accessToken;

      if (idToken == null) {
        emit(const AuthError('Failed to get Google credentials'));
        return;
      }

      final user = await _authRepository.googleSignIn(idToken);
      emit(AuthAuthenticated(user));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Google sign-in failed: $e'));
    }
  }

  Future<void> _onLogout(
    AuthLogout event,
    Emitter<AuthState> emit,
  ) async {
    await _googleSignIn.signOut();
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onUpdateProfile(
    AuthUpdateProfile event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final data = <String, dynamic>{};
      if (event.fullName != null) data['full_name'] = event.fullName;
      if (data.isEmpty) return;

      final updatedUser = await _authRepository.updateProfile(data);
      emit(AuthAuthenticated(updatedUser));
    } catch (_) {
      // Keep existing state on failure
    }
  }
}
