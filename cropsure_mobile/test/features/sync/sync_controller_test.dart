import 'package:cropsure/core/offline/cache_store.dart';
import 'package:cropsure/core/offline/connectivity_controller.dart';
import 'package:cropsure/core/offline/sync_queue_store.dart';
import 'package:cropsure/core/storage/preferences_service.dart';
import 'package:cropsure/features/sync/controllers/sync_controller.dart';
import 'package:cropsure/models/sync_operation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SyncController> _buildSync({bool forceOffline = false}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await PreferencesService.create();
  final connectivity = ConnectivityController(skipPlatform: true);
  await connectivity.start();
  if (forceOffline) connectivity.setForceOffline(true);
  return SyncController(
    connectivity: connectivity,
    cacheStore: CacheStore(prefs),
    queueStore: SyncQueueStore(prefs),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SyncController enqueues pending ops while offline', () async {
    final sync = await _buildSync(forceOffline: true);
    await sync.enqueue(
      SyncOperation(
        id: 'op-1',
        type: SyncOperationType.createFarm,
        status: SyncOperationStatus.pending,
        createdAt: DateTime(2026, 8, 26),
        label: 'Demo farm',
      ),
    );
    expect(sync.pendingCount, 1);
    expect(sync.connectivity.isOffline, isTrue);
  });

  test('SyncController processes queue when online', () async {
    final sync = await _buildSync();
    await sync.enqueue(
      SyncOperation(
        id: 'op-2',
        type: SyncOperationType.updateCrop,
        status: SyncOperationStatus.pending,
        createdAt: DateTime(2026, 8, 26),
        label: 'Tomato',
      ),
    );
    await sync.processQueue();
    expect(sync.pendingCount, 0);
    expect(
      sync.operations.any((o) => o.status == SyncOperationStatus.synced),
      isTrue,
    );
  });
}
