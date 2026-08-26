import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../../models/farm.dart';
import '../api/api_endpoints.dart';
import 'farm_repository.dart';

/// HTTP farm repository. Paths follow [ApiEndpoints] — align with OpenAPI
/// before setting [ApiConfig.useMockApis] to false.
class RemoteFarmRepository implements FarmRepository {
  RemoteFarmRepository(this._client);

  final ApiClient _client;

  @override
  Future<Result<List<Farm>>> getFarms() async {
    try {
      final response = await _client.get<List<dynamic>>(ApiEndpoints.farms);
      final data = response.data ?? const [];
      return Success(
        data
            .map((e) => Farm.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
    } catch (error) {
      return Failure(error);
    }
  }

  @override
  Future<Result<Farm>> getFarmById(String id) async {
    try {
      final response =
          await _client.get<Map<String, dynamic>>(ApiEndpoints.farmById(id));
      final data = response.data;
      if (data == null) {
        return const Failure(NotFoundException('Farm not found.'));
      }
      return Success(Farm.fromJson(data));
    } catch (error) {
      return Failure(error);
    }
  }

  @override
  Future<Result<Farm>> createFarm(FarmInput input) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        ApiEndpoints.farms,
        data: {
          'name': input.name,
          'location': input.location,
          'area_hectares': input.areaHectares,
          if (input.notes != null) 'notes': input.notes,
        },
      );
      final data = response.data;
      if (data == null) {
        return const Failure(ServerException('Empty farm create response.'));
      }
      return Success(Farm.fromJson(data));
    } catch (error) {
      return Failure(error);
    }
  }

  @override
  Future<Result<Farm>> updateFarm(String id, FarmInput input) async {
    try {
      final response = await _client.put<Map<String, dynamic>>(
        ApiEndpoints.farmById(id),
        data: {
          'name': input.name,
          'location': input.location,
          'area_hectares': input.areaHectares,
          if (input.notes != null) 'notes': input.notes,
        },
      );
      final data = response.data;
      if (data == null) {
        return const Failure(ServerException('Empty farm update response.'));
      }
      return Success(Farm.fromJson(data));
    } catch (error) {
      return Failure(error);
    }
  }

  @override
  Future<Result<void>> deleteFarm(String id) async {
    try {
      await _client.delete(ApiEndpoints.farmById(id));
      return const Success(null);
    } catch (error) {
      return Failure(error);
    }
  }
}
