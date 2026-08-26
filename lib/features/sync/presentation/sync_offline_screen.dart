import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/api_config.dart';
import '../../../core/di/app_scope.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/sync_operation.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/status_badge.dart';

class SyncOfflineScreen extends StatelessWidget {
  const SyncOfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = AppScope.read(context).syncController;
    final theme = Theme.of(context);
    final dateFmt = DateFormat('d MMM, HH:mm');

    return AppScaffold(
      title: 'Sync & offline',
      body: ListenableBuilder(
        listenable: Listenable.merge([sync, sync.connectivity]),
        builder: (context, _) {
          final online = sync.connectivity.isOnline;
          final pending = sync.pendingOperations;

          return ResponsiveContent(
            child: ListView(
              children: [
                Text(
                  'Demonstrate offline cache, pending sync, and API mode.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  glass: true,
                  emphasized: online,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            online
                                ? Icons.cloud_done_outlined
                                : Icons.cloud_off_rounded,
                            color: online ? AppColors.white : AppColors.warning,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              online ? 'Online' : 'Offline',
                              style: AppTypography.display(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: online
                                    ? AppColors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          StatusBadge(
                            label: online ? 'Connected' : 'Disconnected',
                            tone: online
                                ? StatusBadgeTone.success
                                : StatusBadgeTone.warning,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        online
                            ? 'Live reads refresh cache. Writes sync immediately.'
                            : 'Showing last available cached farms and crops. '
                                'New edits stay on device until sync.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: online
                              ? AppColors.white.withValues(alpha: 0.9)
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Simulate offline',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: online ? AppColors.white : null,
                          ),
                        ),
                        subtitle: Text(
                          'Force offline for demo (Chrome stays “connected”).',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: online
                                ? AppColors.white.withValues(alpha: 0.75)
                                : AppColors.textSecondary,
                          ),
                        ),
                        value: sync.connectivity.forceOffline,
                        onChanged: sync.connectivity.setForceOffline,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(
                  title: 'Data source',
                  subtitle: 'Mock vs live API wiring',
                ),
                AppCard(
                  glass: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MetaRow(
                        label: 'Mode',
                        value: ApiConfig.dataSourceLabel,
                      ),
                      _MetaRow(label: 'API base', value: ApiConfig.baseUrl),
                      _MetaRow(
                        label: 'Farms cache',
                        value: sync.farmsCachedAt == null
                            ? 'Empty'
                            : dateFmt.format(sync.farmsCachedAt!),
                      ),
                      _MetaRow(
                        label: 'Crops cache',
                        value: sync.cropsCachedAt == null
                            ? 'Empty'
                            : dateFmt.format(sync.cropsCachedAt!),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: 'Clear local cache',
                        variant: AppButtonVariant.outlined,
                        icon: Icons.delete_outline,
                        onPressed: () async {
                          await sync.clearCache();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Local farm/crop cache cleared.'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: 'Pending sync',
                  subtitle: pending.isEmpty
                      ? 'No queued changes'
                      : '${pending.length} waiting to sync',
                  actionLabel: sync.isSyncing ? 'Syncing…' : 'Retry now',
                  onAction: sync.isSyncing || !online
                      ? null
                      : () => sync.processQueue(),
                ),
                if (sync.lastSyncError != null) ...[
                  Text(
                    sync.lastSyncError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (pending.isEmpty)
                  AppCard(
                    glass: true,
                    child: Text(
                      online
                          ? 'All caught up. Edits made while online sync immediately.'
                          : 'Make a farm or crop edit while offline to queue a sync item.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  ...pending.map(
                    (op) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _SyncTile(operation: op),
                    ),
                  ),
                if (sync.operations.any(
                  (o) => o.status == SyncOperationStatus.synced,
                )) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Clear synced history',
                    variant: AppButtonVariant.text,
                    onPressed: sync.clearSyncedHistory,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Open farms (test cache)',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => context.go(AppRoutes.farms),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: sync.pendingCount > 0 && sync.connectivity.isOffline
                      ? 'Retry failed'
                      : 'Process queue',
                  onPressed: sync.isSyncing
                      ? null
                      : () async {
                          if (sync.operations.any(
                            (o) => o.status == SyncOperationStatus.failed,
                          )) {
                            await sync.retryFailed();
                          } else {
                            await sync.processQueue();
                          }
                        },
                  isLoading: sync.isSyncing,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.titleSmall),
          ),
        ],
      ),
    );
  }
}

class _SyncTile extends StatelessWidget {
  const _SyncTile({required this.operation});

  final SyncOperation operation;

  StatusBadgeTone get _tone => switch (operation.status) {
        SyncOperationStatus.pending => StatusBadgeTone.warning,
        SyncOperationStatus.syncing => StatusBadgeTone.neutral,
        SyncOperationStatus.failed => StatusBadgeTone.error,
        SyncOperationStatus.synced => StatusBadgeTone.success,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      glass: true,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(operation.typeLabel, style: theme.textTheme.titleSmall),
                Text(
                  operation.label ?? operation.entityId ?? operation.id,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (operation.errorMessage != null)
                  Text(
                    operation.errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
              ],
            ),
          ),
          StatusBadge(label: operation.statusLabel, tone: _tone),
        ],
      ),
    );
  }
}
