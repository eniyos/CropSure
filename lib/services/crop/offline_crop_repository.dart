import '../../core/errors/app_exception.dart';
import '../../core/offline/cache_store.dart';
import '../../core/offline/connectivity_controller.dart';
import '../../core/utils/result.dart';
import '../../features/sync/controllers/sync_controller.dart';
import '../../models/crop_batch.dart';
import '../../models/sync_operation.dart';
import 'crop_repository.dart';

/// Caches crop reads and queues writes when offline.
class OfflineCropRepository implements CropRepository {
  OfflineCropRepository({
    required CropRepository inner,
    required CacheStore cacheStore,
    required ConnectivityController connectivity,
    required SyncController syncController,
  })  : _inner = inner,
        _cache = cacheStore,
        _connectivity = connectivity,
        _sync = syncController;

  final CropRepository _inner;
  final CacheStore _cache;
  final ConnectivityController _connectivity;
  final SyncController _sync;

  @override
  Future<Result<List<CropBatch>>> getCrops({String? farmId}) async {
    if (!_connectivity.isOnline) {
      final cached = _filter(_cache.readCrops(), farmId);
      if (cached != null) {
        _sync.markCropRead(fromCache: true);
        return Success(cached);
      }
      return const Failure(
        NetworkException(
          'You are offline and no crop cache is available yet.',
        ),
      );
    }

    final result = await _inner.getCrops(farmId: farmId);
    await result.when(
      success: (crops) async {
        // Cache full list when unfiltered; otherwise merge into existing cache.
        if (farmId == null) {
          await _cache.saveCrops(crops);
        } else {
          final existing = _cache.readCrops() ?? [];
          final merged = [
            ...existing.where((c) => c.farmId != farmId),
            ...crops,
          ];
          await _cache.saveCrops(merged);
        }
        _sync.markCropRead(fromCache: false);
      },
      failure: (_) async {},
    );

    if (result.isFailure) {
      final cached = _filter(_cache.readCrops(), farmId);
      if (cached != null) {
        _sync.markCropRead(fromCache: true);
        return Success(cached);
      }
    }
    return result;
  }

  @override
  Future<Result<CropBatch>> getCropById(String id) async {
    if (!_connectivity.isOnline) {
      final match = _cache.readCrops()?.where((c) => c.id == id).toList();
      if (match != null && match.isNotEmpty) {
        _sync.markCropRead(fromCache: true);
        return Success(match.first);
      }
      return const Failure(
        NetworkException('Crop detail is unavailable offline.'),
      );
    }

    final result = await _inner.getCropById(id);
    if (result.isSuccess) {
      _sync.markCropRead(fromCache: false);
      final crop = result.valueOrNull!;
      final existing = _cache.readCrops() ?? [];
      await _cache.saveCrops([
        ...existing.where((c) => c.id != crop.id),
        crop,
      ]);
    }
    return result;
  }

  @override
  Future<Result<CropBatch>> createCrop(CropBatchInput input) async {
    final result = await _inner.createCrop(input);
    return _afterWrite(
      result,
      type: SyncOperationType.createCrop,
      label: '${input.cropType} · ${input.variety}',
      payload: {
        'farm_id': input.farmId,
        'crop_type': input.cropType,
        'variety': input.variety,
        'planting_date': input.plantingDate.toIso8601String(),
        'growth_stage': input.growthStage.name,
        if (input.areaHectares != null) 'area_hectares': input.areaHectares,
        if (input.notes != null) 'notes': input.notes,
      },
    );
  }

  @override
  Future<Result<CropBatch>> updateCrop(String id, CropBatchInput input) async {
    final result = await _inner.updateCrop(id, input);
    return _afterWrite(
      result,
      type: SyncOperationType.updateCrop,
      entityId: id,
      label: '${input.cropType} · ${input.variety}',
      payload: {
        'id': id,
        'farm_id': input.farmId,
        'crop_type': input.cropType,
        'variety': input.variety,
        'planting_date': input.plantingDate.toIso8601String(),
        'growth_stage': input.growthStage.name,
        if (input.areaHectares != null) 'area_hectares': input.areaHectares,
        if (input.notes != null) 'notes': input.notes,
      },
    );
  }

  @override
  Future<Result<void>> deleteCrop(String id) async {
    final result = await _inner.deleteCrop(id);
    if (result.isSuccess) {
      final crops = _cache.readCrops();
      if (crops != null) {
        await _cache.saveCrops(crops.where((c) => c.id != id).toList());
      }
      if (!_connectivity.isOnline) {
        await _sync.enqueue(
          SyncOperation(
            id: 'sync-${DateTime.now().microsecondsSinceEpoch}',
            type: SyncOperationType.deleteCrop,
            status: SyncOperationStatus.pending,
            createdAt: DateTime.now(),
            entityId: id,
            label: 'Delete crop',
            payload: {'id': id},
          ),
        );
      }
    }
    return result;
  }

  List<CropBatch>? _filter(List<CropBatch>? all, String? farmId) {
    if (all == null) return null;
    if (farmId == null) return all;
    return all.where((c) => c.farmId == farmId).toList();
  }

  Future<Result<CropBatch>> _afterWrite(
    Result<CropBatch> result, {
    required SyncOperationType type,
    required String label,
    String? entityId,
    Map<String, dynamic>? payload,
  }) async {
    if (result.isFailure) return result;
    final crop = result.valueOrNull!;
    final crops = _cache.readCrops() ?? [];
    await _cache.saveCrops([
      ...crops.where((c) => c.id != crop.id),
      crop,
    ]);

    if (!_connectivity.isOnline) {
      await _sync.enqueue(
        SyncOperation(
          id: 'sync-${DateTime.now().microsecondsSinceEpoch}',
          type: type,
          status: SyncOperationStatus.pending,
          createdAt: DateTime.now(),
          entityId: entityId ?? crop.id,
          label: label,
          payload: payload,
        ),
      );
    }
    return result;
  }
}
