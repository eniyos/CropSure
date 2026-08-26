import 'package:cropsure/core/errors/app_exception.dart';
import 'package:cropsure/core/utils/result.dart';
import 'package:cropsure/features/auth/controllers/auth_controller.dart';
import 'package:cropsure/models/auth_session.dart';
import 'package:cropsure/models/user.dart';
import 'package:cropsure/services/auth/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  AuthSession? stored;
  bool failLogin = false;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    if (failLogin) {
      return const Failure(AuthException('Invalid credentials'));
    }
    stored = AuthSession(
      accessToken: 'token',
      user: User(
        id: '1',
        email: email,
        fullName: 'Test Farmer',
        role: UserRole.farmer,
      ),
    );
    return Success(stored!);
  }

  @override
  Future<Result<AuthSession>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    stored = AuthSession(
      accessToken: 'token',
      user: User(
        id: '2',
        email: email,
        fullName: fullName,
        role: UserRole.farmer,
      ),
    );
    return Success(stored!);
  }

  @override
  Future<Result<void>> requestPasswordReset({required String email}) async {
    return const Success(null);
  }

  @override
  Future<Result<AuthSession?>> restoreSession() async {
    return Success(stored);
  }

  @override
  Future<Result<void>> logout() async {
    stored = null;
    return const Success(null);
  }
}

void main() {
  late _FakeAuthRepository repository;
  late AuthController controller;

  setUp(() {
    repository = _FakeAuthRepository();
    controller = AuthController(repository);
  });

  test('bootstrap without session is unauthenticated', () async {
    await controller.bootstrap();
    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.isAuthenticated, isFalse);
  });

  test('login success authenticates', () async {
    final ok = await controller.login(
      email: 'farmer@cropsure.app',
      password: 'password123',
    );
    expect(ok, isTrue);
    expect(controller.status, AuthStatus.authenticated);
    expect(controller.user?.email, 'farmer@cropsure.app');
  });

  test('login failure keeps unauthenticated', () async {
    repository.failLogin = true;
    final ok = await controller.login(email: 'a@b.com', password: 'password123');
    expect(ok, isFalse);
    expect(controller.errorMessage, isNotNull);
    expect(controller.isAuthenticated, isFalse);
  });

  test('logout clears session', () async {
    await controller.login(email: 'a@b.com', password: 'password123');
    await controller.logout();
    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.session, isNull);
  });

  test('handleSessionExpired marks expired', () async {
    await controller.login(email: 'a@b.com', password: 'password123');
    controller.handleSessionExpired();
    expect(controller.sessionExpired, isTrue);
    expect(controller.status, AuthStatus.unauthenticated);
  });
}
