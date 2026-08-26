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
import '../../../models/crop_batch.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_error_view.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/agri_network_image.dart';
import '../../../widgets/brand_mark.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/health_status.dart';
import '../../../widgets/living_background.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/offline_banner.dart';
import '../../../widgets/scroll_reveal.dart';
import '../../../widgets/status_badge.dart';
import '../controllers/crop_controller.dart';

class CropListScreen extends StatefulWidget {
  const CropListScreen({super.key, this.farmId});

  final String? farmId;

  @override
  State<CropListScreen> createState() => _CropListScreenState();
}

class _CropListScreenState extends State<CropListScreen> {
  late final CropController _controller;
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    _controller = AppScope.read(context).cropController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadCrops(farmId: widget.farmId);
    });
  }

  @override
  void didUpdateWidget(covariant CropListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.farmId != widget.farmId) {
      _controller.loadCrops(farmId: widget.farmId);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  String _cropImage(CropBatch crop, int index) {
    final key = crop.cropType.toLowerCase();
    if (key.contains('wheat') || key.contains('grain')) {
      return AgriAssets.dawnField;
    }
    if (key.contains('rice') || key.contains('paddy')) {
      return AgriAssets.mistMorning;
    }
    if (key.contains('veg') || key.contains('tomato')) {
      return AgriAssets.harvest;
    }
    const fallback = [
      AgriAssets.greenCanopy,
      AgriAssets.soilHands,
      AgriAssets.leafMacro,
      AgriAssets.harvest,
    ];
    return fallback[index % fallback.length];
  }

  void _openNew() {
    context.push(
      widget.farmId == null
          ? AppRoutes.cropNew
          : '${AppRoutes.cropNew}?farmId=${widget.farmId}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.farmId == null ? 'Crops' : 'Farm crops',
      actions: [
        IconButton(
          tooltip: 'Add crop batch',
          onPressed: _openNew,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'crops-fab',
        onPressed: _openNew,
        icon: const Icon(Icons.add),
        label: const Text('Add crop'),
      ),
      body: AppAtmosphere(
        showFieldPhoto: true,
        scene: AgriScene.greenCanopy,
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            switch (_controller.listState) {
              case LoadState.loading:
              case LoadState.idle:
                return const LoadingWidget(message: 'Loading crop batches…');
              case LoadState.error:
                return AppErrorView(
                  message: _controller.errorMessage ??
                      'Could not load crop batches.',
                  onRetry: () => _controller.loadCrops(farmId: widget.farmId),
                );
              case LoadState.empty:
                return EmptyState(
                  title: 'No crop batches',
                  message: 'Add a crop batch to track health and trust.',
                  icon: Icons.grass_outlined,
                  actionLabel: 'Add crop',
                  onAction: _openNew,
                );
              case LoadState.success:
                final crops = _controller.crops;
                final healthy = crops
                    .where((c) => c.healthStatus == CropHealthStatus.healthy)
                    .length;
                final atRisk = crops
                    .where(
                      (c) =>
                          c.healthStatus == CropHealthStatus.atRisk ||
                          c.healthStatus == CropHealthStatus.critical,
                    )
                    .length;
                final sync = AppScope.read(context).syncController;
                return RefreshIndicator(
                  onRefresh: () =>
                      _controller.loadCrops(farmId: widget.farmId),
                  child: ResponsiveContent(
                    maxWidth: 720,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      100,
                    ),
                    child: CustomScrollView(
                      controller: _scroll,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              ScrollReveal(
                                child: _CropsHeroHeader(
                                  cropCount: crops.length,
                                  healthy: healthy,
                                  atRisk: atRisk,
                                  scrollController: _scroll,
                                ),
                              ),
                              CacheFreshnessBanner(
                                visible: _controller.servingFromCache,
                                cachedAt: sync.cropsCachedAt,
                              ),
                            ],
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          sliver: SliverList.separated(
                            itemCount: crops.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final crop = crops[index];
                              return ScrollReveal(
                                delay: Duration(
                                  milliseconds: 55 * index.clamp(0, 10),
                                ),
                                child: _CropShowcaseCard(
                                  crop: crop,
                                  imageUrl: _cropImage(crop, index),
                                ),
                              );
                            },
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 24),
                        ),
                      ],
                    ),
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}

class _CropsHeroHeader extends StatelessWidget {
  const _CropsHeroHeader({
    required this.cropCount,
    required this.healthy,
    required this.atRisk,
    required this.scrollController,
  });

  final int cropCount;
  final int healthy;
  final int atRisk;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: SizedBox(
          height: 210,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ParallaxImage(
                imageUrl: AgriAssets.harvest,
                scrollController: scrollController,
                height: 210,
                factor: 0.16,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppColors.leaf.withValues(alpha: 0.25),
                      AppColors.leafDeep.withValues(alpha: 0.92),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GROWING NOW',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.harvest,
                        letterSpacing: 2.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Crop batches',
                      style: AppTypography.display(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        letterSpacing: -0.6,
                      ),
                    ),
                    Text(
                      'Health, stage, and trust in one glance',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: _StatGlass(
                            label: 'Batches',
                            value: '$cropCount',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatGlass(
                            label: 'Healthy',
                            value: '$healthy',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatGlass(
                            label: 'At risk',
                            value: '$atRisk',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatGlass extends StatelessWidget {
  const _StatGlass({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.display(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _CropShowcaseCard extends StatefulWidget {
  const _CropShowcaseCard({required this.crop, required this.imageUrl});

  final CropBatch crop;
  final String imageUrl;

  @override
  State<_CropShowcaseCard> createState() => _CropShowcaseCardState();
}

class _CropShowcaseCardState extends State<_CropShowcaseCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final crop = widget.crop;
    final theme = Theme.of(context);
    final trust = crop.trustScore;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => context.push(AppRoutes.cropDetailsPath(crop.id)),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: AppCard(
          padding: EdgeInsets.zero,
          semanticLabel: 'Crop ${crop.displayTitle}',
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 108,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(AppSpacing.radiusLg),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AgriNetworkImage(
                          url: widget.imageUrl,
                          fit: BoxFit.cover,
                          placeholderColor: AppColors.leaf,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.ink.withValues(alpha: 0.35),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                crop.displayTitle,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            StatusBadge(
                              label: crop.healthStatus.displayName,
                              tone: HealthStatusPresentation.tone(
                                crop.healthStatus,
                              ),
                              icon: HealthStatusPresentation.icon(
                                crop.healthStatus,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          crop.farmName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _SoftChip(
                              icon: Icons.timeline,
                              label: crop.growthStage.displayName,
                            ),
                            _SoftChip(
                              icon: Icons.calendar_today_outlined,
                              label: DateFormatters.format(crop.plantingDate),
                            ),
                            if (trust != null)
                              _SoftChip(
                                icon: Icons.verified_outlined,
                                label: 'Trust ${trust.toStringAsFixed(0)}',
                                accent: true,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SoftChip extends StatelessWidget {
  const _SoftChip({
    required this.icon,
    required this.label,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: accent
            ? AppColors.green50
            : AppColors.neutral100.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: accent ? AppColors.leaf : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: accent ? AppColors.leaf : AppColors.textSecondary,
              fontWeight: accent ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
