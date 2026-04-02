import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Connection timed out. Please try again.',
          statusCode: 408,
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        String message = 'Something went wrong';
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          message = data['message'].toString();
        }
        return ApiException(
          message: message,
          statusCode: statusCode,
          data: data,
        );
      case DioExceptionType.cancel:
        return const ApiException(message: 'Request cancelled');
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'No internet connection',
          statusCode: 0,
        );
      default:
        return ApiException(message: e.message ?? 'Unexpected error');
    }
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Standardized API result wrapper.
class ApiResult<T> {
  final T? data;
  final ApiException? error;

  const ApiResult._({this.data, this.error});

  factory ApiResult.success(T data) => ApiResult._(data: data);
  factory ApiResult.failure(ApiException error) => ApiResult._(error: error);

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  R when<R>({
    required R Function(T data) success,
    required R Function(ApiException error) failure,
  }) {
    if (isSuccess) return success(data as T);
    return failure(error!);
  }
}
