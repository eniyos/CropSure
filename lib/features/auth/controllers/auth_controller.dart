import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../models/auth_session.dart';
import '../../../models/user.dart';
import '../../../services/auth/auth_repository.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

/// App-wide auth state. Used as [GoRouter.refreshListenable].
class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.unknown;
  AuthSession? _session;
  bool _busy = false;
  String? _errorMessage;
  bool _sessionExpired = false;

  AuthStatus get status => _status;
  AuthSession? get session => _session;
  User? get user => _session?.user;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isBusy => _busy;
  String? get errorMessage => _errorMessage;
  bool get sessionExpired => _sessionExpired;

  Future<void> bootstrap() async {
    _setBusy(true);
    try {
      final result = await _repository.restoreSession();
      result.when(
        success: (session) {
          if (session != null) {
            _session = session;
            _status = AuthStatus.authenticated;
          } else {
            _session = null;
            _status = AuthStatus.unauthenticated;
          }
          _errorMessage = null;
        },
        failure: (error) {
          _session = null;
          _status = AuthStatus.unauthenticated;
          _errorMessage = ErrorMapper.fromObject(error).message;
        },
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setBusy(true);
    _errorMessage = null;
    _sessionExpired = false;
    try {
      final result = await _repository.login(email: email, password: password);
      return result.when(
        success: (session) {
          _session = session;
          _status = AuthStatus.authenticated;
          notifyListeners();
          return true;
        },
        failure: (error) {
          _errorMessage = ErrorMapper.fromObject(error).message;
          notifyListeners();
          return false;
        },
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setBusy(true);
    _errorMessage = null;
    try {
      final result = await _repository.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      return result.when(
        success: (session) {
          _session = session;
          _status = AuthStatus.authenticated;
          notifyListeners();
          return true;
        },
        failure: (error) {
          _errorMessage = ErrorMapper.fromObject(error).message;
          notifyListeners();
          return false;
        },
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<bool> requestPasswordReset({required String email}) async {
    _setBusy(true);
    _errorMessage = null;
    try {
      final result = await _repository.requestPasswordReset(email: email);
      return result.when(
        success: (_) {
          notifyListeners();
          return true;
        },
        failure: (error) {
          _errorMessage = ErrorMapper.fromObject(error).message;
          notifyListeners();
          return false;
        },
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<void> logout() async {
    _setBusy(true);
    try {
      await _repository.logout();
    } finally {
      _session = null;
      _status = AuthStatus.unauthenticated;
      _sessionExpired = false;
      _errorMessage = null;
      _setBusy(false);
    }
  }

  /// Called by API interceptor when a 401 is received.
  void handleSessionExpired() {
    if (_status != AuthStatus.authenticated) return;
    _session = null;
    _status = AuthStatus.unauthenticated;
    _sessionExpired = true;
    _errorMessage = const UnauthorizedException().message;
    notifyListeners();
    // Clear persisted session without awaiting UI.
    _repository.logout();
  }

  void clearError() {
    if (_errorMessage == null && !_sessionExpired) return;
    _errorMessage = null;
    _sessionExpired = false;
    notifyListeners();
  }

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }
}
