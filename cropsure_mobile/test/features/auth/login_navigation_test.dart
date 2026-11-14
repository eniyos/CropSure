import 'package:cropsure/app.dart';
import 'package:cropsure/core/di/app_scope.dart';
import 'package:cropsure/core/offline/cache_store.dart';
import 'package:cropsure/core/offline/connectivity_controller.dart';
import 'package:cropsure/core/offline/sync_queue_store.dart';
import 'package:cropsure/core/routing/app_routes.dart';
import 'package:cropsure/core/storage/preferences_service.dart';
import 'package:cropsure/core/utils/result.dart';
import 'package:cropsure/features/auth/controllers/auth_controller.dart';
import 'package:cropsure/features/crop/controllers/crop_controller.dart';
import 'package:cropsure/features/dashboard/controllers/dashboard_controller.dart';
import 'package:cropsure/features/disease/controllers/disease_analysis_controller.dart';
import 'package:cropsure/features/farm/controllers/farm_controller.dart';
import 'package:cropsure/features/market/controllers/market_controller.dart';
import 'package:cropsure/features/notifications/controllers/notification_controller.dart';
import 'package:cropsure/features/passport/controllers/passport_controller.dart';
import 'package:cropsure/features/sync/controllers/sync_controller.dart';
import 'package:cropsure/features/treatment/controllers/treatment_controller.dart';
import 'package:cropsure/features/trust/controllers/trust_controller.dart';
import 'package:cropsure/features/weather/controllers/weather_controller.dart';
import 'package:cropsure/models/auth_session.dart';
import 'package:cropsure/models/user.dart';
import 'package:cropsure/services/auth/auth_repository.dart';
import 'package:cropsure/services/crop/mock_crop_repository.dart';
import 'package:cropsure/services/dashboard/mock_dashboard_repository.dart';
import 'package:cropsure/services/disease/mock_disease_analysis_repository.dart';
import 'package:cropsure/services/farm/mock_farm_repository.dart';
import 'package:cropsure/services/market/mock_market_repository.dart';
import 'package:cropsure/services/notifications/mock_notification_repository.dart';
import 'package:cropsure/services/passport/mock_passport_repository.dart';
import 'package:cropsure/services/treatment/mock_treatment_repository.dart';
import 'package:cropsure/services/trust/mock_trust_repository.dart';
import 'package:cropsure/services/weather/mock_weather_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AuthedRepository implements AuthRepository {
  static final _session = AuthSession(
    accessToken: 'token',
    refreshToken: 'refresh',
    user: const User(
      id: 'farmer-001',
      email: 'farmer@cropsure.app',
      fullName: 'Ritesh Shinde',
      role: UserRole.farmer,
    ),
  );

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
}

Future<AppDependencies> _deps(AuthController auth) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await PreferencesService.create();
  final connectivity = ConnectivityController(skipPlatform: true);
  await connectivity.start();
  final sync = SyncController(
    connectivity: connectivity,
    cacheStore: CacheStore(prefs),
    queueStore: SyncQueueStore(prefs),
  );
  final farms = MockFarmRepository();
  final crops = MockCropRepository(farms);

  return AppDependencies(
    authController: auth,
    farmController: FarmController(farms),
    cropController: CropController(crops),
    dashboardController: DashboardController(MockDashboardRepository(crops)),
    diseaseAnalysisController: DiseaseAnalysisController(
      analysisRepository: MockDiseaseAnalysisRepository(),
      cropRepository: crops,
    ),
    trustController: TrustController(MockTrustRepository(crops)),
    treatmentController: TreatmentController(MockTreatmentRepository(crops)),
    weatherController: WeatherController(MockWeatherRepository()),
    marketController: MarketController(MockMarketRepository()),
    notificationController:
        NotificationController(MockNotificationRepository()),
    passportController: PassportController(MockPassportRepository(crops)),
    connectivityController: connectivity,
    syncController: sync,
  );
}

void main() {
  testWidgets('authenticated shell navigates between Home and Farms', (
    tester,
  ) async {
    final auth = AuthController(_AuthedRepository());
    await auth.bootstrap();
    final dependencies = await _deps(auth);

    await tester.pumpWidget(CropSureApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Ritesh Shinde'), findsOneWidget);

    await tester.tap(find.text('Farms').last);
    await tester.pumpAndSettle();

    expect(find.text('Add farm'), findsWidgets);

    final context = tester.element(find.byType(Scaffold).first);
    GoRouter.of(context).go(AppRoutes.syncOffline);
    await tester.pumpAndSettle();

    expect(find.text('Sync & offline'), findsOneWidget);
  });
}
