import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../models/disease_analysis.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/status_badge.dart';

class YieldPredictionCard extends StatelessWidget {
  const YieldPredictionCard({super.key, required this.prediction});

  final YieldPrediction prediction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.agriculture_outlined, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Yield prediction', style: theme.textTheme.titleMedium),
              ),
              const StatusBadge(
                label: 'Model estimate',
                tone: StatusBadgeTone.info,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${prediction.predictedYield.toStringAsFixed(1)} ${prediction.unit}',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            prediction.seasonLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (prediction.confidence != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Confidence ${(prediction.confidence! * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.labelLarge,
            ),
          ],
          if (prediction.asOf != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'As of ${DateFormatters.formatWithTime(prediction.asOf)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (prediction.explanation != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(prediction.explanation!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
