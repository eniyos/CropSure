import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_constants.dart';
import 'core/di/app_scope.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

class CropSureApp extends StatefulWidget {
  const CropSureApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<CropSureApp> createState() => _CropSureAppState();
}

class _CropSureAppState extends State<CropSureApp> {
  late final GoRouter _router = createAppRouter(
    widget.dependencies.authController,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      dependencies: widget.dependencies,
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: _router,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          // Keep text readable without breaking dense agri layouts.
          final scaler = media.textScaler.clamp(
            minScaleFactor: 0.9,
            maxScaleFactor: 1.35,
          );
          return MediaQuery(
            data: media.copyWith(textScaler: scaler),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
