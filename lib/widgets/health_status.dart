import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/crop_batch.dart';
import 'status_badge.dart';

abstract final class HealthStatusPresentation {
  static StatusBadgeTone tone(CropHealthStatus status) => switch (status) {
    CropHealthStatus.healthy => StatusBadgeTone.success,
    CropHealthStatus.watch => StatusBadgeTone.warning,
    CropHealthStatus.atRisk => StatusBadgeTone.warning,
    CropHealthStatus.critical => StatusBadgeTone.error,
    CropHealthStatus.unknown => StatusBadgeTone.neutral,
  };

  static IconData icon(CropHealthStatus status) => switch (status) {
    CropHealthStatus.healthy => Icons.check_circle_outline,
    CropHealthStatus.watch => Icons.visibility_outlined,
    CropHealthStatus.atRisk => Icons.warning_amber_outlined,
    CropHealthStatus.critical => Icons.error_outline,
    CropHealthStatus.unknown => Icons.help_outline,
  };

  static Color color(CropHealthStatus status) => switch (status) {
    CropHealthStatus.healthy => AppColors.severityHealthy,
    CropHealthStatus.watch => AppColors.severityMild,
    CropHealthStatus.atRisk => AppColors.severityModerate,
    CropHealthStatus.critical => AppColors.severityCritical,
    CropHealthStatus.unknown => AppColors.textSecondary,
  };
}
