import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../models/crop_passport.dart';
import '../crop/crop_repository.dart';
import 'passport_repository.dart';

/// Mock digital passport + QR verification fixtures for Phase 6.
class MockPassportRepository implements PassportRepository {
  MockPassportRepository(this._cropRepository);

  final CropRepository _cropRepository;
  static const _delay = Duration(milliseconds: 480);

  @override
  Future<Result<List<CropPassport>>> listPassports({String? cropBatchId}) async {
    await Future<void>.delayed(_delay);
    final all = await _buildAll();
    if (cropBatchId == null) return Success(all);
    return Success(all.where((p) => p.cropBatchId == cropBatchId).toList());
  }

  @override
  Future<Result<PassportDetail>> getPassport(String passportId) async {
    await Future<void>.delayed(_delay);
    final all = await _buildAll();
    final match = all.where((p) => p.id == passportId).toList();
    if (match.isEmpty) {
      return const Failure(NotFoundException('Passport not found.'));
    }
    return Success(
      PassportDetail(
        passport: match.first,
        timeline: _timelineFor(match.first),
      ),
    );
  }

  @override
  Future<Result<PassportDetail>> getPassportForCrop(String cropBatchId) async {
    await Future<void>.delayed(_delay);
    final all = await _buildAll();
    final match = all.where((p) => p.cropBatchId == cropBatchId).toList();
    if (match.isEmpty) {
      // Auto-issue a draft-style passport for any known crop without one.
      final cropResult = await _cropRepository.getCropById(cropBatchId);
      final crop = cropResult.valueOrNull;
      if (crop == null) {
        return const Failure(NotFoundException('Crop batch not found.'));
      }
      final issued = _passportFromCrop(
        crop.id,
        crop.displayTitle,
        crop.farmName,
        crop.trustScore,
        status: PassportVerificationStatus.draft,
        codeSuffix: 'NEW',
      );
      return Success(
        PassportDetail(passport: issued, timeline: _timelineFor(issued)),
      );
    }
    return Success(
      PassportDetail(
        passport: match.first,
        timeline: _timelineFor(match.first),
      ),
    );
  }

  @override
  Future<Result<PassportVerificationResult>> verifyCode(String code) async {
    await Future<void>.delayed(_delay);
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) {
      return const Success(
        PassportVerificationResult(
          isValid: false,
          message: 'Enter a verification code from a CropSure passport QR.',
        ),
      );
    }

    final all = await _buildAll();
    for (final passport in all) {
      final payloadMatch = passport.qrPayload.toUpperCase().contains(normalized);
      final codeMatch =
          passport.verificationCode?.toUpperCase() == normalized;
      if (payloadMatch || codeMatch) {
        return Success(
          PassportVerificationResult(
            isValid: passport.status == PassportVerificationStatus.verified ||
                passport.status == PassportVerificationStatus.pending,
            message: passport.status == PassportVerificationStatus.verified
                ? 'Passport verified. Crop provenance matches CropSure records.'
                : 'Code recognized. Passport is ${passport.status.displayName.toLowerCase()}.',
            passport: passport,
            verifiedAt: DateTime.now(),
          ),
        );
      }
    }

    return const Success(
      PassportVerificationResult(
        isValid: false,
        message: 'No matching passport for this code. Check and try again.',
      ),
    );
  }

  Future<List<CropPassport>> _buildAll() async {
    final cropsResult = await _cropRepository.getCrops();
    final crops = cropsResult.valueOrNull ?? const [];
    if (crops.isEmpty) return const [];

    final passports = <CropPassport>[];
    for (var i = 0; i < crops.length; i++) {
      final crop = crops[i];
      final status = switch (i % 3) {
        0 => PassportVerificationStatus.verified,
        1 => PassportVerificationStatus.pending,
        _ => PassportVerificationStatus.draft,
      };
      passports.add(
        _passportFromCrop(
          crop.id,
          crop.displayTitle,
          crop.farmName,
          crop.trustScore,
          status: status,
          codeSuffix: '${i + 1}'.padLeft(2, '0'),
        ),
      );
    }
    return passports;
  }

  CropPassport _passportFromCrop(
    String cropId,
    String label,
    String farmName,
    double? trust, {
    required PassportVerificationStatus status,
    required String codeSuffix,
  }) {
    final now = DateTime.now();
    final code = 'CS-PASS-$codeSuffix';
    return CropPassport(
      id: 'passport-$cropId',
      cropBatchId: cropId,
      cropLabel: label,
      farmName: farmName,
      status: status,
      qrPayload: 'cropsure://passport/verify?code=$code',
      verificationCode: code,
      trustScore: trust,
      issuedAt: now.subtract(Duration(days: 12 + codeSuffix.hashCode % 5)),
      updatedAt: now.subtract(const Duration(hours: 6)),
      expiresAt: now.add(const Duration(days: 180)),
      verifierName: status == PassportVerificationStatus.verified
          ? 'CropSure Field Lab'
          : null,
      summary:
          'Digital crop passport for $label from $farmName. '
          'Includes planting, health, trust, and verification trail.',
    );
  }

  List<PassportTimelineEvent> _timelineFor(CropPassport passport) {
    final base = passport.issuedAt;
    return [
      PassportTimelineEvent(
        id: '${passport.id}-created',
        type: PassportEventType.created,
        title: 'Passport opened',
        occurredAt: base,
        description: 'Digital passport record created for ${passport.cropLabel}.',
      ),
      PassportTimelineEvent(
        id: '${passport.id}-planted',
        type: PassportEventType.planted,
        title: 'Field provenance linked',
        occurredAt: base.add(const Duration(hours: 4)),
        description: 'Linked to ${passport.farmName}.',
      ),
      PassportTimelineEvent(
        id: '${passport.id}-disease',
        type: PassportEventType.diseaseAnalysis,
        title: 'AI disease check recorded',
        occurredAt: base.add(const Duration(days: 3)),
        description: 'Latest analysis snapshot attached to the passport trail.',
      ),
      PassportTimelineEvent(
        id: '${passport.id}-treatment',
        type: PassportEventType.treatmentApplied,
        title: 'Treatment logged',
        occurredAt: base.add(const Duration(days: 5)),
        description: 'Treatment history synced for buyer / verifier review.',
      ),
      PassportTimelineEvent(
        id: '${passport.id}-trust',
        type: PassportEventType.trustUpdated,
        title: 'Trust score refreshed',
        occurredAt: base.add(const Duration(days: 7)),
        description: passport.trustScore == null
            ? 'Trust engine snapshot pending.'
            : 'Trust score ${passport.trustScore!.toStringAsFixed(0)} attached.',
      ),
      PassportTimelineEvent(
        id: '${passport.id}-qr',
        type: PassportEventType.qrIssued,
        title: 'QR verification code issued',
        occurredAt: base.add(const Duration(days: 8)),
        description: 'Code ${passport.verificationCode} ready for sharing.',
      ),
      if (passport.status == PassportVerificationStatus.verified)
        PassportTimelineEvent(
          id: '${passport.id}-verified',
          type: PassportEventType.verified,
          title: 'Verified by ${passport.verifierName ?? 'CropSure'}',
          occurredAt: passport.updatedAt,
          description: 'Passport status set to Verified.',
        ),
    ];
  }
}
