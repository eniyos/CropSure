import '../../core/utils/result.dart';
import '../../models/crop_passport.dart';

abstract class PassportRepository {
  Future<Result<List<CropPassport>>> listPassports({String? cropBatchId});

  Future<Result<PassportDetail>> getPassport(String passportId);

  Future<Result<PassportDetail>> getPassportForCrop(String cropBatchId);

  Future<Result<PassportVerificationResult>> verifyCode(String code);
}
