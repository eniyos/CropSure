import '../../core/constants/api_config.dart';
import '../../core/network/api_client.dart';
import '../../core/offline/cache_store.dart';
import '../../core/offline/connectivity_controller.dart';
import '../../features/sync/controllers/sync_controller.dart';
import '../crop/crop_repository.dart';
import '../crop/mock_crop_repository.dart';
import '../crop/offline_crop_repository.dart';
import '../crop/remote_crop_repository.dart';
import '../farm/farm_repository.dart';
import '../farm/mock_farm_repository.dart';
import '../farm/offline_farm_repository.dart';
import '../farm/remote_farm_repository.dart';

/// Builds mock-or-remote repositories and wraps them for offline cache/sync.
class RepositoryFactory {
  RepositoryFactory({
    required ApiClient apiClient,
    required CacheStore cacheStore,
    required ConnectivityController connectivity,
    required SyncController syncController,
  }) {
    final mockFarm = MockFarmRepository();
    final FarmRepository farmInner = ApiConfig.useMockApis
        ? mockFarm
        : RemoteFarmRepository(apiClient);
    farmRepository = OfflineFarmRepository(
      inner: farmInner,
      cacheStore: cacheStore,
      connectivity: connectivity,
      syncController: syncController,
    );

    final CropRepository cropInner = ApiConfig.useMockApis
        ? MockCropRepository(mockFarm)
        : RemoteCropRepository(apiClient);
    cropRepository = OfflineCropRepository(
      inner: cropInner,
      cacheStore: cacheStore,
      connectivity: connectivity,
      syncController: syncController,
    );
  }

  late final FarmRepository farmRepository;
  late final CropRepository cropRepository;
}
