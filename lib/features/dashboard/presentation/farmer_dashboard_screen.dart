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
import '../../../models/dashboard_summary.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_error_view.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/agri_network_image.dart';
import '../../../widgets/brand_mark.dart';
import '../../../widgets/health_status.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/living_background.dart';
import '../../../widgets/score_card.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/status_badge.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  late final DashboardController _dashboard;
  late final AuthController _auth;

  @override
  void initState() {
    super.initState();
    final deps = AppScope.read(context);
    _dashboard = deps.dashboardController;
    _auth = deps.authController;
    WidgetsBinding.instance.addPostFrameCallback((_) => _dashboard.load());
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final name = _auth.user?.fullName ?? 'Farmer';

    return AppScaffold(
      title: 'CropSure',
      showBrandInTitle: true,
      showBackButton: false,
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => context.push(AppRoutes.notifications),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        IconButton(
          tooltip: 'Sign out',
          onPressed: () => _auth.logout(),
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
      body: AppAtmosphere(
        showFieldPhoto: true,
        scene: AgriScene.mistMorning,
        child: ListenableBuilder(
        listenable: _dashboard,
        builder: (context, _) {
          switch (_dashboard.state) {
            case LoadState.loading:
            case LoadState.idle:
              return const LoadingWidget(message: 'Loading your farm overview…');
            case LoadState.error:
              return AppErrorView(
                message:
                    _dashboard.errorMessage ?? 'Could not load the dashboard.',
                onRetry: _dashboard.load,
              );
            case LoadState.empty:
            case LoadState.success:
              final summary = _dashboard.summary;
              if (summary == null) {
                return AppErrorView(
                  message: 'Dashboard data is unavailable.',
                  onRetry: _dashboard.load,
                );
              }
              return RefreshIndicator(
                onRefresh: _dashboard.load,
                child: ResponsiveContent(
                  maxWidth: 720,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      _FieldHero(
                        greeting: _greeting(),
                        name: name,
                        summary: summary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ScoreCard(
                        title: 'Dynamic Crop Trust Score',
                        score: summary.trustScore,
                        confidence: summary.trustConfidence,
                        subtitle:
                            'Updated ${DateFormatters.formatWithTime(summary.trustUpdatedAt)}',
                        onTap: () => context.push(AppRoutes.trustScore),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SectionHeader(
                        eyebrow: 'Workflow',
                        title: 'Quick actions',
                        actionLabel: 'Farms',
                        onAction: () => context.go(AppRoutes.farms),
                      ),
                      const _QuickActionsGrid(),
                      const SizedBox(height: AppSpacing.lg),
                      SectionHeader(
                        eyebrow: 'Crops',
                        title: 'Active crop batches',
                        actionLabel: 'See all',
                        onAction: () => context.go(AppRoutes.crops),
                      ),
                      if (summary.activeBatches.isEmpty)
                        const AppCard(
                          child: Text('No active crop batches yet.'),
                        )
                      else
                        ...summary.activeBatches.take(3).map(
                          (crop) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _CropSummaryTile(crop: crop),
                          ),
                        ),
                      if (summary.latestDisease != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        const SectionHeader(title: 'Latest disease analysis'),
                        _DiseaseCard(disease: summary.latestDisease!),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      const SectionHeader(title: 'Weather'),
                      if (summary.weather != null)
                        _WeatherCard(
                          weather: summary.weather!,
                          onTap: () => context.push(AppRoutes.weather),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      const SectionHeader(title: 'Market'),
                      if (summary.market != null)
                        _MarketCard(
                          market: summary.market!,
                          onTap: () => context.push(AppRoutes.market),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      SectionHeader(
                        title: 'Recent notifications',
                        actionLabel: 'See all',
                        onAction: () => context.push(AppRoutes.notifications),
                      ),
                      ...summary.notifications.map(
                        (n) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _NotificationTile(
                            notification: n,
                            onTap: () => context.push(
                              AppRoutes.notificationDetailsPath(n.id),
                            ),
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
      ),
    );
  }
}

class _FieldHero extends StatelessWidget {
  const _FieldHero({
    required this.greeting,
    required this.name,
    required this.summary,
  });

  final String greeting;
  final String name;
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.leafDeep.withValues(alpha: 0.28),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: SizedBox(
          height: 236,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AgriNetworkImage(
                url: AgriAssets.dawnField,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.15),
                placeholderColor: AppColors.leafDeep,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      AppColors.leafDeep.withValues(alpha: 0.55),
                      AppColors.ink.withValues(alpha: 0.92),
                    ],
                    stops: const [0, 0.45, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.harvest,
                        letterSpacing: 2.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      name,
                      style: AppTypography.display(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        letterSpacing: -0.6,
                      ),
                    ),
                    Text(
                      'Your fields, scored for trust',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.82),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: _HeroStat(
                            label: 'Healthy',
                            value: '${summary.healthyBatchCount}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _HeroStat(
                            label: 'At risk',
                            value: '${summary.atRiskBatchCount}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _HeroStat(
                            label: 'Active',
                            value: '${summary.activeBatches.length}',
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

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.display(
              fontSize: 20,
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

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        label: 'Add Farm',
        icon: Icons.add_business_outlined,
        onTap: () => context.push(AppRoutes.farmNew),
      ),
      _QuickAction(
        label: 'Add Crop',
        icon: Icons.grass_outlined,
        onTap: () => context.push(AppRoutes.cropNew),
      ),
      _QuickAction(
        label: 'Analyze Crop',
        icon: Icons.biotech_outlined,
        onTap: () => context.push(AppRoutes.analyzeCrop),
      ),
      _QuickAction(
        label: 'View Passport',
        icon: Icons.badge_outlined,
        onTap: () => context.push(AppRoutes.passport),
      ),
      _QuickAction(
        label: 'Offline / Sync',
        icon: Icons.cloud_sync_outlined,
        onTap: () => context.push(AppRoutes.syncOffline),
      ),
      _QuickAction(
        label: 'Trust Score',
        icon: Icons.verified_outlined,
        onTap: () => context.push(AppRoutes.trustScore),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = 3;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.05,
          children: actions,
        );
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.white.withValues(alpha: 0.92),
                AppColors.green50.withValues(alpha: 0.88),
              ],
            ),
            border: Border.all(color: AppColors.leaf.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.leaf.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.leaf, size: 22),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.15,
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

class _CropSummaryTile extends StatelessWidget {
  const _CropSummaryTile({required this.crop});

  final CropBatch crop;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(AppRoutes.cropDetailsPath(crop.id)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop.displayTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${crop.farmName} · ${crop.growthStage.displayName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          StatusBadge(
            label: crop.healthStatus.displayName,
            tone: HealthStatusPresentation.tone(crop.healthStatus),
          ),
        ],
      ),
    );
  }
}

class _DiseaseCard extends StatelessWidget {
  const _DiseaseCard({required this.disease});

  final LatestDiseaseSummary disease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: () => context.push(AppRoutes.cropDetailsPath(disease.cropBatchId)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(disease.diseaseName, style: theme.textTheme.titleMedium),
              ),
              StatusBadge(
                label: disease.severityLabel,
                tone: StatusBadgeTone.warning,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(disease.cropLabel, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Confidence ${(disease.confidence * 100).toStringAsFixed(0)}% · '
            '${DateFormatters.formatWithTime(disease.analyzedAt)}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({required this.weather, this.onTap});

  final WeatherSummary weather;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_outlined, color: AppColors.info),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(weather.condition, style: theme.textTheme.titleMedium),
              ),
              Text(
                '${weather.temperatureC.toStringAsFixed(0)}°C',
                style: theme.textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Humidity ${weather.humidityPercent.toStringAsFixed(0)}%'
            '${weather.rainChancePercent != null ? ' · Rain ${weather.rainChancePercent!.toStringAsFixed(0)}%' : ''}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (weather.advisory != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(weather.advisory!, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _MarketCard extends StatelessWidget {
  const _MarketCard({required this.market, this.onTap});

  final MarketSummary market;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(market.crop, style: theme.textTheme.titleMedium),
                Text(
                  market.marketName,
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  'Updated ${DateFormatters.formatWithTime(market.updatedAt)}',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          Text(
            '${market.price.toStringAsFixed(1)} ${market.unit}',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, this.onTap});

  final NotificationSummary notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            notification.isRead
                ? Icons.notifications_none
                : Icons.notifications_active_outlined,
            color: notification.isRead
                ? AppColors.textSecondary
                : AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.title, style: theme.textTheme.titleSmall),
                Text(notification.body, style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  DateFormatters.formatWithTime(notification.createdAt),
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
