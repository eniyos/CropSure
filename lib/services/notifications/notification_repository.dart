import '../../core/utils/result.dart';
import '../../models/app_notification.dart';

abstract class NotificationRepository {
  Future<Result<List<AppNotification>>> getNotifications();

  Future<Result<AppNotification>> getNotificationById(String id);

  Future<Result<AppNotification>> markAsRead(String id);

  Future<Result<void>> markAllAsRead();
}
