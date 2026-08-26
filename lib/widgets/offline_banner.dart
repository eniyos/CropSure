import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/di/app_scope.dart';
import '../core/routing/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Thin strip shown when the app is offline (or demo force-offline).
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = AppScope.read(context).syncController;
    return ListenableBuilder(
      listenable: sync,
      builder: (context, _) {
        if (!sync.connectivity.isOffline) {
          return const SizedBox.shrink();
        }

        final pending = sync.pendingCount;
        return Material(
          color: AppColors.warning.withValues(alpha: 0.18),
          child: InkWell(
            onTap: () => context.push(AppRoutes.syncOffline),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 18,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      pending > 0
                          ? 'Offline · $pending change${pending == 1 ? '' : 's'} pending sync'
                          : 'You are offline · showing last available data',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                  Text(
                    'Details',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.green700,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Inline note when a list/detail is served from cache.
class CacheFreshnessBanner extends StatelessWidget {
  const CacheFreshnessBanner({
    super.key,
    required this.visible,
    this.cachedAt,
    this.label = 'Showing cached data',
  });

  final bool visible;
  final DateTime? cachedAt;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final time = cachedAt == null
        ? null
        : TimeOfDay.fromDateTime(cachedAt!).format(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.skyMist.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.green600.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.history_rounded,
            size: 18,
            color: AppColors.green700.withValues(alpha: 0.9),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              time == null ? label : '$label · last updated $time',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
