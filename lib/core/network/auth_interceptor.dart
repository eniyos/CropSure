import 'package:dio/dio.dart';

import '../constants/api_config.dart';

/// Attaches bearer tokens and surfaces 401 for session expiry handling.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({this.tokenProvider, this.onUnauthorized});

  final Future<String?> Function()? tokenProvider;
  final void Function()? onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      options.headers[ApiConfig.authHeader] =
          '${ApiConfig.bearerPrefix}$token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}
