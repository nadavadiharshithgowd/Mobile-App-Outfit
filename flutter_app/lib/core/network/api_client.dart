import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import 'auth_interceptor.dart';
import 'api_exceptions.dart';

class ApiClient {
  late final Dio _dio;
  final AuthInterceptor _authInterceptor;

  ApiClient({required AuthInterceptor authInterceptor})
      : _authInterceptor = authInterceptor {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.addAll([
      _authInterceptor,
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => dev.log('$obj', name: 'API'),
      ),
    ]);
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> uploadToPresignedUrl(
    String presignedUrl,
    List<int> fileBytes,
    String contentType, {
    void Function(int, int)? onSendProgress,
  }) async {
    final uploadDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    try {
      return await uploadDio.put(
        presignedUrl,
        data: Stream.fromIterable([fileBytes]),
        options: Options(
          headers: {
            'Content-Type': contentType,
            'Content-Length': fileBytes.length,
          },
        ),
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
