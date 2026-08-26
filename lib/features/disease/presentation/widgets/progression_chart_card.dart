import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../models/disease_analysis.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/status_badge.dart';

class ProgressionChartCard extends StatelessWidget {
  const ProgressionChartCard({
    super.key,
    required this.progression,
  });

  final DiseaseProgression progression;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = progression.points;
    if (points.isEmpty) {
      return const AppCard(child: Text('No progression data available.'));
    }

    final byDay = {
      for (final point in points) point.dayOffset: point,
    };
    final spots = [
      for (final point in points)
        FlSpot(point.dayOffset.toDouble(), point.riskScore),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${progression.horizon.label} prediction',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const StatusBadge(
                label: 'Prediction',
                tone: StatusBadgeTone.info,
                icon: Icons.timeline,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            progression.riskLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
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
                      reservedSize: 34,
                      interval: 25,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: progression.horizon == ProgressionHorizon.days7
                          ? 1
                          : 4,
                      getTitlesWidget: (value, meta) {
                        final match = byDay[value.toInt()];
                        if (match == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat('dd/MM').format(match.date),
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
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touched) => touched
                        .map(
                          (spot) => LineTooltipItem(
                            'Day ${spot.x.toInt()}\nRisk ${spot.y.toStringAsFixed(0)}',
                            theme.textTheme.labelMedium!.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            progression.explanation,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
