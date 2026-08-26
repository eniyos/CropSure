/// Typed application failures shown to users via friendly messages.
sealed class AppException implements Exception {
  const AppException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException([
    super.message =
        'No internet connection. Check your network and try again.',
    super.code,
  ]);
}

final class TimeoutException extends AppException {
  const TimeoutException([
    super.message = 'The request took too long. Please try again.',
    super.code,
  ]);
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Your session has expired. Please sign in again.',
    super.code = '401',
  ]);
}

final class ForbiddenException extends AppException {
  const ForbiddenException([
    super.message = 'You do not have permission to do that.',
    super.code = '403',
  ]);
}

final class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'We could not find what you were looking for.',
    super.code = '404',
  ]);
}

final class ServerException extends AppException {
  const ServerException([
    super.message =
        'Something went wrong on our side. Please try again later.',
    super.code = '500',
  ]);
}

final class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

final class UnexpectedException extends AppException {
  const UnexpectedException([
    super.message = 'Something unexpected happened. Please try again.',
    super.code,
  ]);
}

final class BackendUnavailableException extends AppException {
  const BackendUnavailableException([
    super.message =
        'The live API is not configured yet. Keep mock mode enabled or set a valid base URL.',
    super.code = 'backend_unavailable',
  ]);
}

final class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}
