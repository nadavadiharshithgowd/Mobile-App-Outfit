import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import '../constants/api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;

  AuthInterceptor({required SecureStorage storage}) : _storage = storage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final noAuthPaths = [
      ApiEndpoints.sendOtp,
      ApiEndpoints.verifyOtp,
      ApiEndpoints.googleAuth,
      ApiEndpoints.refreshToken,
    ];

    final requiresAuth = !noAuthPaths.any(
      (path) => options.path.contains(path),
    );

    if (requiresAuth) {
      final token = await _storage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Don't try to refresh if we're already refreshing
      if (err.requestOptions.path.contains(ApiEndpoints.refreshToken)) {
        handler.next(err);
        return;
      }

      final refreshed = await _refreshToken();
      if (refreshed) {
        final token = await _storage.getAccessToken();
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $token';

        try {
          // Use a Dio instance with the same baseUrl for retry
          final retryDio = Dio(BaseOptions(
            baseUrl: options.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ));
          final response = await retryDio.fetch(options);
          handler.resolve(response);
          return;
        } catch (_) {}
      }

      await _storage.clearTokens();
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) return false;

      final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
      final response = await dio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccess = response.data['access'] as String;
        await _storage.saveAccessToken(newAccess);
        return true;
      }
    } catch (_) {}
    return false;
  }
}
