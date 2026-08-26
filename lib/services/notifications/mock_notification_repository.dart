import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../models/app_notification.dart';
import 'notification_repository.dart';

class MockNotificationRepository implements NotificationRepository {
  MockNotificationRepository() {
    _items = [
      AppNotification(
        id: 'n1',
        title: 'Disease alert',
        body: 'Early blight confidence above 90% on Tomato · Hybrid 61.',
        type: NotificationType.diseaseAlert,
        createdAt: DateTime.now().subtract(const Duration(hours: 14)),
        details:
            'The AI service reported Early Blight with high confidence. '
            'Open disease analysis for Grad-CAM and severity details, then '
            'review treatment options for the affected crop batch.',
      ),
      AppNotification(
        id: 'n2',
        title: 'Trust score update',
        body: 'Overall Dynamic Crop Trust Score refreshed.',
        type: NotificationType.trustUpdate,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: true,
        details:
            'The Trust Engine recalculated your score using recent disease, '
            'treatment, and weather signals.',
      ),
      AppNotification(
        id: 'n3',
        title: 'Weather advisory',
        body: 'Rain chance 35% tonight. Check drainage on Riverbend Fields.',
        type: NotificationType.weatherAlert,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        details:
            'Moderate humidity and light rain chance may increase leaf wetness. '
            'Review the weather module for the full forecast and farm risks.',
      ),
      AppNotification(
        id: 'n4',
        title: 'Treatment reminder',
        body: 'Neem oil follow-up is scheduled in 2 days for Tomato · Hybrid 61.',
        type: NotificationType.treatmentReminder,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        details:
            'Open Treatments to confirm or reschedule this planned application.',
      ),
      AppNotification(
        id: 'n5',
        title: 'Market update',
        body: 'Tomato prices at Nashik APMC rose to ₹28.5/kg.',
        type: NotificationType.marketInfo,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        details:
            'Check the market screen for prices across nearby yards and the '
            'recent tomato price trend.',
      ),
      AppNotification(
        id: 'n6',
        title: 'Passport verification event',
        body: 'A digital crop passport was prepared for Grape · Thompson Seedless.',
        type: NotificationType.passportEvent,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        details:
            'Open Digital crop passport from the dashboard or a crop batch '
            'to view the timeline, QR code, and verify with CS-PASS codes.',
      ),
    ];
  }

  late List<AppNotification> _items;
  static const _delay = Duration(milliseconds: 400);

  @override
  Future<Result<List<AppNotification>>> getNotifications() async {
    await Future<void>.delayed(_delay);
    final sorted = [..._items]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Success(List.unmodifiable(sorted));
  }

  @override
  Future<Result<AppNotification>> getNotificationById(String id) async {
    await Future<void>.delayed(_delay);
    try {
      return Success(_items.firstWhere((n) => n.id == id));
    } on StateError {
      return const Failure(NotFoundException('Notification not found.'));
    }
  }

  @override
  Future<Result<AppNotification>> markAsRead(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _items.indexWhere((n) => n.id == id);
    if (index < 0) {
      return const Failure(NotFoundException('Notification not found.'));
    }
    final updated = _items[index].copyWith(isRead: true);
    _items = [..._items]..[index] = updated;
    return Success(updated);
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _items = _items.map((n) => n.copyWith(isRead: true)).toList();
    return const Success(null);
  }
}
