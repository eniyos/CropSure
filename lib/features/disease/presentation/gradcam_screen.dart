import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_scaffold.dart';
import 'widgets/gradcam_comparison_view.dart';

class GradCamScreen extends StatefulWidget {
  const GradCamScreen({super.key});

  @override
  State<GradCamScreen> createState() => _GradCamScreenState();
}

class _GradCamScreenState extends State<GradCamScreen> {
  bool _showOverlay = true;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.read(context).diseaseAnalysisController;
    final result = controller.result;
    final gradCam = result?.gradCam;

    return AppScaffold(
      title: 'Grad-CAM',
      actions: [
        IconButton(
          tooltip: _showOverlay ? 'Hide overlay' : 'Show overlay',
          onPressed: () => setState(() => _showOverlay = !_showOverlay),
          icon: Icon(
            _showOverlay ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
        ),
      ],
      body: gradCam == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Grad-CAM data is not available for this analysis.'),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'Back to result',
                      expand: false,
                      onPressed: () => context.go(AppRoutes.analysisResult),
                    ),
                  ],
                ),
              ),
            )
          : ResponsiveContent(
              child: ListView(
                children: [
                  GradCamComparisonView(
                    originalBytes: controller.imageBytes,
                    gradCam: gradCam,
                    showOverlay: _showOverlay,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Back to AI result',
                    variant: AppButtonVariant.outlined,
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
    );
  }
}
