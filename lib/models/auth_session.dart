import 'user.dart';

/// Authenticated session payload returned by auth repository.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.user,
    this.refreshToken,
    this.expiresAt,
  });

  final String accessToken;
  final String? refreshToken;
  final User user;
  final DateTime? expiresAt;

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  AuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    User? user,
    DateTime? expiresAt,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
