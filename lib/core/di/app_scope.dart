import 'package:flutter/material.dart';

import '../../features/auth/controllers/auth_controller.dart';
import '../../features/crop/controllers/crop_controller.dart';
import '../../features/dashboard/controllers/dashboard_controller.dart';
import '../../features/disease/controllers/disease_analysis_controller.dart';
import '../../features/farm/controllers/farm_controller.dart';
import '../../features/market/controllers/market_controller.dart';
import '../../features/notifications/controllers/notification_controller.dart';
import '../../features/passport/controllers/passport_controller.dart';
import '../../features/sync/controllers/sync_controller.dart';
import '../../features/treatment/controllers/treatment_controller.dart';
import '../../features/trust/controllers/trust_controller.dart';
import '../../features/weather/controllers/weather_controller.dart';
import '../offline/connectivity_controller.dart';

/// Application-wide dependencies for Phase 2+.
class AppDependencies {
  const AppDependencies({
    required this.authController,
    required this.farmController,
    required this.cropController,
    required this.dashboardController,
    required this.diseaseAnalysisController,
    required this.trustController,
    required this.treatmentController,
    required this.weatherController,
    required this.marketController,
    required this.notificationController,
    required this.passportController,
    required this.connectivityController,
    required this.syncController,
  });

  final AuthController authController;
  final FarmController farmController;
  final CropController cropController;
  final DashboardController dashboardController;
  final DiseaseAnalysisController diseaseAnalysisController;
  final TrustController trustController;
  final TreatmentController treatmentController;
  final WeatherController weatherController;
  final MarketController marketController;
  final NotificationController notificationController;
  final PassportController passportController;
  final ConnectivityController connectivityController;
  final SyncController syncController;
}

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.dependencies,
    required super.child,
  });

  final AppDependencies dependencies;

  static AppDependencies of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!.dependencies;
  }

  static AppDependencies read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!.dependencies;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      dependencies != oldWidget.dependencies;
}
