import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/di/app_scope.dart';
import 'core/network/api_client.dart';
import 'core/offline/cache_store.dart';
import 'core/offline/connectivity_controller.dart';
import 'core/offline/sync_queue_store.dart';
import 'core/storage/preferences_service.dart';
import 'core/storage/secure_storage_service.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/crop/controllers/crop_controller.dart';
import 'features/dashboard/controllers/dashboard_controller.dart';
import 'features/disease/controllers/disease_analysis_controller.dart';
import 'features/farm/controllers/farm_controller.dart';
import 'features/market/controllers/market_controller.dart';
import 'features/notifications/controllers/notification_controller.dart';
import 'features/passport/controllers/passport_controller.dart';
import 'features/sync/controllers/sync_controller.dart';
import 'features/treatment/controllers/treatment_controller.dart';
import 'features/trust/controllers/trust_controller.dart';
import 'features/weather/controllers/weather_controller.dart';
import 'services/api/repository_factory.dart';
import 'services/auth/mock_auth_repository.dart';
import 'services/dashboard/mock_dashboard_repository.dart';
import 'services/disease/mock_disease_analysis_repository.dart';
import 'services/market/mock_market_repository.dart';
import 'services/notifications/mock_notification_repository.dart';
import 'services/passport/mock_passport_repository.dart';
import 'services/storage/session_storage.dart';
import 'services/treatment/mock_treatment_repository.dart';
import 'services/trust/mock_trust_repository.dart';
import 'services/weather/mock_weather_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final secureStorage = SecureStorageService();
  final sessionStorage = SessionStorage(secureStorage);
  final preferences = await PreferencesService.create();
  final cacheStore = CacheStore(preferences);
  final syncQueueStore = SyncQueueStore(preferences);

  final connectivityController = ConnectivityController();
  await connectivityController.start();

  final syncController = SyncController(
    connectivity: connectivityController,
    cacheStore: cacheStore,
    queueStore: syncQueueStore,
  );

  final authRepository = MockAuthRepository(sessionStorage);
  final authController = AuthController(authRepository);

  final apiClient = ApiClient(
    tokenProvider: sessionStorage.readAccessToken,
    onUnauthorized: authController.handleSessionExpired,
  );

  final repos = RepositoryFactory(
    apiClient: apiClient,
    cacheStore: cacheStore,
    connectivity: connectivityController,
    syncController: syncController,
  );

  final farmRepository = repos.farmRepository;
  final cropRepository = repos.cropRepository;
  final dashboardRepository = MockDashboardRepository(cropRepository);
  final diseaseRepository = MockDiseaseAnalysisRepository();
  final trustRepository = MockTrustRepository(cropRepository);
  final treatmentRepository = MockTreatmentRepository(cropRepository);
  final weatherRepository = MockWeatherRepository();
  final marketRepository = MockMarketRepository();
  final notificationRepository = MockNotificationRepository();
  final passportRepository = MockPassportRepository(cropRepository);

  final dependencies = AppDependencies(
    authController: authController,
    farmController: FarmController(
      farmRepository,
      connectivity: connectivityController,
      syncController: syncController,
    ),
    cropController: CropController(
      cropRepository,
      connectivity: connectivityController,
      syncController: syncController,
    ),
    dashboardController: DashboardController(dashboardRepository),
    diseaseAnalysisController: DiseaseAnalysisController(
      analysisRepository: diseaseRepository,
      cropRepository: cropRepository,
    ),
    trustController: TrustController(trustRepository),
    treatmentController: TreatmentController(treatmentRepository),
    weatherController: WeatherController(weatherRepository),
    marketController: MarketController(marketRepository),
    notificationController: NotificationController(notificationRepository),
    passportController: PassportController(passportRepository),
    connectivityController: connectivityController,
    syncController: syncController,
  );

  runApp(CropSureApp(dependencies: dependencies));
}
