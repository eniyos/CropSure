import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/crop/presentation/crop_details_screen.dart';
import '../../features/crop/presentation/crop_form_screen.dart';
import '../../features/crop/presentation/crop_list_screen.dart';
import '../../features/dashboard/presentation/farmer_dashboard_screen.dart';
import '../../features/dashboard/presentation/farmer_shell_screen.dart';
import '../../features/disease/presentation/analysis_result_screen.dart';
import '../../features/disease/presentation/analyze_crop_screen.dart';
import '../../features/disease/presentation/gradcam_screen.dart';
import '../../features/disease/presentation/progression_screen.dart';
import '../../features/disease/presentation/yield_prediction_screen.dart';
import '../../features/farm/presentation/farm_details_screen.dart';
import '../../features/farm/presentation/farm_form_screen.dart';
import '../../features/farm/presentation/farm_list_screen.dart';
import '../../features/market/presentation/market_screen.dart';
import '../../features/notifications/presentation/notification_screens.dart';
import '../../features/passport/presentation/passport_details_screen.dart';
import '../../features/passport/presentation/passport_list_screen.dart';
import '../../features/passport/presentation/passport_verify_screen.dart';
import '../../features/sync/presentation/sync_offline_screen.dart';
import '../../features/treatment/presentation/treatment_details_screen.dart';
import '../../features/treatment/presentation/treatment_form_screen.dart';
import '../../features/treatment/presentation/treatment_list_screen.dart';
import '../../features/trust/presentation/trust_score_screen.dart';
import '../../features/weather/presentation/weather_screen.dart';
import 'app_routes.dart';

/// Creates a fresh GoRouter. Navigator keys are created per instance so hot
/// reload / redirects never reuse a GlobalKey across two Navigators.
GoRouter createAppRouter(AuthController authController) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final dashboardNavKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
  final farmsNavKey = GlobalKey<NavigatorState>(debugLabel: 'farms');
  final cropsNavKey = GlobalKey<NavigatorState>(debugLabel: 'crops');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: authController,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final status = authController.status;
      final location = state.matchedLocation;
      final isSplash = location == AppRoutes.splash;
      final isAuthRoute =
          location == AppRoutes.login ||
          location == AppRoutes.register ||
          location == AppRoutes.forgotPassword;
      final isProtected = location.startsWith('/home');

      if (status == AuthStatus.unknown) {
        return isSplash ? null : AppRoutes.splash;
      }

      if (status == AuthStatus.authenticated) {
        if (isSplash || isAuthRoute) return AppRoutes.dashboard;
        return null;
      }

      if (isSplash) return AppRoutes.login;
      if (isProtected || !isAuthRoute) return AppRoutes.login;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) =>
            SplashScreen(authController: authController),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) =>
            LoginScreen(authController: authController),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) =>
            RegisterScreen(authController: authController),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) =>
            ForgotPasswordScreen(authController: authController),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return FarmerShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: dashboardNavKey,
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const FarmerDashboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: farmsNavKey,
            routes: [
              GoRoute(
                path: AppRoutes.farms,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const FarmListScreen(),
                ),
                routes: [
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: 'new',
                    builder: (context, state) => const FarmFormScreen(),
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: ':farmId/edit',
                    builder: (context, state) => FarmFormScreen(
                      farmId: state.pathParameters['farmId'],
                    ),
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: ':farmId',
                    builder: (context, state) => FarmDetailsScreen(
                      farmId: state.pathParameters['farmId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: cropsNavKey,
            routes: [
              GoRoute(
                path: AppRoutes.crops,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: CropListScreen(
                    farmId: state.uri.queryParameters['farmId'],
                  ),
                ),
                routes: [
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: 'new',
                    builder: (context, state) => CropFormScreen(
                      initialFarmId: state.uri.queryParameters['farmId'],
                    ),
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: ':cropId/edit',
                    builder: (context, state) => CropFormScreen(
                      cropId: state.pathParameters['cropId'],
                    ),
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: ':cropId',
                    builder: (context, state) => CropDetailsScreen(
                      cropId: state.pathParameters['cropId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Full-screen routes outside the tab shell.
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.analysisResult,
        builder: (context, state) => const AnalysisResultScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.analysisGradCam,
        builder: (context, state) => const GradCamScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.analysisProgression,
        builder: (context, state) => const ProgressionScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.analysisYield,
        builder: (context, state) => const YieldPredictionScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.analyzeCrop,
        builder: (context, state) => AnalyzeCropScreen(
          cropId: state.uri.queryParameters['cropId'],
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.trustScore,
        builder: (context, state) => TrustScoreScreen(
          cropBatchId: state.uri.queryParameters['cropId'],
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.treatmentNew,
        builder: (context, state) => TreatmentFormScreen(
          initialCropId: state.uri.queryParameters['cropId'],
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/home/treatments/:treatmentId/edit',
        builder: (context, state) => TreatmentFormScreen(
          treatmentId: state.pathParameters['treatmentId'],
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/home/treatments/:treatmentId',
        builder: (context, state) => TreatmentDetailsScreen(
          treatmentId: state.pathParameters['treatmentId']!,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.treatments,
        builder: (context, state) => TreatmentListScreen(
          cropBatchId: state.uri.queryParameters['cropId'],
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.weather,
        builder: (context, state) => const WeatherScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.market,
        builder: (context, state) => const MarketScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/home/notifications/:notificationId',
        builder: (context, state) => NotificationDetailsScreen(
          notificationId: state.pathParameters['notificationId']!,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationListScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.syncOffline,
        builder: (context, state) => const SyncOfflineScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.passport,
        builder: (context, state) => PassportListScreen(
          cropBatchId: state.uri.queryParameters['cropId'],
        ),
        routes: [
          GoRoute(
            path: 'verify',
            builder: (context, state) => PassportVerifyScreen(
              initialCode: state.uri.queryParameters['code'],
            ),
          ),
          GoRoute(
            path: 'crop/:cropId',
            builder: (context, state) => PassportDetailsScreen(
              cropBatchId: state.pathParameters['cropId'],
            ),
          ),
          GoRoute(
            path: ':passportId',
            builder: (context, state) => PassportDetailsScreen(
              passportId: state.pathParameters['passportId'],
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
}
