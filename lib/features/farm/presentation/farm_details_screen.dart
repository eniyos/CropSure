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
import '../../../widgets/loading_widget.dart';
import '../../../widgets/scroll_reveal.dart';
import '../../../widgets/section_header.dart';
import '../controllers/farm_controller.dart';

class FarmDetailsScreen extends StatefulWidget {
  const FarmDetailsScreen({super.key, required this.farmId});

  final String farmId;

  @override
  State<FarmDetailsScreen> createState() => _FarmDetailsScreenState();
}

class _FarmDetailsScreenState extends State<FarmDetailsScreen> {
  late final FarmController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppScope.read(context).farmController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadFarm(widget.farmId);
    });
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove farm?'),
        content: const Text(
          'This removes the farm from your list. Crop batches linked to it '
          'may need updating.',
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
    final ok = await _controller.deleteFarm(widget.farmId);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farm removed.')),
      );
      context.go(AppRoutes.farms);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Farm details',
      actions: [
        IconButton(
          tooltip: 'Edit',
          onPressed: () => context.push(AppRoutes.farmEditPath(widget.farmId)),
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          switch (_controller.detailState) {
            case LoadState.loading:
            case LoadState.idle:
              return const LoadingWidget(message: 'Loading farm…');
            case LoadState.error:
            case LoadState.empty:
              return AppErrorView(
                message: _controller.errorMessage ?? 'Farm not found.',
                onRetry: () => _controller.loadFarm(widget.farmId),
              );
            case LoadState.success:
              final farm = _controller.selected!;
              return RefreshIndicator(
                onRefresh: () => _controller.loadFarm(widget.farmId),
                child: ResponsiveContent(
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
                          height: 200,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AgriNetworkImage(
                                url: AgriAssets.dawnField,
                                fit: BoxFit.cover,
                                placeholderColor: AppColors.leafDeep,
                              ),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
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
                                    const Spacer(),
                                    Text(
                                      farm.name,
                                      style: AppTypography.display(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.white,
                                      ),
                                    ),
                                    Text(
                                      farm.location,
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
                      delay: const Duration(milliseconds: 80),
                      child: AppCard(
                        glass: true,
                        child: Column(
                          children: [
                            _DetailRow(
                              label: 'Area',
                              value:
                                  '${farm.areaHectares.toStringAsFixed(1)} hectares',
                            ),
                            const Divider(height: AppSpacing.lg),
                            _DetailRow(
                              label: 'Created',
                              value: DateFormatters.format(farm.createdAt),
                            ),
                            const Divider(height: AppSpacing.lg),
                            _DetailRow(
                              label: 'Last updated',
                              value: DateFormatters.format(farm.updatedAt),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (farm.notes != null && farm.notes!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      ScrollReveal(
                        delay: const Duration(milliseconds: 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(
                              eyebrow: 'Notes',
                              title: 'Field notes',
                            ),
                            AppCard(
                              glass: true,
                              child: Text(
                                farm.notes!,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
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
                            eyebrow: 'Actions',
                            title: 'What next?',
                          ),
                          AppButton(
                            label: 'View crop batches',
                            icon: Icons.grass_outlined,
                            onPressed: () =>
                                context.go(AppRoutes.cropsForFarmPath(farm.id)),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppButton(
                            label: 'Edit farm',
                            variant: AppButtonVariant.outlined,
                            icon: Icons.edit_outlined,
                            onPressed: () =>
                                context.push(AppRoutes.farmEditPath(farm.id)),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppButton(
                            label: 'Remove farm',
                            variant: AppButtonVariant.text,
                            icon: Icons.delete_outline,
                            onPressed: _confirmDelete,
                          ),
                        ],
                      ),
                    ),
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
