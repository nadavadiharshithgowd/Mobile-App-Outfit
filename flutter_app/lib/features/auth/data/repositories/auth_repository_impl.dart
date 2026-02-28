import '../../../../core/storage/secure_storage.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final SecureStorage _secureStorage;

  AuthRepository({
    required AuthRemoteDatasource remoteDatasource,
    required SecureStorage secureStorage,
  })  : _remoteDatasource = remoteDatasource,
        _secureStorage = secureStorage;

  Future<void> sendOtp(String email) async {
    await _remoteDatasource.sendOtp(email);
  }

  Future<UserModel> verifyOtp(String email, String otp) async {
    final response = await _remoteDatasource.verifyOtp(email, otp);
    await _saveAuthData(response);
    return response.user;
  }

  Future<UserModel> googleSignIn(String idToken) async {
    final response = await _remoteDatasource.googleSignIn(idToken);
    await _saveAuthData(response);
    return response.user;
  }

  Future<UserModel> getCurrentUser() async {
    return await _remoteDatasource.getCurrentUser();
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    return await _remoteDatasource.updateProfile(data);
  }

  Future<bool> isAuthenticated() async {
    return await _secureStorage.hasTokens();
  }

  Future<void> logout() async {
    await _secureStorage.clearAll();
  }

  Future<void> _saveAuthData(AuthResponse response) async {
    await _secureStorage.saveTokens(
      accessToken: response.tokens.accessToken,
      refreshToken: response.tokens.refreshToken,
    );
    await _secureStorage.saveUserId(response.user.id);
    await _secureStorage.saveUserEmail(response.user.email);
  }
}
