import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/image_preview.dart';
import '../../../widgets/result_card.dart';
import '../../../widgets/section_header.dart';
import 'widgets/severity_indicator.dart';
import 'widgets/yield_prediction_card.dart';

class AnalysisResultScreen extends StatelessWidget {
  const AnalysisResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.read(context).diseaseAnalysisController;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final result = controller.result;
        if (result == null) {
          return AppScaffold(
            title: 'AI result',
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No analysis result is available yet.'),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'Start analysis',
                      expand: false,
                      onPressed: () => context.go(AppRoutes.analyzeCrop),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final theme = Theme.of(context);

        return AppScaffold(
          title: 'AI result',
          body: ResponsiveContent(
            child: ListView(
              children: [
                ResultCard(
                  title: 'Disease detected',
                  resultLabel: result.diseaseName,
                  confidence: result.confidence,
                  severityLabel: result.severity.displayName,
                  severityTone: SeverityPresentation.tone(result.severity),
                  timestampLabel:
                      'Analyzed ${DateFormatters.formatWithTime(result.analyzedAt)}',
                  details: result.cropLabel,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceMuted,
                    child: Icon(
                      SeverityPresentation.icon(result.severity),
                      color: SeverityPresentation.color(result.severity),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (controller.imageBytes != null)
                  ImagePreview(
                    imageBytes: controller.imageBytes,
                    height: 200,
                  ),
                const SizedBox(height: AppSpacing.lg),
                SeverityIndicator(
                  level: result.severity,
                  score: result.severityScore,
                ),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(title: 'Detailed explanation'),
                AppCard(
                  child: Text(
                    result.explanation,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                if (result.yieldPrediction != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  YieldPredictionCard(prediction: result.yieldPrediction!),
                ],
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(
                  title: 'Explore further',
                  subtitle: 'Visualizations from the AI service response',
                ),
                AppButton(
                  label: 'Open Grad-CAM',
                  icon: Icons.layers_outlined,
                  onPressed: () => context.push(AppRoutes.analysisGradCam),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Disease progression',
                  variant: AppButtonVariant.outlined,
                  icon: Icons.show_chart,
                  onPressed: () => context.push(AppRoutes.analysisProgression),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Yield prediction details',
                  variant: AppButtonVariant.outlined,
                  icon: Icons.agriculture_outlined,
                  onPressed: () => context.push(AppRoutes.analysisYield),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Analyze another image',
                  variant: AppButtonVariant.text,
                  onPressed: () {
                    controller.resetFlow();
                    context.go(
                      AppRoutes.analyzeCropPath(
                        cropId: result.cropBatchId,
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }
}
