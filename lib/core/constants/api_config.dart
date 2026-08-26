/// Centralized API / environment configuration.
///
/// Switch [useMockApis] to `false` when a real FastAPI backend is available.
/// Endpoint path constants live in `services/api/api_endpoints.dart` and must
/// match the OpenAPI contract before enabling live HTTP.
abstract final class ApiConfig {
  /// When true, repositories use mock implementations instead of HTTP.
  static const bool useMockApis = true;

  /// Placeholder base URL. Override with `--dart-define=CROPSURE_API_BASE_URL=...`.
  static const String baseUrl = String.fromEnvironment(
    'CROPSURE_API_BASE_URL',
    defaultValue: 'https://api.cropsure.local',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const String authHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';

  static String get dataSourceLabel =>
      useMockApis ? 'Mock data (demo)' : 'Live API';
}
