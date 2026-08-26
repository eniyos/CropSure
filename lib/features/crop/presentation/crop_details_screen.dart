import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/agri_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/load_state.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_error_view.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/agri_network_image.dart';
import '../../../widgets/health_status.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/score_card.dart';
import '../../../widgets/scroll_reveal.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/status_badge.dart';
import '../controllers/crop_controller.dart';

class CropDetailsScreen extends StatefulWidget {
  const CropDetailsScreen({super.key, required this.cropId});

  final String cropId;

  @override
  State<CropDetailsScreen> createState() => _CropDetailsScreenState();
}

class _CropDetailsScreenState extends State<CropDetailsScreen> {
  late final CropController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppScope.read(context).cropController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadCrop(widget.cropId);
    });
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove crop batch?'),
        content: const Text(
          'This removes the crop batch from your list. Related analysis '
          'history will remain available once the backend is connected.',
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
    final ok = await _controller.deleteCrop(widget.cropId);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crop batch removed.')),
      );
      context.go(AppRoutes.crops);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Crop batch',
      actions: [
        IconButton(
          tooltip: 'Edit',
          onPressed: () => context.push(AppRoutes.cropEditPath(widget.cropId)),
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          switch (_controller.detailState) {
            case LoadState.loading:
            case LoadState.idle:
              return const LoadingWidget(message: 'Loading crop batch…');
            case LoadState.error:
            case LoadState.empty:
              return AppErrorView(
                message: _controller.errorMessage ?? 'Crop batch not found.',
                onRetry: () => _controller.loadCrop(widget.cropId),
              );
            case LoadState.success:
              final crop = _controller.selected!;
              return ResponsiveContent(
                child: ListView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  children: [
                    ScrollReveal(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusXl),
                        child: SizedBox(
                          height: 210,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AgriNetworkImage(
                                url: AgriAssets.greenCanopy,
                                fit: BoxFit.cover,
                                placeholderColor: AppColors.leaf,
                              ),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.1),
                                      AppColors.leafDeep.withValues(alpha: 0.9),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: StatusBadge(
                                        label: crop.healthStatus.displayName,
                                        tone: HealthStatusPresentation.tone(
                                          crop.healthStatus,
                                        ),
                                        icon: HealthStatusPresentation.icon(
                                          crop.healthStatus,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      crop.displayTitle,
                                      style: AppTypography.display(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.white,
                                      ),
                                    ),
                                    Text(
                                      crop.farmName,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: AppColors.white
                                            .withValues(alpha: 0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ScrollReveal(
                      delay: const Duration(milliseconds: 70),
                      child: AppCard(
                        glass: true,
                        child: Column(
                          children: [
                            _DetailRow(
                              label: 'Growth stage',
                              value: crop.growthStage.displayName,
                            ),
                            const Divider(height: AppSpacing.lg),
                            _DetailRow(
                              label: 'Planted',
                              value: DateFormatters.format(crop.plantingDate),
                            ),
                            if (crop.areaHectares != null) ...[
                              const Divider(height: AppSpacing.lg),
                              _DetailRow(
                                label: 'Area',
                                value:
                                    '${crop.areaHectares!.toStringAsFixed(1)} ha',
                              ),
                            ],
                            const Divider(height: AppSpacing.lg),
                            _DetailRow(
                              label: 'Updated',
                              value: DateFormatters.format(crop.updatedAt),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (crop.trustScore != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      ScrollReveal(
                        delay: const Duration(milliseconds: 110),
                        child: ScoreCard(
                          title: 'Dynamic Crop Trust Score',
                          score: crop.trustScore!,
                          subtitle: 'From latest trust engine snapshot',
                          onTap: () => context.push(
                            AppRoutes.trustScorePath(cropId: crop.id),
                          ),
                        ),
                      ),
                    ],
                    if (crop.notes != null && crop.notes!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      ScrollReveal(
                        delay: const Duration(milliseconds: 130),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(
                              eyebrow: 'Notes',
                              title: 'Batch notes',
                            ),
                            AppCard(glass: true, child: Text(crop.notes!)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    ScrollReveal(
                      delay: const Duration(milliseconds: 160),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SectionHeader(
                            eyebrow: 'Workflow',
                            title: 'Quick access',
                            subtitle: 'AI, trust, treatments, and passport',
                          ),
                          AppButton(
                            label: 'AI disease analysis',
                            icon: Icons.biotech_outlined,
                            onPressed: () => context.push(
                              AppRoutes.analyzeCropPath(cropId: crop.id),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppButton(
                            label: 'View trust score',
                            variant: AppButtonVariant.outlined,
                            icon: Icons.verified_outlined,
                            onPressed: () => context.push(
                              AppRoutes.trustScorePath(cropId: crop.id),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppButton(
                            label: 'Treatment history',
                            variant: AppButtonVariant.outlined,
                            icon: Icons.medical_services_outlined,
                            onPressed: () => context.push(
                              AppRoutes.treatmentsPath(cropId: crop.id),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppButton(
                            label: 'Digital crop passport',
                            variant: AppButtonVariant.outlined,
                            icon: Icons.badge_outlined,
                            onPressed: () => context.push(
                              AppRoutes.passportForCropPath(crop.id),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppButton(
                            label: 'Edit crop batch',
                            variant: AppButtonVariant.outlined,
                            icon: Icons.edit_outlined,
                            onPressed: () =>
                                context.push(AppRoutes.cropEditPath(crop.id)),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppButton(
                            label: 'Remove crop batch',
                            variant: AppButtonVariant.text,
                            icon: Icons.delete_outline,
                            onPressed: _confirmDelete,
                          ),
                        ],
                      ),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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
