import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../models/disease_severity.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/status_badge.dart';

abstract final class SeverityPresentation {
  static Color color(DiseaseSeverityLevel level) => switch (level) {
    DiseaseSeverityLevel.healthy => AppColors.severityHealthy,
    DiseaseSeverityLevel.mild => AppColors.severityMild,
    DiseaseSeverityLevel.moderate => AppColors.severityModerate,
    DiseaseSeverityLevel.severe => AppColors.severitySevere,
    DiseaseSeverityLevel.critical => AppColors.severityCritical,
  };

  static StatusBadgeTone tone(DiseaseSeverityLevel level) => switch (level) {
    DiseaseSeverityLevel.healthy => StatusBadgeTone.success,
    DiseaseSeverityLevel.mild => StatusBadgeTone.info,
    DiseaseSeverityLevel.moderate => StatusBadgeTone.warning,
    DiseaseSeverityLevel.severe => StatusBadgeTone.warning,
    DiseaseSeverityLevel.critical => StatusBadgeTone.error,
  };

  static IconData icon(DiseaseSeverityLevel level) => switch (level) {
    DiseaseSeverityLevel.healthy => Icons.check_circle_outline,
    DiseaseSeverityLevel.mild => Icons.eco_outlined,
    DiseaseSeverityLevel.moderate => Icons.warning_amber_outlined,
    DiseaseSeverityLevel.severe => Icons.report_gmailerrorred_outlined,
    DiseaseSeverityLevel.critical => Icons.dangerous_outlined,
  };
}

class SeverityIndicator extends StatelessWidget {
  const SeverityIndicator({
    super.key,
    required this.level,
    required this.score,
    this.showExplanation = true,
  });

  final DiseaseSeverityLevel level;
  final double score;
  final bool showExplanation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = SeverityPresentation.color(level);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(SeverityPresentation.icon(level), color: activeColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Disease severity', style: theme.textTheme.titleMedium),
              ),
              StatusBadge(
                label: '${level.levelIndex}. ${level.displayName}',
                tone: SeverityPresentation.tone(level),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (final item in DiseaseSeverityLevel.values) ...[
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: item == level
                              ? SeverityPresentation.color(item)
                              : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(99),
                          border: item == level
                              ? Border.all(color: activeColor, width: 1.5)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.levelIndex}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: item == level
                              ? activeColor
                              : AppColors.textSecondary,
                          fontWeight:
                              item == level ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item != DiseaseSeverityLevel.critical)
                  const SizedBox(width: 4),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Severity score: ${score.toStringAsFixed(0)} / 100',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (showExplanation) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(level.explanation, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
