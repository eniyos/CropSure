import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/load_state.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_error_view.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/score_card.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/status_badge.dart';
import '../controllers/trust_controller.dart';
import 'widgets/trust_signal_card.dart';
import 'widgets/trust_trend_chart.dart';

class TrustScoreScreen extends StatefulWidget {
  const TrustScoreScreen({super.key, this.cropBatchId});

  final String? cropBatchId;

  @override
  State<TrustScoreScreen> createState() => _TrustScoreScreenState();
}

class _TrustScoreScreenState extends State<TrustScoreScreen> {
  late final TrustController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppScope.read(context).trustController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.load(cropBatchId: widget.cropBatchId);
    });
  }

  @override
  void didUpdateWidget(covariant TrustScoreScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cropBatchId != widget.cropBatchId) {
      _controller.load(cropBatchId: widget.cropBatchId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Trust score',
      actions: [
        IconButton(
          tooltip: 'Treatments',
          onPressed: () => context.push(
            AppRoutes.treatmentsPath(cropId: widget.cropBatchId),
          ),
          icon: const Icon(Icons.medical_services_outlined),
        ),
      ],
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          switch (_controller.state) {
            case LoadState.loading:
            case LoadState.idle:
              return const LoadingWidget(
                message: 'Loading Dynamic Crop Trust Score…',
              );
            case LoadState.error:
              return AppErrorView(
                message: _controller.errorMessage ??
                    'Could not load the trust score.',
                onRetry: _controller.refresh,
              );
            case LoadState.empty:
            case LoadState.success:
              final detail = _controller.detail;
              if (detail == null) {
                return AppErrorView(
                  message: 'Trust score data is unavailable.',
                  onRetry: _controller.refresh,
                );
              }

              return RefreshIndicator(
                onRefresh: _controller.refresh,
                child: ResponsiveContent(
                  maxWidth: 720,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Text(
                        detail.cropLabel == null
                            ? 'Dynamic Crop Trust Score'
                            : detail.cropLabel!,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Calculated by the CropSure Trust Engine',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ScoreCard(
                        title: 'Current trust score',
                        score: detail.score,
                        confidence: detail.confidence,
                        subtitle:
                            'Updated ${DateFormatters.formatWithTime(detail.updatedAt)}',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppCard(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.trending_up,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Trend: ${detail.trendLabel}',
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            StatusBadge(
                              label: detail.trendLabel,
                              tone: detail.trendLabel == 'Declining'
                                  ? StatusBadgeTone.warning
                                  : StatusBadgeTone.success,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TrustTrendChart(history: detail.history),
                      const SizedBox(height: AppSpacing.lg),
                      const SectionHeader(
                        title: 'Signal breakdown',
                        subtitle: 'Inputs supplied by the Trust Engine',
                      ),
                      ...detail.signals.map(
                        (signal) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: TrustSignalCard(signal: signal),
                        ),
                      ),
                      if (detail.explanation != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        AppCard(
                          child: Text(
                            detail.explanation!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: 'View treatments',
                        icon: Icons.medical_services_outlined,
                        onPressed: () => context.push(
                          AppRoutes.treatmentsPath(
                            cropId: detail.cropBatchId ?? widget.cropBatchId,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: 'Add treatment',
                        variant: AppButtonVariant.outlined,
                        icon: Icons.add,
                        onPressed: () => context.push(
                          AppRoutes.treatmentNewPath(
                            cropId: detail.cropBatchId ?? widget.cropBatchId,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
