import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/offline/cache_store.dart';
import '../../../core/offline/connectivity_controller.dart';
import '../../../core/offline/sync_queue_store.dart';
import '../../../models/sync_operation.dart';

/// Manages pending offline mutations, retry, and cache metadata for the UI.
class SyncController extends ChangeNotifier {
  SyncController({
    required ConnectivityController connectivity,
    required CacheStore cacheStore,
    required SyncQueueStore queueStore,
  })  : _connectivity = connectivity,
        _cacheStore = cacheStore,
        _queueStore = queueStore {
    _ops = _queueStore.readAll();
    _connectivity.addListener(_onConnectivityChanged);
  }

  final ConnectivityController _connectivity;
  final CacheStore _cacheStore;
  final SyncQueueStore _queueStore;

  List<SyncOperation> _ops = const [];
  bool _isSyncing = false;
  String? _lastSyncError;
  bool _lastFarmReadFromCache = false;
  bool _lastCropReadFromCache = false;

  ConnectivityController get connectivity => _connectivity;
  CacheStore get cacheStore => _cacheStore;

  List<SyncOperation> get operations => List.unmodifiable(_ops);
  List<SyncOperation> get pendingOperations => _ops
      .where(
        (o) =>
            o.status == SyncOperationStatus.pending ||
            o.status == SyncOperationStatus.failed,
      )
      .toList();

  int get pendingCount => pendingOperations.length;
  bool get isSyncing => _isSyncing;
  String? get lastSyncError => _lastSyncError;
  bool get lastFarmReadFromCache => _lastFarmReadFromCache;
  bool get lastCropReadFromCache => _lastCropReadFromCache;
  DateTime? get farmsCachedAt => _cacheStore.farmsCachedAt;
  DateTime? get cropsCachedAt => _cacheStore.cropsCachedAt;

  void markFarmRead({required bool fromCache}) {
    _lastFarmReadFromCache = fromCache;
    notifyListeners();
  }

  void markCropRead({required bool fromCache}) {
    _lastCropReadFromCache = fromCache;
    notifyListeners();
  }

  Future<void> enqueue(SyncOperation operation) async {
    _ops = [..._ops, operation];
    await _persist();
    notifyListeners();
  }

  Future<void> retryFailed() async {
    _ops = _ops
        .map(
          (o) => o.status == SyncOperationStatus.failed
              ? o.copyWith(status: SyncOperationStatus.pending, errorMessage: null)
              : o,
        )
        .toList();
    await _persist();
    notifyListeners();
    await processQueue();
  }

  /// Processes pending items. With mock APIs this marks local writes as synced.
  Future<void> processQueue() async {
    if (!_connectivity.isOnline || _isSyncing) return;

    final pending = pendingOperations;
    if (pending.isEmpty) return;

    _isSyncing = true;
    _lastSyncError = null;
    notifyListeners();

    for (final op in pending) {
      _ops = _ops
          .map(
            (o) => o.id == op.id
                ? o.copyWith(status: SyncOperationStatus.syncing)
                : o,
          )
          .toList();
      notifyListeners();

      try {
        // Real backends would replay payload against Remote* repositories here.
        // Mock mode confirms local state is already applied and closes the item.
        await Future<void>.delayed(const Duration(milliseconds: 350));
        if (!_connectivity.isOnline) {
          throw const NetworkException();
        }
        _ops = _ops
            .map(
              (o) => o.id == op.id
                  ? o.copyWith(
                      status: SyncOperationStatus.synced,
                      completedAt: DateTime.now(),
                      errorMessage: null,
                    )
                  : o,
            )
            .toList();
      } catch (error) {
        _lastSyncError = error is AppException
            ? error.message
            : 'Sync failed. Will retry when online.';
        _ops = _ops
            .map(
              (o) => o.id == op.id
                  ? o.copyWith(
                      status: SyncOperationStatus.failed,
                      errorMessage: _lastSyncError,
                    )
                  : o,
            )
            .toList();
        break;
      }
      await _persist();
      notifyListeners();
    }

    // Drop completed synced items older than keep window (keep last few for UI).
    final synced = _ops
        .where((o) => o.status == SyncOperationStatus.synced)
        .toList();
    if (synced.length > 8) {
      final dropIds = synced
          .take(synced.length - 8)
          .map((o) => o.id)
          .toSet();
      _ops = _ops.where((o) => !dropIds.contains(o.id)).toList();
    }

    _isSyncing = false;
    await _persist();
    notifyListeners();
  }

  Future<void> clearSyncedHistory() async {
    _ops = _ops
        .where((o) => o.status != SyncOperationStatus.synced)
        .toList();
    await _persist();
    notifyListeners();
  }

  Future<void> clearCache() async {
    await _cacheStore.clearAll();
    notifyListeners();
  }

  void _onConnectivityChanged() {
    notifyListeners();
    if (_connectivity.isOnline) {
      processQueue();
    }
  }

  Future<void> _persist() => _queueStore.writeAll(_ops);

  @override
  void dispose() {
    _connectivity.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}
