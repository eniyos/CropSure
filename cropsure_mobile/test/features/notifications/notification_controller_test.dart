import 'package:cropsure/core/utils/load_state.dart';
import 'package:cropsure/features/notifications/controllers/notification_controller.dart';
import 'package:cropsure/services/notifications/mock_notification_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('NotificationController loads and marks read', () async {
    final controller = NotificationController(MockNotificationRepository());
    await controller.loadNotifications();
    expect(controller.listState, LoadState.success);
    expect(controller.unreadCount, greaterThan(0));

    final firstUnread =
        controller.notifications.firstWhere((n) => !n.isRead);
    await controller.markAsRead(firstUnread.id);
    expect(
      controller.notifications.firstWhere((n) => n.id == firstUnread.id).isRead,
      isTrue,
    );
  });
}
