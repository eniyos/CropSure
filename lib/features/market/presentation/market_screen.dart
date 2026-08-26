import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/load_state.dart';
import '../../../models/market_price.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_error_view.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/section_header.dart';
import '../controllers/market_controller.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  late final MarketController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppScope.read(context).marketController;
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.load());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Market prices',
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          switch (_controller.state) {
            case LoadState.loading:
            case LoadState.idle:
              return const LoadingWidget(message: 'Loading market prices…');
            case LoadState.error:
              return AppErrorView(
                message:
                    _controller.errorMessage ?? 'Could not load market prices.',
                onRetry: _controller.load,
              );
            case LoadState.empty:
              return EmptyState(
                title: 'No market prices',
                message: 'Market data will appear when the backend provides it.',
                icon: Icons.storefront_outlined,
                actionLabel: 'Retry',
                onAction: _controller.load,
              );
            case LoadState.success:
              final overview = _controller.overview!;
              return RefreshIndicator(
                onRefresh: _controller.load,
                child: ResponsiveContent(
                  maxWidth: 720,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Text(
                        'Nearby market rates',
                        style: theme.textTheme.headlineSmall,
                      ),
                      Text(
                        'Updated ${DateFormatters.formatWithTime(overview.updatedAt)}',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (overview.priceHistory.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        SectionHeader(
                          title: overview.featuredCrop == null
                              ? 'Price trend'
                              : '${overview.featuredCrop} price trend',
                          subtitle: 'Last 7 days (backend market service)',
                        ),
                        _PriceTrendChart(points: overview.priceHistory),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      const SectionHeader(title: 'Current prices'),
                      ...overview.prices.map(
                        (price) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _PriceCard(price: price),
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

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.price});

  final MarketPrice price;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final change = price.changePercent;
    final changeColor = change == null
        ? AppColors.textSecondary
        : change >= 0
        ? AppColors.success
        : AppColors.error;

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(price.crop, style: theme.textTheme.titleMedium),
                Text(
                  price.marketName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Updated ${DateFormatters.formatWithTime(price.updatedAt)}',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${price.price.toStringAsFixed(1)} ${price.unit}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              if (change != null)
                Text(
                  '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
                  style: theme.textTheme.labelMedium?.copyWith(color: changeColor),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceTrendChart extends StatelessWidget {
  const _PriceTrendChart({required this.points});

  final List<MarketPricePoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].price),
    ];
    final minY = points.map((p) => p.price).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = points.map((p) => p.price).reduce((a, b) => a > b ? a : b) + 2;

    return AppCard(
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: AppColors.outline.withValues(alpha: 0.7),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (value, meta) => Text(
                    value.toStringAsFixed(0),
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= points.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        DateFormat('dd/MM').format(points[index].date),
                        style: theme.textTheme.labelSmall,
                      ),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.primary,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
