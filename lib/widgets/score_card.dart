import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'app_card.dart';

/// Circular trust / health score presentation used across modules.
class ScoreCard extends StatelessWidget {
  const ScoreCard({
    super.key,
    required this.title,
    required this.score,
    this.maxScore = 100,
    this.subtitle,
    this.confidence,
    this.onTap,
  });

  final String title;
  final double score;
  final double maxScore;
  final String? subtitle;
  final double? confidence;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = (score / maxScore).clamp(0.0, 1.0);
    final color = ratio >= 0.75
        ? AppColors.trustHigh
        : ratio >= 0.5
        ? AppColors.trustMedium
        : AppColors.trustLow;

    return AppCard(
      onTap: onTap,
      semanticLabel: '$title score ${score.toStringAsFixed(0)}',
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 7,
                  backgroundColor: AppColors.surfaceMuted,
                  color: color,
                ),
                Text(
                  score.toStringAsFixed(0),
                  style: theme.textTheme.titleLarge?.copyWith(color: color),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                if (confidence != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Confidence ${(confidence! * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
