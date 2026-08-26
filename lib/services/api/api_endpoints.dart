/// REST path placeholders for FastAPI integration.
///
/// Replace values to match the backend OpenAPI contract before setting
/// [ApiConfig.useMockApis] to `false`. Do not invent production paths beyond
/// these temporary scaffolding keys.
abstract final class ApiEndpoints {
  static const String farms = '/api/v1/farms';
  static String farmById(String id) => '/api/v1/farms/$id';

  static const String crops = '/api/v1/crops';
  static String cropById(String id) => '/api/v1/crops/$id';

  static const String authLogin = '/api/v1/auth/login';
  static const String authRegister = '/api/v1/auth/register';
  static const String authLogout = '/api/v1/auth/logout';
  static const String authForgotPassword = '/api/v1/auth/forgot-password';
}
