import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../models/auth_session.dart';
import '../../models/user.dart';
import '../storage/session_storage.dart';
import 'auth_repository.dart';

/// Development-only auth. Isolated from production API services.
///
/// Accepts the demo credentials, or any valid email + password (≥8 chars)
/// for registration / login during UI development.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._sessionStorage);

  final SessionStorage _sessionStorage;

  static const _networkDelay = Duration(milliseconds: 700);

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_networkDelay);

    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || password.isEmpty) {
      return const Failure(AuthException('Email and password are required.'));
    }

    final isDemo =
        normalized == AppConstants.demoEmail &&
        password == AppConstants.demoPassword;
    final isDevAcceptable =
        normalized.contains('@') && password.length >= 8;

    if (!isDemo && !isDevAcceptable) {
      return const Failure(
        AuthException('Invalid email or password. Try the demo account.'),
      );
    }

    final session = AuthSession(
      accessToken: 'mock_access_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_refresh_token',
      user: User(
        id: 'farmer-001',
        email: normalized,
        fullName: isDemo ? 'Ritesh Shinde' : _nameFromEmail(normalized),
        role: UserRole.farmer,
        phone: '+91 98765 43210',
      ),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );

    await _sessionStorage.saveSession(session);
    return Success(session);
  }

  @override
  Future<Result<AuthSession>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_networkDelay);

    final normalized = email.trim().toLowerCase();
    if (fullName.trim().length < 2) {
      return const Failure(AuthException('Please enter your full name.'));
    }
    if (!normalized.contains('@')) {
      return const Failure(AuthException('Enter a valid email address.'));
    }
    if (password.length < 8) {
      return const Failure(
        AuthException('Password must be at least 8 characters.'),
      );
    }

    final session = AuthSession(
      accessToken: 'mock_access_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_refresh_token',
      user: User(
        id: 'farmer-${DateTime.now().millisecondsSinceEpoch}',
        email: normalized,
        fullName: fullName.trim(),
        role: UserRole.farmer,
      ),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );

    await _sessionStorage.saveSession(session);
    return Success(session);
  }

  @override
  Future<Result<void>> requestPasswordReset({required String email}) async {
    await Future<void>.delayed(_networkDelay);
    if (!email.contains('@')) {
      return const Failure(AuthException('Enter a valid email address.'));
    }
    // Mock: always succeeds for valid-looking emails.
    return const Success(null);
  }

  @override
  Future<Result<AuthSession?>> restoreSession() async {
    try {
      final session = await _sessionStorage.readSession();
      if (session == null) return const Success(null);
      if (session.isExpired) {
        await _sessionStorage.clear();
        return const Success(null);
      }
      return Success(session);
    } on Object catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<void>> logout() async {
    await _sessionStorage.clear();
    return const Success(null);
  }

  String _nameFromEmail(String email) {
    final local = email.split('@').first;
    if (local.isEmpty) return 'Farmer';
    return local[0].toUpperCase() + local.substring(1);
  }
}
