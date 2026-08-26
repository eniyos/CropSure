import 'package:cropsure/core/errors/app_exception.dart';
import 'package:cropsure/core/errors/error_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps AppException unchanged', () {
    const original = NetworkException('offline');
    expect(ErrorMapper.fromObject(original), same(original));
  });

  test('maps Dio connection timeout', () {
    final mapped = ErrorMapper.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionTimeout,
      ),
    );
    expect(mapped, isA<TimeoutException>());
  });

  test('maps Dio connection error to NetworkException', () {
    final mapped = ErrorMapper.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionError,
      ),
    );
    expect(mapped, isA<NetworkException>());
  });

  test('maps unauthorized status', () {
    expect(ErrorMapper.fromStatusCode(401), isA<UnauthorizedException>());
  });
}
