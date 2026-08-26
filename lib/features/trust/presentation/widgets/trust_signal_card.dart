import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../models/trust_score.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/status_badge.dart';

class TrustSignalCard extends StatelessWidget {
  const TrustSignalCard({super.key, required this.signal});

  final TrustSignal signal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final positive = signal.contribution >= 0;
    final tone = positive ? StatusBadgeTone.success : StatusBadgeTone.warning;
    final color = positive ? AppColors.success : AppColors.warning;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(signal.name, style: theme.textTheme.titleSmall),
              ),
              StatusBadge(label: signal.statusLabel, tone: tone),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${positive ? '+' : ''}${(signal.contribution * 100).toStringAsFixed(0)}% contribution',
            style: theme.textTheme.labelLarge?.copyWith(color: color),
          ),
          if (signal.description != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              signal.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
