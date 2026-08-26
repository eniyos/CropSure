/// Central route path constants.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String home = '/home';
  static const String dashboard = '/home/dashboard';
  static const String farms = '/home/farms';
  static const String farmNew = '/home/farms/new';
  static const String farmDetails = '/home/farms/:farmId';
  static const String farmEdit = '/home/farms/:farmId/edit';

  static const String crops = '/home/crops';
  static const String cropNew = '/home/crops/new';
  static const String cropDetails = '/home/crops/:cropId';
  static const String cropEdit = '/home/crops/:cropId/edit';

  static const String analyzeCrop = '/home/analyze';
  static const String analysisResult = '/home/analyze/result';
  static const String analysisGradCam = '/home/analyze/gradcam';
  static const String analysisProgression = '/home/analyze/progression';
  static const String analysisYield = '/home/analyze/yield';

  static const String trustScore = '/home/trust';
  static const String treatments = '/home/treatments';
  static const String treatmentNew = '/home/treatments/new';
  static const String treatmentDetails = '/home/treatments/:treatmentId';
  static const String treatmentEdit = '/home/treatments/:treatmentId/edit';

  static const String weather = '/home/weather';
  static const String market = '/home/market';
  static const String notifications = '/home/notifications';
  static const String notificationDetails =
      '/home/notifications/:notificationId';

  static const String passport = '/home/passport';
  static const String passportVerify = '/home/passport/verify';
  static const String syncOffline = '/home/sync';

  static String cropsForFarmPath(String farmId) =>
      '$crops?farmId=$farmId';

  static String passportDetailsPath(String passportId) =>
      '/home/passport/$passportId';

  static String passportForCropPath(String cropId) =>
      '/home/passport/crop/$cropId';

  static String passportPath({String? cropId}) =>
      cropId == null ? passport : passportForCropPath(cropId);

  static String passportVerifyPath({String? code}) => code == null
      ? passportVerify
      : '$passportVerify?code=${Uri.encodeQueryComponent(code)}';

  static String farmDetailsPath(String farmId) => '/home/farms/$farmId';
  static String farmEditPath(String farmId) => '/home/farms/$farmId/edit';
  static String cropDetailsPath(String cropId) => '/home/crops/$cropId';
  static String cropEditPath(String cropId) => '/home/crops/$cropId/edit';
  static String analyzeCropPath({String? cropId}) =>
      cropId == null ? analyzeCrop : '$analyzeCrop?cropId=$cropId';
  static String trustScorePath({String? cropId}) =>
      cropId == null ? trustScore : '$trustScore?cropId=$cropId';
  static String treatmentsPath({String? cropId}) =>
      cropId == null ? treatments : '$treatments?cropId=$cropId';
  static String treatmentNewPath({String? cropId}) =>
      cropId == null ? treatmentNew : '$treatmentNew?cropId=$cropId';
  static String treatmentDetailsPath(String id) => '/home/treatments/$id';
  static String treatmentEditPath(String id) => '/home/treatments/$id/edit';
  static String notificationDetailsPath(String id) =>
      '/home/notifications/$id';
}
