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
import '../../../models/farm.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_error_view.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/agri_network_image.dart';
import '../../../widgets/brand_mark.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/living_background.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/offline_banner.dart';
import '../../../widgets/scroll_reveal.dart';
import '../controllers/farm_controller.dart';

class FarmListScreen extends StatefulWidget {
  const FarmListScreen({super.key});

  @override
  State<FarmListScreen> createState() => _FarmListScreenState();
}

class _FarmListScreenState extends State<FarmListScreen> {
  late final FarmController _controller;
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    _controller = AppScope.read(context).farmController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadFarms();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  String _farmImage(int index) {
    const images = [
      AgriAssets.dawnField,
      AgriAssets.greenCanopy,
      AgriAssets.mistMorning,
      AgriAssets.soilHands,
      AgriAssets.harvest,
    ];
    return images[index % images.length];
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Farms',
      showBrandInTitle: false,
      actions: [
        IconButton(
          tooltip: 'Add farm',
          onPressed: () => context.push(AppRoutes.farmNew),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'farms-fab',
        onPressed: () => context.push(AppRoutes.farmNew),
        icon: const Icon(Icons.add),
        label: const Text('Add farm'),
      ),
      body: AppAtmosphere(
        showFieldPhoto: true,
        scene: AgriScene.dawnField,
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            switch (_controller.listState) {
              case LoadState.loading:
              case LoadState.idle:
                return const LoadingWidget(message: 'Loading farms…');
              case LoadState.error:
                return AppErrorView(
                  message: _controller.errorMessage ?? 'Could not load farms.',
                  onRetry: _controller.loadFarms,
                );
              case LoadState.empty:
                return EmptyState(
                  title: 'No farms yet',
                  message: 'Add your first farm to start tracking crops.',
                  icon: Icons.agriculture_outlined,
                  actionLabel: 'Add farm',
                  onAction: () => context.push(AppRoutes.farmNew),
                );
              case LoadState.success:
                final farms = _controller.farms;
                final totalHa = farms.fold<double>(
                  0,
                  (sum, f) => sum + f.areaHectares,
                );
                final sync = AppScope.read(context).syncController;
                return RefreshIndicator(
                  onRefresh: _controller.loadFarms,
                  child: ResponsiveContent(
                    maxWidth: 720,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      100,
                    ),
                    child: ListView.builder(
                      controller: _scroll,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      itemCount: farms.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            children: [
                              ScrollReveal(
                                child: _FarmsHeroHeader(
                                  farmCount: farms.length,
                                  totalHa: totalHa,
                                  scrollController: _scroll,
                                ),
                              ),
                              CacheFreshnessBanner(
                                visible: _controller.servingFromCache,
                                cachedAt: sync.farmsCachedAt,
                              ),
                            ],
                          );
                        }
                        final farm = farms[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: ScrollReveal(
                            delay: Duration(milliseconds: 60 * (index - 1).clamp(0, 8)),
                            child: _FarmShowcaseCard(
                              farm: farm,
                              imageUrl: _farmImage(index - 1),
                            ),
                          ),
                        );
                      },
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

class _FarmsHeroHeader extends StatelessWidget {
  const _FarmsHeroHeader({
    required this.farmCount,
    required this.totalHa,
    required this.scrollController,
  });

  final int farmCount;
  final double totalHa;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: SizedBox(
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ParallaxImage(
                imageUrl: AgriAssets.greenCanopy,
                scrollController: scrollController,
                height: 200,
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
                    Text(
                      'YOUR LAND',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.harvest,
                        letterSpacing: 2.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Farms',
                      style: AppTypography.display(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        letterSpacing: -0.8,
                      ),
                    ),
                    Text(
                      'Fields mapped for trust and care',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _HeroChip(label: '$farmCount farms'),
                        const SizedBox(width: 8),
                        _HeroChip(label: '${totalHa.toStringAsFixed(1)} ha'),
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

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _FarmShowcaseCard extends StatefulWidget {
  const _FarmShowcaseCard({required this.farm, required this.imageUrl});

  final Farm farm;
  final String imageUrl;

  @override
  State<_FarmShowcaseCard> createState() => _FarmShowcaseCardState();
}

class _FarmShowcaseCardState extends State<_FarmShowcaseCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final farm = widget.farm;
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => context.push(AppRoutes.farmDetailsPath(farm.id)),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: AppCard(
          padding: EdgeInsets.zero,
          semanticLabel: 'Farm ${farm.name}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLg),
                ),
                child: SizedBox(
                  height: 140,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AgriNetworkImage(
                        url: widget.imageUrl,
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
                              AppColors.ink.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        bottom: 12,
                        right: 14,
                        child: Text(
                          farm.name,
                          style: AppTypography.display(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.place_outlined,
                                size: 16,
                                color: AppColors.leaf,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  farm.location,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${farm.areaHectares.toStringAsFixed(1)} hectares'
                            '${farm.updatedAt != null ? ' · ${DateFormatters.short.format(farm.updatedAt!)}' : ''}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.leaf,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.green50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.leaf,
                      ),
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
