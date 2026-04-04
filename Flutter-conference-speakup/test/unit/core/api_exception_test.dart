import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_conference_speakup/core/network/api_exception.dart';

void main() {
  group('ApiException', () {
    test('fromDioException handles connectionTimeout', () {
      final e = ApiException.fromDioException(
        DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );
      expect(e.message, contains('timed out'));
      expect(e.statusCode, 408);
    });

    test('fromDioException handles sendTimeout', () {
      final e = ApiException.fromDioException(
        DioException(
          type: DioExceptionType.sendTimeout,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );
      expect(e.message, contains('timed out'));
    });

    test('fromDioException handles receiveTimeout', () {
      final e = ApiException.fromDioException(
        DioException(
          type: DioExceptionType.receiveTimeout,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );
      expect(e.message, contains('timed out'));
    });

    test('fromDioException handles badResponse with message', () {
      final e = ApiException.fromDioException(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 404,
            data: {'message': 'User not found'},
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        ),
      );
      expect(e.message, 'User not found');
      expect(e.statusCode, 404);
    });

    test('fromDioException handles badResponse without message', () {
      final e = ApiException.fromDioException(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 500,
            data: 'plain text error',
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        ),
      );
      expect(e.message, 'Something went wrong');
      expect(e.statusCode, 500);
    });

    test('fromDioException handles cancel', () {
      final e = ApiException.fromDioException(
        DioException(
          type: DioExceptionType.cancel,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );
      expect(e.message, 'Request cancelled');
    });

    test('fromDioException handles connectionError', () {
      final e = ApiException.fromDioException(
        DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );
      expect(e.message, 'No internet connection');
      expect(e.statusCode, 0);
    });

    test('toString includes statusCode and message', () {
      const e = ApiException(message: 'Test error', statusCode: 400);
      expect(e.toString(), 'ApiException(400): Test error');
    });
  });

  group('ApiResult', () {
    test('success contains data', () {
      final result = ApiResult.success('hello');
      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.data, 'hello');
    });

    test('failure contains error', () {
      const error = ApiException(message: 'fail');
      final result = ApiResult<String>.failure(error);
      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.error?.message, 'fail');
    });

    test('when calls success branch', () {
      final result = ApiResult.success(42);
      final value = result.when(
        success: (data) => 'got $data',
        failure: (error) => 'error',
      );
      expect(value, 'got 42');
    });

    test('when calls failure branch', () {
      const error = ApiException(message: 'fail');
      final result = ApiResult<int>.failure(error);
      final value = result.when(
        success: (data) => 'got $data',
        failure: (error) => 'error: ${error.message}',
      );
      expect(value, 'error: fail');
    });
  });
}
