import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}

class AuthSendOtp extends AuthEvent {
  final String email;
  const AuthSendOtp(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthVerifyOtp extends AuthEvent {
  final String email;
  final String otp;
  const AuthVerifyOtp({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class AuthGoogleSignIn extends AuthEvent {
  const AuthGoogleSignIn();
}

class AuthLogout extends AuthEvent {
  const AuthLogout();
}

class AuthUpdateProfile extends AuthEvent {
  final String? fullName;
  const AuthUpdateProfile({this.fullName});

  @override
  List<Object?> get props => [fullName];
}
