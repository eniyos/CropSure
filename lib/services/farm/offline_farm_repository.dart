import '../../core/errors/app_exception.dart';
import '../../core/offline/cache_store.dart';
import '../../core/offline/connectivity_controller.dart';
import '../../core/utils/result.dart';
import '../../features/sync/controllers/sync_controller.dart';
import '../../models/farm.dart';
import '../../models/sync_operation.dart';
import 'farm_repository.dart';

/// Caches reads and queues writes when offline. Delegates to mock or remote.
class OfflineFarmRepository implements FarmRepository {
  OfflineFarmRepository({
    required FarmRepository inner,
    required CacheStore cacheStore,
    required ConnectivityController connectivity,
    required SyncController syncController,
  })  : _inner = inner,
        _cache = cacheStore,
        _connectivity = connectivity,
        _sync = syncController;

  final FarmRepository _inner;
  final CacheStore _cache;
  final ConnectivityController _connectivity;
  final SyncController _sync;

  @override
  Future<Result<List<Farm>>> getFarms() async {
    if (!_connectivity.isOnline) {
      final cached = _cache.readFarms();
      if (cached != null) {
        _sync.markFarmRead(fromCache: true);
        return Success(cached);
      }
      return const Failure(
        NetworkException(
          'You are offline and no farm cache is available yet.',
        ),
      );
    }

    final result = await _inner.getFarms();
    await result.when(
      success: (farms) async {
        await _cache.saveFarms(farms);
        _sync.markFarmRead(fromCache: false);
      },
      failure: (_) async {
        final cached = _cache.readFarms();
        if (cached != null) {
          _sync.markFarmRead(fromCache: true);
        }
      },
    );

    if (result.isFailure) {
      final cached = _cache.readFarms();
      if (cached != null) return Success(cached);
    }
    return result;
  }

  @override
  Future<Result<Farm>> getFarmById(String id) async {
    if (!_connectivity.isOnline) {
      final cached = _cache.readFarms();
      final match = cached?.where((f) => f.id == id).toList();
      if (match != null && match.isNotEmpty) {
        _sync.markFarmRead(fromCache: true);
        return Success(match.first);
      }
      return const Failure(
        NetworkException('Farm detail is unavailable offline.'),
      );
    }

    final result = await _inner.getFarmById(id);
    if (result.isSuccess) {
      _sync.markFarmRead(fromCache: false);
      final farms = _cache.readFarms() ?? [];
      final farm = result.valueOrNull!;
      final next = [
        ...farms.where((f) => f.id != farm.id),
        farm,
      ];
      await _cache.saveFarms(next);
    }
    return result;
  }

  @override
  Future<Result<Farm>> createFarm(FarmInput input) async {
    final result = await _inner.createFarm(input);
    return _afterWrite(
      result,
      type: SyncOperationType.createFarm,
      label: input.name.trim(),
      payload: {
        'name': input.name,
        'location': input.location,
        'area_hectares': input.areaHectares,
        if (input.notes != null) 'notes': input.notes,
      },
    );
  }

  @override
  Future<Result<Farm>> updateFarm(String id, FarmInput input) async {
    final result = await _inner.updateFarm(id, input);
    return _afterWrite(
      result,
      type: SyncOperationType.updateFarm,
      entityId: id,
      label: input.name.trim(),
      payload: {
        'id': id,
        'name': input.name,
        'location': input.location,
        'area_hectares': input.areaHectares,
        if (input.notes != null) 'notes': input.notes,
      },
    );
  }

  @override
  Future<Result<void>> deleteFarm(String id) async {
    final result = await _inner.deleteFarm(id);
    if (result.isSuccess) {
      final farms = _cache.readFarms();
      if (farms != null) {
        await _cache.saveFarms(farms.where((f) => f.id != id).toList());
      }
      if (!_connectivity.isOnline) {
        await _sync.enqueue(
          SyncOperation(
            id: 'sync-${DateTime.now().microsecondsSinceEpoch}',
            type: SyncOperationType.deleteFarm,
            status: SyncOperationStatus.pending,
            createdAt: DateTime.now(),
            entityId: id,
            label: 'Delete farm',
            payload: {'id': id},
          ),
        );
      }
    }
    return result;
  }

  Future<Result<Farm>> _afterWrite(
    Result<Farm> result, {
    required SyncOperationType type,
    required String label,
    String? entityId,
    Map<String, dynamic>? payload,
  }) async {
    if (result.isFailure) return result;
    final farm = result.valueOrNull!;
    final farms = _cache.readFarms() ?? [];
    await _cache.saveFarms([
      ...farms.where((f) => f.id != farm.id),
      farm,
    ]);

    if (!_connectivity.isOnline) {
      await _sync.enqueue(
        SyncOperation(
          id: 'sync-${DateTime.now().microsecondsSinceEpoch}',
          type: type,
          status: SyncOperationStatus.pending,
          createdAt: DateTime.now(),
          entityId: entityId ?? farm.id,
          label: label,
          payload: payload,
        ),
      );
    }
    return result;
  }
}
