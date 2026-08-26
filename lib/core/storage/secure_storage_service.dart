import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure persistence for auth tokens and sensitive session data.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String accessTokenKey = 'cropsure_access_token';
  static const String refreshTokenKey = 'cropsure_refresh_token';
  static const String userJsonKey = 'cropsure_user_json';

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> deleteAll() => _storage.deleteAll();
}
