import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'app_card.dart';
import 'status_badge.dart';

/// Generic analysis / verification result presentation.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.title,
    required this.resultLabel,
    this.confidence,
    this.severityLabel,
    this.severityTone = StatusBadgeTone.neutral,
    this.timestampLabel,
    this.details,
    this.leading,
  });

  final String title;
  final String resultLabel;
  final double? confidence;
  final String? severityLabel;
  final StatusBadgeTone severityTone;
  final String? timestampLabel;
  final String? details;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(resultLabel, style: theme.textTheme.headlineSmall),
                  ],
                ),
              ),
              if (severityLabel != null)
                StatusBadge(label: severityLabel!, tone: severityTone),
            ],
          ),
          if (confidence != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Confidence ${(confidence! * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (timestampLabel != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              timestampLabel!,
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (details != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(details!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
