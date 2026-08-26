/// Application-wide constants for CropSure.
abstract final class AppConstants {
  static const String appName = 'CropSure';
  static const String appTagline = 'AI crop trust for modern farms';

  /// Short description used on splash and marketing surfaces.
  static const String appSubtitle =
      'Dynamic crop trust scoring and digital crop passports';

  static const Duration splashMinDuration = Duration(milliseconds: 1600);
  static const Duration sessionCheckTimeout = Duration(seconds: 8);

  /// Demo credentials for mock auth only (never used against production APIs).
  static const String demoEmail = 'farmer@cropsure.app';
  static const String demoPassword = 'password123';
}
