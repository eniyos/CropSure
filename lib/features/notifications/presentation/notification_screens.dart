import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/load_state.dart';
import '../../../models/app_notification.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_error_view.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/status_badge.dart';
import '../controllers/notification_controller.dart';

IconData _iconFor(NotificationType type) => switch (type) {
  NotificationType.diseaseAlert => Icons.biotech_outlined,
  NotificationType.treatmentReminder => Icons.medical_services_outlined,
  NotificationType.trustUpdate => Icons.verified_outlined,
  NotificationType.weatherAlert => Icons.cloud_outlined,
  NotificationType.marketInfo => Icons.storefront_outlined,
  NotificationType.passportEvent => Icons.badge_outlined,
  NotificationType.general => Icons.notifications_outlined,
};

StatusBadgeTone _toneFor(NotificationType type) => switch (type) {
  NotificationType.diseaseAlert => StatusBadgeTone.error,
  NotificationType.treatmentReminder => StatusBadgeTone.warning,
  NotificationType.trustUpdate => StatusBadgeTone.success,
  NotificationType.weatherAlert => StatusBadgeTone.info,
  NotificationType.marketInfo => StatusBadgeTone.info,
  NotificationType.passportEvent => StatusBadgeTone.neutral,
  NotificationType.general => StatusBadgeTone.neutral,
};

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  late final NotificationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppScope.read(context).notificationController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Notifications',
      actions: [
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            if (_controller.unreadCount == 0) return const SizedBox.shrink();
            return TextButton(
              onPressed: _controller.markAllAsRead,
              child: const Text('Mark all read'),
            );
          },
        ),
      ],
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          switch (_controller.listState) {
            case LoadState.loading:
            case LoadState.idle:
              return const LoadingWidget(message: 'Loading notifications…');
            case LoadState.error:
              return AppErrorView(
                message: _controller.errorMessage ??
                    'Could not load notifications.',
                onRetry: _controller.loadNotifications,
              );
            case LoadState.empty:
              return EmptyState(
                title: 'No notifications',
                message: 'Alerts and updates will appear here.',
                icon: Icons.notifications_none_rounded,
                actionLabel: 'Refresh',
                onAction: _controller.loadNotifications,
              );
            case LoadState.success:
              return RefreshIndicator(
                onRefresh: _controller.loadNotifications,
                child: ResponsiveContent(
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _controller.notifications.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = _controller.notifications[index];
                      return _NotificationTile(notification: item);
                    },
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: () => context.push(
        AppRoutes.notificationDetailsPath(notification.id),
      ),
      semanticLabel: notification.title,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _iconFor(notification.type),
            color: notification.isRead
                ? AppColors.textSecondary
                : AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: notification.isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(notification.body, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    StatusBadge(
                      label: notification.type.displayName,
                      tone: _toneFor(notification.type),
                    ),
                    const Spacer(),
                    Text(
                      DateFormatters.formatWithTime(notification.createdAt),
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationDetailsScreen extends StatefulWidget {
  const NotificationDetailsScreen({super.key, required this.notificationId});

  final String notificationId;

  @override
  State<NotificationDetailsScreen> createState() =>
      _NotificationDetailsScreenState();
}

class _NotificationDetailsScreenState extends State<NotificationDetailsScreen> {
  late final NotificationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppScope.read(context).notificationController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadNotification(widget.notificationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Notification',
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          switch (_controller.detailState) {
            case LoadState.loading:
            case LoadState.idle:
              return const LoadingWidget(message: 'Loading notification…');
            case LoadState.error:
            case LoadState.empty:
              return AppErrorView(
                message:
                    _controller.errorMessage ?? 'Notification not found.',
                onRetry: () =>
                    _controller.loadNotification(widget.notificationId),
              );
            case LoadState.success:
              final item = _controller.selected!;
              return ResponsiveContent(
                child: ListView(
                  children: [
                    Row(
                      children: [
                        Icon(_iconFor(item.type), color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            item.title,
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    StatusBadge(
                      label: item.type.displayName,
                      tone: _toneFor(item.type),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      DateFormatters.formatWithTime(item.createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      child: Text(item.body, style: theme.textTheme.bodyLarge),
                    ),
                    if (item.details != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      AppCard(
                        child: Text(
                          item.details!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      item.isRead ? 'Status: Read' : 'Status: Unread',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}
