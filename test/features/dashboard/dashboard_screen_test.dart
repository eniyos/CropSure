import 'package:cropsure/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cropsure/core/di/app_scope.dart';
import 'package:cropsure/core/offline/cache_store.dart';
import 'package:cropsure/core/offline/connectivity_controller.dart';
import 'package:cropsure/core/offline/sync_queue_store.dart';
import 'package:cropsure/core/storage/preferences_service.dart';
import 'package:cropsure/core/utils/result.dart';
import 'package:cropsure/features/auth/controllers/auth_controller.dart';
import 'package:cropsure/features/crop/controllers/crop_controller.dart';
import 'package:cropsure/features/dashboard/controllers/dashboard_controller.dart';
import 'package:cropsure/features/farm/controllers/farm_controller.dart';
import 'package:cropsure/features/sync/controllers/sync_controller.dart';
import 'package:cropsure/models/auth_session.dart';
import 'package:cropsure/models/crop_batch.dart';
import 'package:cropsure/models/dashboard_summary.dart';
import 'package:cropsure/models/farm.dart';
import 'package:cropsure/models/user.dart';
import 'package:cropsure/services/auth/auth_repository.dart';
import 'package:cropsure/services/crop/crop_repository.dart';
import 'package:cropsure/services/dashboard/dashboard_repository.dart';
import 'package:cropsure/services/farm/farm_repository.dart';
import 'package:cropsure/features/disease/controllers/disease_analysis_controller.dart';
import 'package:cropsure/features/market/controllers/market_controller.dart';
import 'package:cropsure/features/notifications/controllers/notification_controller.dart';
import 'package:cropsure/features/passport/controllers/passport_controller.dart';
import 'package:cropsure/features/treatment/controllers/treatment_controller.dart';
import 'package:cropsure/features/trust/controllers/trust_controller.dart';
import 'package:cropsure/features/weather/controllers/weather_controller.dart';
import 'package:cropsure/services/disease/mock_disease_analysis_repository.dart';
import 'package:cropsure/services/market/mock_market_repository.dart';
import 'package:cropsure/services/notifications/mock_notification_repository.dart';
import 'package:cropsure/services/passport/mock_passport_repository.dart';
import 'package:cropsure/services/treatment/mock_treatment_repository.dart';
import 'package:cropsure/services/trust/mock_trust_repository.dart';
import 'package:cropsure/services/weather/mock_weather_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AuthedRepository implements AuthRepository {
  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async =>
      Success(_session);

  @override
  Future<Result<void>> logout() async => const Success(null);

  @override
  Future<Result<AuthSession>> register({
    required String fullName,
    required String email,
    required String password,
  }) async =>
      Success(_session);

  @override
  Future<Result<void>> requestPasswordReset({required String email}) async =>
      const Success(null);

  @override
  Future<Result<AuthSession?>> restoreSession() async => Success(_session);

  static final _session = AuthSession(
    accessToken: 'token',
    user: const User(
      id: '1',
      email: 'farmer@cropsure.app',
      fullName: 'Ritesh Shinde',
      role: UserRole.farmer,
    ),
  );
}

class _DashboardRepo implements DashboardRepository {
  @override
  Future<Result<DashboardSummary>> getFarmerDashboard() async {
    return Success(
      DashboardSummary(
        healthSummaryLabel: '1 crop needs attention',
        healthyBatchCount: 1,
        atRiskBatchCount: 1,
        activeBatches: const [],
        trustScore: 78,
        trustConfidence: 0.84,
        trustUpdatedAt: DateTime(2026, 8, 25),
        weather: const WeatherSummary(
          condition: 'Partly cloudy',
          temperatureC: 29,
          humidityPercent: 62,
        ),
        market: MarketSummary(
          crop: 'Tomato',
          marketName: 'Nashik APMC',
          price: 28.5,
          unit: '₹/kg',
          updatedAt: DateTime(2026, 8, 25),
        ),
      ),
    );
  }
}

class _EmptyFarmRepository implements FarmRepository {
  @override
  Future<Result<Farm>> createFarm(FarmInput input) async =>
      const Failure('unused');

  @override
  Future<Result<void>> deleteFarm(String id) async => const Success(null);

  @override
  Future<Result<Farm>> getFarmById(String id) async => const Failure('unused');

  @override
  Future<Result<List<Farm>>> getFarms() async => const Success([]);

  @override
  Future<Result<Farm>> updateFarm(String id, FarmInput input) async =>
      const Failure('unused');
}

class _EmptyCropRepository implements CropRepository {
  @override
  Future<Result<CropBatch>> createCrop(CropBatchInput input) async =>
      const Failure('unused');

  @override
  Future<Result<void>> deleteCrop(String id) async => const Success(null);

  @override
  Future<Result<CropBatch>> getCropById(String id) async =>
      const Failure('unused');

  @override
  Future<Result<List<CropBatch>>> getCrops({String? farmId}) async =>
      const Success([]);

  @override
  Future<Result<CropBatch>> updateCrop(String id, CropBatchInput input) async =>
      const Failure('unused');
}

void main() {
  testWidgets('authenticated user sees farmer dashboard content', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PreferencesService.create();
    final connectivity = ConnectivityController(skipPlatform: true);
    await connectivity.start();
    final sync = SyncController(
      connectivity: connectivity,
      cacheStore: CacheStore(prefs),
      queueStore: SyncQueueStore(prefs),
    );

    final auth = AuthController(_AuthedRepository());
    await auth.bootstrap();

    final cropRepo = _EmptyCropRepository();
    final dependencies = AppDependencies(
      authController: auth,
      farmController: FarmController(_EmptyFarmRepository()),
      cropController: CropController(cropRepo),
      dashboardController: DashboardController(_DashboardRepo()),
      diseaseAnalysisController: DiseaseAnalysisController(
        analysisRepository: MockDiseaseAnalysisRepository(),
        cropRepository: cropRepo,
      ),
      trustController: TrustController(MockTrustRepository(cropRepo)),
      treatmentController: TreatmentController(MockTreatmentRepository(cropRepo)),
      weatherController: WeatherController(MockWeatherRepository()),
      marketController: MarketController(MockMarketRepository()),
      notificationController:
          NotificationController(MockNotificationRepository()),
      passportController: PassportController(MockPassportRepository(cropRepo)),
      connectivityController: connectivity,
      syncController: sync,
    );

    await tester.pumpWidget(CropSureApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    expect(find.text('Ritesh Shinde'), findsOneWidget);
    expect(find.text('Dynamic Crop Trust Score'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Quick actions'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text('Your fields, scored for trust'), findsOneWidget);
  });
}
