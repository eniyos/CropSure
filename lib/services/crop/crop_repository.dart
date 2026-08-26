import '../../core/utils/result.dart';
import '../../models/crop_batch.dart';

abstract class CropRepository {
  Future<Result<List<CropBatch>>> getCrops({String? farmId});

  Future<Result<CropBatch>> getCropById(String id);

  Future<Result<CropBatch>> createCrop(CropBatchInput input);

  Future<Result<CropBatch>> updateCrop(String id, CropBatchInput input);

  Future<Result<void>> deleteCrop(String id);
}
