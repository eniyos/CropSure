import '../../core/utils/result.dart';
import '../../models/farm.dart';

abstract class FarmRepository {
  Future<Result<List<Farm>>> getFarms();

  Future<Result<Farm>> getFarmById(String id);

  Future<Result<Farm>> createFarm(FarmInput input);

  Future<Result<Farm>> updateFarm(String id, FarmInput input);

  Future<Result<void>> deleteFarm(String id);
}
