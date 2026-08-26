import 'package:dio/dio.dart';

import 'app_exception.dart';

/// Converts low-level failures into user-facing [AppException]s.
abstract final class ErrorMapper {
  static AppException fromObject(Object error) {
    if (error is AppException) return error;
    if (error is DioException) return fromDio(error);
    return const UnexpectedException();
  }

  static AppException fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        return fromStatusCode(error.response?.statusCode);
      case DioExceptionType.cancel:
        return const UnexpectedException('Request was cancelled.');
      case DioExceptionType.badCertificate:
        return const NetworkException(
          'Secure connection failed. Please try again.',
        );
      case DioExceptionType.unknown:
        return const UnexpectedException();
      case DioExceptionType.transformTimeout:
        return const TimeoutException();
    }
  }

  static AppException fromStatusCode(int? statusCode) {
    switch (statusCode) {
      case 401:
        return const UnauthorizedException();
      case 403:
        return const ForbiddenException();
      case 404:
        return const NotFoundException();
      case 408:
        return const TimeoutException();
      case 500:
      case 502:
      case 503:
        return const ServerException();
      default:
        return const UnexpectedException();
    }
  }
}
