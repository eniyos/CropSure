import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/load_state.dart';
import '../../../models/weather.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_error_view.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/status_badge.dart';
import '../controllers/weather_controller.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late final WeatherController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppScope.read(context).weatherController;
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.load());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Weather',
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          switch (_controller.state) {
            case LoadState.loading:
            case LoadState.idle:
              return const LoadingWidget(message: 'Loading weather…');
            case LoadState.error:
              return AppErrorView(
                message: _controller.errorMessage ?? 'Could not load weather.',
                onRetry: _controller.load,
              );
            case LoadState.empty:
            case LoadState.success:
              final report = _controller.report;
              if (report == null) {
                return AppErrorView(
                  message: 'Weather data is unavailable.',
                  onRetry: _controller.load,
                );
              }
              return RefreshIndicator(
                onRefresh: _controller.load,
                child: ResponsiveContent(
                  maxWidth: 720,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Text(report.locationLabel, style: theme.textTheme.headlineSmall),
                      Text(
                        'Updated ${DateFormatters.formatWithTime(report.updatedAt)}',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.cloud_outlined,
                                  color: AppColors.info,
                                  size: 36,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    report.condition,
                                    style: theme.textTheme.titleLarge,
                                  ),
                                ),
                                Text(
                                  '${report.temperatureC.toStringAsFixed(0)}°C',
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: AppSpacing.md,
                              runSpacing: AppSpacing.xs,
                              children: [
                                _Metric(
                                  label: 'Humidity',
                                  value:
                                      '${report.humidityPercent.toStringAsFixed(0)}%',
                                ),
                                if (report.rainChancePercent != null)
                                  _Metric(
                                    label: 'Rain chance',
                                    value:
                                        '${report.rainChancePercent!.toStringAsFixed(0)}%',
                                  ),
                                if (report.rainfallMm != null)
                                  _Metric(
                                    label: 'Rainfall',
                                    value:
                                        '${report.rainfallMm!.toStringAsFixed(1)} mm',
                                  ),
                                if (report.windKph != null)
                                  _Metric(
                                    label: 'Wind',
                                    value:
                                        '${report.windKph!.toStringAsFixed(0)} km/h',
                                  ),
                              ],
                            ),
                            if (report.advisory != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(report.advisory!, style: theme.textTheme.bodyMedium),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const SectionHeader(
                        title: '5-day forecast',
                        subtitle: 'Provided by the weather service',
                      ),
                      ...report.forecast.map(
                        (day) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _ForecastTile(day: day),
                        ),
                      ),
                      if (report.agriculturalRisks.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        const SectionHeader(
                          title: 'Agricultural risks',
                          subtitle: 'When supplied by the backend weather service',
                        ),
                        ...report.agriculturalRisks.map(
                          (risk) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _RiskCard(risk: risk),
                          ),
                        ),
                      ],
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

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _ForecastTile extends StatelessWidget {
  const _ForecastTile({required this.day});

  final WeatherForecastDay day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              DateFormat('EEE\ndd MMM').format(day.date),
              style: theme.textTheme.labelMedium,
            ),
          ),
          Expanded(
            child: Text(day.condition, style: theme.textTheme.titleSmall),
          ),
          Text(
            '${day.highC.toStringAsFixed(0)}° / ${day.lowC.toStringAsFixed(0)}°',
            style: theme.textTheme.titleSmall,
          ),
          if (day.rainChancePercent != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${day.rainChancePercent!.toStringAsFixed(0)}%',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.info,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  const _RiskCard({required this.risk});

  final AgriculturalRisk risk;

  @override
  Widget build(BuildContext context) {
    final tone = switch (risk.levelLabel.toLowerCase()) {
      'high' || 'critical' => StatusBadgeTone.error,
      'moderate' || 'medium' => StatusBadgeTone.warning,
      _ => StatusBadgeTone.success,
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  risk.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              StatusBadge(label: risk.levelLabel, tone: tone),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(risk.description, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
