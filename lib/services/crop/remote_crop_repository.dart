import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../../models/crop_batch.dart';
import '../api/api_endpoints.dart';
import 'crop_repository.dart';

/// HTTP crop repository. Align path contracts with OpenAPI before enabling.
class RemoteCropRepository implements CropRepository {
  RemoteCropRepository(this._client);

  final ApiClient _client;

  @override
  Future<Result<List<CropBatch>>> getCrops({String? farmId}) async {
    try {
      final response = await _client.get<List<dynamic>>(
        ApiEndpoints.crops,
        queryParameters: farmId == null ? null : {'farm_id': farmId},
      );
      final data = response.data ?? const [];
      return Success(
        data
            .map((e) => CropBatch.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
    } catch (error) {
      return Failure(error);
    }
  }

  @override
  Future<Result<CropBatch>> getCropById(String id) async {
    try {
      final response =
          await _client.get<Map<String, dynamic>>(ApiEndpoints.cropById(id));
      final data = response.data;
      if (data == null) {
        return const Failure(NotFoundException('Crop batch not found.'));
      }
      return Success(CropBatch.fromJson(data));
    } catch (error) {
      return Failure(error);
    }
  }

  @override
  Future<Result<CropBatch>> createCrop(CropBatchInput input) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        ApiEndpoints.crops,
        data: _body(input),
      );
      final data = response.data;
      if (data == null) {
        return const Failure(ServerException('Empty crop create response.'));
      }
      return Success(CropBatch.fromJson(data));
    } catch (error) {
      return Failure(error);
    }
  }

  @override
  Future<Result<CropBatch>> updateCrop(String id, CropBatchInput input) async {
    try {
      final response = await _client.put<Map<String, dynamic>>(
        ApiEndpoints.cropById(id),
        data: _body(input),
      );
      final data = response.data;
      if (data == null) {
        return const Failure(ServerException('Empty crop update response.'));
      }
      return Success(CropBatch.fromJson(data));
    } catch (error) {
      return Failure(error);
    }
  }

  @override
  Future<Result<void>> deleteCrop(String id) async {
    try {
      await _client.delete(ApiEndpoints.cropById(id));
      return const Success(null);
    } catch (error) {
      return Failure(error);
    }
  }

  Map<String, dynamic> _body(CropBatchInput input) => {
        'farm_id': input.farmId,
        'crop_type': input.cropType,
        'variety': input.variety,
        'planting_date': input.plantingDate.toIso8601String(),
        'growth_stage': input.growthStage.name,
        if (input.areaHectares != null) 'area_hectares': input.areaHectares,
        if (input.notes != null) 'notes': input.notes,
      };
}
