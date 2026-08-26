import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/load_state.dart';
import '../../../models/treatment.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_error_view.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/status_badge.dart';
import '../controllers/treatment_controller.dart';

class TreatmentDetailsScreen extends StatefulWidget {
  const TreatmentDetailsScreen({super.key, required this.treatmentId});

  final String treatmentId;

  @override
  State<TreatmentDetailsScreen> createState() => _TreatmentDetailsScreenState();
}

class _TreatmentDetailsScreenState extends State<TreatmentDetailsScreen> {
  late final TreatmentController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppScope.read(context).treatmentController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadTreatment(widget.treatmentId);
    });
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove treatment?'),
        content: const Text(
          'This removes the treatment record from your history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final item = _controller.selected;
    final ok = await _controller.deleteTreatment(widget.treatmentId);
    if (!mounted) return;
    if (ok) {
      if (item != null) {
        await AppScope.read(context).trustController.load(
          cropBatchId: item.cropBatchId,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Treatment removed.')),
      );
      context.go(AppRoutes.treatments);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Treatment details',
      actions: [
        IconButton(
          tooltip: 'Edit',
          onPressed: () =>
              context.push(AppRoutes.treatmentEditPath(widget.treatmentId)),
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          switch (_controller.detailState) {
            case LoadState.loading:
            case LoadState.idle:
              return const LoadingWidget(message: 'Loading treatment…');
            case LoadState.error:
            case LoadState.empty:
              return AppErrorView(
                message: _controller.errorMessage ?? 'Treatment not found.',
                onRetry: () => _controller.loadTreatment(widget.treatmentId),
              );
            case LoadState.success:
              final item = _controller.selected!;
              return ResponsiveContent(
                child: ListView(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                        StatusBadge(
                          label: item.status.displayName,
                          tone: _toneFor(item.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.cropLabel,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      child: Column(
                        children: [
                          _Row(
                            label: 'Date',
                            value: DateFormatters.format(item.date),
                          ),
                          const Divider(height: AppSpacing.lg),
                          _Row(
                            label: 'Status',
                            value: item.status.displayName,
                          ),
                          const Divider(height: AppSpacing.lg),
                          _Row(
                            label: 'Updated',
                            value: DateFormatters.format(item.updatedAt),
                          ),
                        ],
                      ),
                    ),
                    if (item.notes != null && item.notes!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      const SectionHeader(title: 'Notes'),
                      AppCard(child: Text(item.notes!)),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    const SectionHeader(title: 'Actions'),
                    AppButton(
                      label: 'View trust score',
                      icon: Icons.verified_outlined,
                      onPressed: () => context.push(
                        AppRoutes.trustScorePath(cropId: item.cropBatchId),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: 'View crop batch',
                      variant: AppButtonVariant.outlined,
                      icon: Icons.grass_outlined,
                      onPressed: () => context.push(
                        AppRoutes.cropDetailsPath(item.cropBatchId),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: 'Edit treatment',
                      variant: AppButtonVariant.outlined,
                      icon: Icons.edit_outlined,
                      onPressed: () => context.push(
                        AppRoutes.treatmentEditPath(item.id),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: 'Remove treatment',
                      variant: AppButtonVariant.text,
                      icon: Icons.delete_outline,
                      onPressed: _confirmDelete,
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(value, style: theme.textTheme.titleSmall),
      ],
    );
  }
}

// Reuse tone helper from list screen file.
StatusBadgeTone _toneFor(TreatmentStatus status) => switch (status) {
  TreatmentStatus.completed => StatusBadgeTone.success,
  TreatmentStatus.inProgress => StatusBadgeTone.info,
  TreatmentStatus.planned => StatusBadgeTone.warning,
  TreatmentStatus.cancelled => StatusBadgeTone.neutral,
};
