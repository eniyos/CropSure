import '../../core/utils/result.dart';
import '../../models/trust_score.dart';

abstract class TrustRepository {
  /// When [cropBatchId] is null, returns the farmer's overall trust snapshot.
  Future<Result<TrustScoreDetail>> getTrustScore({String? cropBatchId});
}
