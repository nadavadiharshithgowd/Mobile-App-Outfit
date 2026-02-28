import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/user_model.dart';
import '../models/auth_token_model.dart';

class AuthRemoteDatasource {
  final ApiClient _apiClient;

  AuthRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<void> sendOtp(String email) async {
    await _apiClient.post(
      ApiEndpoints.sendOtp,
      data: {'email': email},
    );
  }

  Future<AuthResponse> verifyOtp(String email, String otp) async {
    final response = await _apiClient.post(
      ApiEndpoints.verifyOtp,
      data: {'email': email, 'otp': otp},
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResponse> googleSignIn(String idToken) async {
    final response = await _apiClient.post(
      ApiEndpoints.googleAuth,
      data: {'id_token': idToken},
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get(ApiEndpoints.me);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiClient.patch(
      ApiEndpoints.me,
      data: data,
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}

class AuthResponse {
  final AuthTokenModel tokens;
  final UserModel user;

  const AuthResponse({required this.tokens, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      tokens: AuthTokenModel.fromJson(json),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
