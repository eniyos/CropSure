import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/load_state.dart';
import '../../../models/treatment.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_error_view.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/status_badge.dart';
import '../controllers/treatment_controller.dart';

StatusBadgeTone _toneFor(TreatmentStatus status) => switch (status) {
  TreatmentStatus.completed => StatusBadgeTone.success,
  TreatmentStatus.inProgress => StatusBadgeTone.info,
  TreatmentStatus.planned => StatusBadgeTone.warning,
  TreatmentStatus.cancelled => StatusBadgeTone.neutral,
};

class TreatmentListScreen extends StatefulWidget {
  const TreatmentListScreen({super.key, this.cropBatchId});

  final String? cropBatchId;

  @override
  State<TreatmentListScreen> createState() => _TreatmentListScreenState();
}

class _TreatmentListScreenState extends State<TreatmentListScreen> {
  late final TreatmentController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppScope.read(context).treatmentController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadTreatments(cropBatchId: widget.cropBatchId);
    });
  }

  @override
  void didUpdateWidget(covariant TreatmentListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cropBatchId != widget.cropBatchId) {
      _controller.loadTreatments(cropBatchId: widget.cropBatchId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Treatments',
      actions: [
        IconButton(
          tooltip: 'Add treatment',
          onPressed: () => context.push(
            AppRoutes.treatmentNewPath(cropId: widget.cropBatchId),
          ),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'treatments-fab',
        onPressed: () => context.push(
          AppRoutes.treatmentNewPath(cropId: widget.cropBatchId),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add treatment'),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          switch (_controller.listState) {
            case LoadState.loading:
            case LoadState.idle:
              return const LoadingWidget(message: 'Loading treatments…');
            case LoadState.error:
              return AppErrorView(
                message: _controller.errorMessage ??
                    'Could not load treatments.',
                onRetry: () => _controller.loadTreatments(
                  cropBatchId: widget.cropBatchId,
                ),
              );
            case LoadState.empty:
              return EmptyState(
                title: 'No treatments yet',
                message: 'Log a treatment to keep crop trust signals up to date.',
                icon: Icons.medical_services_outlined,
                actionLabel: 'Add treatment',
                onAction: () => context.push(
                  AppRoutes.treatmentNewPath(cropId: widget.cropBatchId),
                ),
              );
            case LoadState.success:
              return RefreshIndicator(
                onRefresh: () => _controller.loadTreatments(
                  cropBatchId: widget.cropBatchId,
                ),
                child: ResponsiveContent(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    88,
                  ),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _controller.treatments.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = _controller.treatments[index];
                      return _TreatmentTile(treatment: item);
                    },
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}

class _TreatmentTile extends StatelessWidget {
  const _TreatmentTile({required this.treatment});

  final Treatment treatment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: () => context.push(AppRoutes.treatmentDetailsPath(treatment.id)),
      semanticLabel: 'Treatment ${treatment.name}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(treatment.name, style: theme.textTheme.titleMedium),
              ),
              StatusBadge(
                label: treatment.status.displayName,
                tone: _toneFor(treatment.status),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            treatment.cropLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            DateFormatters.format(treatment.date),
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
