import 'package:cropsure/core/utils/load_state.dart';
import 'package:cropsure/core/utils/result.dart';
import 'package:cropsure/features/passport/controllers/passport_controller.dart';
import 'package:cropsure/models/crop_passport.dart';
import 'package:cropsure/services/passport/passport_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePassportRepository implements PassportRepository {
  @override
  Future<Result<List<CropPassport>>> listPassports({String? cropBatchId}) async {
    final items = [
      CropPassport(
        id: 'passport-1',
        cropBatchId: 'crop-001',
        cropLabel: 'Tomato · Hybrid 61',
        farmName: 'Green Valley',
        status: PassportVerificationStatus.verified,
        issuedAt: DateTime(2026, 8, 1),
        updatedAt: DateTime(2026, 8, 20),
        qrPayload: 'cropsure://passport/verify?code=CS-PASS-01',
        verificationCode: 'CS-PASS-01',
        trustScore: 88,
      ),
    ];
    if (cropBatchId == null) return Success(items);
    return Success(items.where((p) => p.cropBatchId == cropBatchId).toList());
  }

  @override
  Future<Result<PassportDetail>> getPassport(String passportId) async {
    final list = (await listPassports()).valueOrNull ?? const [];
    final match = list.where((p) => p.id == passportId);
    if (match.isEmpty) return const Failure('not found');
    return Success(PassportDetail(passport: match.first, timeline: const []));
  }

  @override
  Future<Result<PassportDetail>> getPassportForCrop(String cropBatchId) async {
    final list = (await listPassports(cropBatchId: cropBatchId)).valueOrNull ??
        const [];
    if (list.isEmpty) return const Failure('not found');
    return Success(PassportDetail(passport: list.first, timeline: const []));
  }

  @override
  Future<Result<PassportVerificationResult>> verifyCode(String code) async {
    if (code.trim().toUpperCase() == 'CS-PASS-01') {
      final passport = (await listPassports()).valueOrNull!.first;
      return Success(
        PassportVerificationResult(
          isValid: true,
          message: 'Verified',
          passport: passport,
        ),
      );
    }
    return const Success(
      PassportVerificationResult(
        isValid: false,
        message: 'No match',
      ),
    );
  }
}

void main() {
  test('PassportController loads list', () async {
    final controller = PassportController(_FakePassportRepository());
    await controller.loadList();
    expect(controller.listState, LoadState.success);
    expect(controller.passports, hasLength(1));
  });

  test('PassportController loads detail by id', () async {
    final controller = PassportController(_FakePassportRepository());
    await controller.loadDetail('passport-1');
    expect(controller.detailState, LoadState.success);
    expect(controller.detail?.passport.verificationCode, 'CS-PASS-01');
  });

  test('PassportController verifies demo code', () async {
    final controller = PassportController(_FakePassportRepository());
    await controller.verify('CS-PASS-01');
    expect(controller.verifyState, LoadState.success);
    expect(controller.verification?.isValid, isTrue);
    expect(controller.verification?.passport?.id, 'passport-1');
  });

  test('PassportController rejects unknown code', () async {
    final controller = PassportController(_FakePassportRepository());
    await controller.verify('BAD-CODE');
    expect(controller.verification?.isValid, isFalse);
  });
}
