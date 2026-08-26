import '../../core/utils/result.dart';
import '../../models/treatment.dart';

abstract class TreatmentRepository {
  Future<Result<List<Treatment>>> getTreatments({String? cropBatchId});

  Future<Result<Treatment>> getTreatmentById(String id);

  Future<Result<Treatment>> createTreatment(TreatmentInput input);

  Future<Result<Treatment>> updateTreatment(String id, TreatmentInput input);

  Future<Result<void>> deleteTreatment(String id);
}
