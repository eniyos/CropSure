import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

enum StatusBadgeTone { neutral, success, warning, error, info }

/// Status chip with label + icon so severity is not color-only.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = StatusBadgeTone.neutral,
    this.icon,
    this.showIcon = true,
  });

  final String label;
  final StatusBadgeTone tone;
  final IconData? icon;
  final bool showIcon;

  IconData? get _resolvedIcon {
    if (!showIcon) return null;
    if (icon != null) return icon;
    return switch (tone) {
      StatusBadgeTone.success => Icons.check_circle_outline,
      StatusBadgeTone.warning => Icons.warning_amber_outlined,
      StatusBadgeTone.error => Icons.error_outline,
      StatusBadgeTone.info => Icons.info_outline,
      StatusBadgeTone.neutral => Icons.label_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      StatusBadgeTone.success => (
        AppColors.success.withValues(alpha: 0.12),
        AppColors.success,
      ),
      StatusBadgeTone.warning => (
        AppColors.warning.withValues(alpha: 0.14),
        AppColors.warning,
      ),
      StatusBadgeTone.error => (
        AppColors.error.withValues(alpha: 0.12),
        AppColors.error,
      ),
      StatusBadgeTone.info => (
        AppColors.info.withValues(alpha: 0.12),
        AppColors.info,
      ),
      StatusBadgeTone.neutral => (
        AppColors.surfaceMuted,
        AppColors.textSecondary,
      ),
    };

    final resolvedIcon = _resolvedIcon;

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs + 2,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(color: fg.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (resolvedIcon != null) ...[
              Icon(resolvedIcon, size: 14, color: fg),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: fg,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
