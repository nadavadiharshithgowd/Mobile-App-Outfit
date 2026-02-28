import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timed out. Please try again.',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);
      case DioExceptionType.cancel:
        return ApiException(message: 'Request was cancelled.');
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection. Please check your network.',
        );
      default:
        return ApiException(
          message: 'An unexpected error occurred.',
          statusCode: error.response?.statusCode,
        );
    }
  }

  static ApiException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    String message;
    if (data is Map && data.containsKey('detail')) {
      message = data['detail'].toString();
    } else if (data is Map && data.containsKey('message')) {
      message = data['message'].toString();
    } else {
      switch (statusCode) {
        case 400:
          message = 'Invalid request. Please check your input.';
          break;
        case 401:
          message = 'Unauthorized. Please sign in again.';
          break;
        case 403:
          message = 'Access denied.';
          break;
        case 404:
          message = 'Resource not found.';
          break;
        case 422:
          message = 'Validation error.';
          break;
        case 429:
          message = 'Too many requests. Please wait a moment.';
          break;
        case 500:
          message = 'Server error. Please try again later.';
          break;
        default:
          message = 'Something went wrong.';
      }
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: data,
    );
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
