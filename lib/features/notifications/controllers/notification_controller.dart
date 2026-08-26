import 'package:flutter/foundation.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/utils/load_state.dart';
import '../../../models/app_notification.dart';
import '../../../services/notifications/notification_repository.dart';

class NotificationController extends ChangeNotifier {
  NotificationController(this._repository);

  final NotificationRepository _repository;

  LoadState _listState = LoadState.idle;
  LoadState _detailState = LoadState.idle;
  List<AppNotification> _notifications = const [];
  AppNotification? _selected;
  String? _errorMessage;

  LoadState get listState => _listState;
  LoadState get detailState => _detailState;
  List<AppNotification> get notifications => _notifications;
  AppNotification? get selected => _selected;
  String? get errorMessage => _errorMessage;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    _listState = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getNotifications();
    result.when(
      success: (items) {
        _notifications = items;
        _listState = items.isEmpty ? LoadState.empty : LoadState.success;
      },
      failure: (error) {
        _errorMessage = ErrorMapper.fromObject(error).message;
        _listState = LoadState.error;
      },
    );
    notifyListeners();
  }

  Future<void> loadNotification(String id) async {
    _detailState = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getNotificationById(id);
    await result.when(
      success: (item) async {
        _selected = item;
        _detailState = LoadState.success;
        if (!item.isRead) {
          await markAsRead(id);
        }
      },
      failure: (error) async {
        _selected = null;
        _errorMessage = ErrorMapper.fromObject(error).message;
        _detailState = LoadState.error;
      },
    );
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final result = await _repository.markAsRead(id);
    result.when(
      success: (updated) {
        _selected = updated;
        _notifications = _notifications
            .map((n) => n.id == id ? updated : n)
            .toList();
      },
      failure: (_) {},
    );
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    final result = await _repository.markAllAsRead();
    result.when(
      success: (_) {
        _notifications =
            _notifications.map((n) => n.copyWith(isRead: true)).toList();
        if (_selected != null) {
          _selected = _selected!.copyWith(isRead: true);
        }
      },
      failure: (error) {
        _errorMessage = ErrorMapper.fromObject(error).message;
      },
    );
    notifyListeners();
  }
}
