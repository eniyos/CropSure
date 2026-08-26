import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/load_state.dart';
import '../../../models/disease_analysis.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_error_view.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/status_badge.dart';
import 'widgets/progression_chart_card.dart';

class ProgressionScreen extends StatefulWidget {
  const ProgressionScreen({super.key});

  @override
  State<ProgressionScreen> createState() => _ProgressionScreenState();
}

class _ProgressionScreenState extends State<ProgressionScreen> {
  @override
  void initState() {
    super.initState();
    final controller = AppScope.read(context).diseaseAnalysisController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.progression == null && controller.result != null) {
        controller.loadProgression(ProgressionHorizon.days14);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.read(context).diseaseAnalysisController;
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Disease progression',
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          if (controller.result == null) {
            return Center(
              child: AppButton(
                label: 'Run analysis first',
                expand: false,
                onPressed: () => context.go(AppRoutes.analyzeCrop),
              ),
            );
          }

          return ResponsiveContent(
            child: ListView(
              children: [
                Text(
                  'Predicted disease risk over time',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Values below are forecasts from the backend progression '
                  'service — not live measurements.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: ProgressionHorizon.values.map((horizon) {
                    final selected = controller.horizon == horizon;
                    return ChoiceChip(
                      label: Text(horizon.label),
                      selected: selected,
                      onSelected: (_) => controller.loadProgression(horizon),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (controller.progressionState == LoadState.loading)
                  const SizedBox(
                    height: 220,
                    child: LoadingWidget(message: 'Loading prediction…'),
                  )
                else if (controller.progressionState == LoadState.error)
                  AppErrorView(
                    message: controller.errorMessage ??
                        'Could not load progression.',
                    onRetry: () =>
                        controller.loadProgression(controller.horizon),
                  )
                else if (controller.progression != null) ...[
                  ProgressionChartCard(progression: controller.progression!),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionHeader(title: 'Risk indicator'),
                  AppCard(
                    child: Row(
                      children: [
                        const Icon(Icons.trending_up, color: AppColors.warning),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            controller.progression!.riskLabel,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const StatusBadge(
                          label: 'Forecast',
                          tone: StatusBadgeTone.warning,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Back to AI result',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
