import 'package:cropsure/core/offline/cache_store.dart';
import 'package:cropsure/core/offline/connectivity_controller.dart';
import 'package:cropsure/core/offline/sync_queue_store.dart';
import 'package:cropsure/core/storage/preferences_service.dart';
import 'package:cropsure/core/utils/result.dart';
import 'package:cropsure/features/sync/controllers/sync_controller.dart';
import 'package:cropsure/models/farm.dart';
import 'package:cropsure/models/sync_operation.dart';
import 'package:cropsure/services/farm/farm_repository.dart';
import 'package:cropsure/services/farm/offline_farm_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryFarmRepository implements FarmRepository {
  final farms = <Farm>[
    const Farm(
      id: 'f1',
      name: 'Cached Farm',
      location: 'Nashik',
      areaHectares: 2,
    ),
  ];

  @override
  Future<Result<Farm>> createFarm(FarmInput input) async {
    final farm = Farm(
      id: 'f-new',
      name: input.name,
      location: input.location,
      areaHectares: input.areaHectares,
    );
    farms.add(farm);
    return Success(farm);
  }

  @override
  Future<Result<void>> deleteFarm(String id) async {
    farms.removeWhere((f) => f.id == id);
    return const Success(null);
  }

  @override
  Future<Result<Farm>> getFarmById(String id) async =>
      Success(farms.firstWhere((f) => f.id == id));

  @override
  Future<Result<List<Farm>>> getFarms() async => Success(List.of(farms));

  @override
  Future<Result<Farm>> updateFarm(String id, FarmInput input) async {
    final i = farms.indexWhere((f) => f.id == id);
    farms[i] = farms[i].copyWith(
      name: input.name,
      location: input.location,
      areaHectares: input.areaHectares,
    );
    return Success(farms[i]);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('OfflineFarmRepository serves cache and queues writes offline', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PreferencesService.create();
    final connectivity = ConnectivityController(skipPlatform: true);
    await connectivity.start();
    final sync = SyncController(
      connectivity: connectivity,
      cacheStore: CacheStore(prefs),
      queueStore: SyncQueueStore(prefs),
    );
    final offline = OfflineFarmRepository(
      inner: _MemoryFarmRepository(),
      cacheStore: CacheStore(prefs),
      connectivity: connectivity,
      syncController: sync,
    );

    // Warm cache while online.
    final online = await offline.getFarms();
    expect(online.isSuccess, isTrue);

    connectivity.setForceOffline(true);
    final cached = await offline.getFarms();
    expect(cached.isSuccess, isTrue);
    expect(cached.valueOrNull, hasLength(1));
    expect(sync.lastFarmReadFromCache, isTrue);

    final created = await offline.createFarm(
      const FarmInput(name: 'Offline Farm', location: 'Pune', areaHectares: 1),
    );
    expect(created.isSuccess, isTrue);
    expect(sync.pendingCount, 1);
    expect(sync.pendingOperations.first.type, SyncOperationType.createFarm);
  });
}
