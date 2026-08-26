import 'dart:convert';

import '../../core/storage/secure_storage_service.dart';
import '../../models/auth_session.dart';
import '../../models/user.dart';

/// Persists and restores auth sessions using secure storage only.
class SessionStorage {
  SessionStorage(this._secureStorage);

  final SecureStorageService _secureStorage;

  Future<void> saveSession(AuthSession session) async {
    await _secureStorage.write(
      SecureStorageService.accessTokenKey,
      session.accessToken,
    );
    if (session.refreshToken != null) {
      await _secureStorage.write(
        SecureStorageService.refreshTokenKey,
        session.refreshToken!,
      );
    }
    await _secureStorage.write(
      SecureStorageService.userJsonKey,
      jsonEncode(session.user.toJson()),
    );
  }

  Future<AuthSession?> readSession() async {
    final token = await _secureStorage.read(
      SecureStorageService.accessTokenKey,
    );
    final userJson = await _secureStorage.read(
      SecureStorageService.userJsonKey,
    );
    if (token == null || token.isEmpty || userJson == null) {
      return null;
    }

    final map = jsonDecode(userJson) as Map<String, dynamic>;
    final refresh = await _secureStorage.read(
      SecureStorageService.refreshTokenKey,
    );

    return AuthSession(
      accessToken: token,
      refreshToken: refresh,
      user: User.fromJson(map),
    );
  }

  Future<String?> readAccessToken() {
    return _secureStorage.read(SecureStorageService.accessTokenKey);
  }

  Future<void> clear() => _secureStorage.deleteAll();
}
