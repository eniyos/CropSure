import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_scaffold.dart';
import 'widgets/yield_prediction_card.dart';

class YieldPredictionScreen extends StatelessWidget {
  const YieldPredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.read(context).diseaseAnalysisController;
    final prediction = controller.result?.yieldPrediction;
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Yield prediction',
      body: ResponsiveContent(
        child: prediction == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No yield prediction is available yet.'),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Back',
                    expand: false,
                    onPressed: () => context.pop(),
                  ),
                ],
              )
            : ListView(
                children: [
                  Text(
                    'Seasonal yield estimate',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Provided by the backend yield prediction service. '
                    'CropSure mobile only displays the returned values.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  YieldPredictionCard(prediction: prediction),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Back to AI result',
                    variant: AppButtonVariant.outlined,
                    onPressed: () => context.go(AppRoutes.analysisResult),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: 'View disease progression',
                    variant: AppButtonVariant.text,
                    onPressed: () => context.push(AppRoutes.analysisProgression),
                  ),
                ],
              ),
      ),
    );
  }
}
