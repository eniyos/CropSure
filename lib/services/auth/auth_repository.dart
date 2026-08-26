import '../../core/utils/result.dart';
import '../../models/auth_session.dart';

/// Auth contract. UI talks to [AuthController], which uses this repository.
///
/// Swap [MockAuthRepository] for a Dio-backed implementation when OpenAPI is ready.
abstract class AuthRepository {
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  });

  Future<Result<AuthSession>> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<Result<void>> requestPasswordReset({required String email});

  Future<Result<AuthSession?>> restoreSession();

  Future<Result<void>> logout();
}
