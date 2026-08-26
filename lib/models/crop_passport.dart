/// Digital crop passport entities (backend-shaped; Flutter displays only).
enum PassportVerificationStatus {
  draft,
  pending,
  verified,
  rejected,
  expired;

  String get displayName => switch (this) {
        PassportVerificationStatus.draft => 'Draft',
        PassportVerificationStatus.pending => 'Pending review',
        PassportVerificationStatus.verified => 'Verified',
        PassportVerificationStatus.rejected => 'Rejected',
        PassportVerificationStatus.expired => 'Expired',
      };

  static PassportVerificationStatus fromString(String? value) {
    return PassportVerificationStatus.values.firstWhere(
      (s) => s.name == value?.toLowerCase().trim(),
      orElse: () => PassportVerificationStatus.pending,
    );
  }
}

enum PassportEventType {
  created,
  planted,
  diseaseAnalysis,
  treatmentApplied,
  trustUpdated,
  qrIssued,
  verified,
  shared;

  String get displayName => switch (this) {
        PassportEventType.created => 'Passport created',
        PassportEventType.planted => 'Crop planted',
        PassportEventType.diseaseAnalysis => 'Disease analysis',
        PassportEventType.treatmentApplied => 'Treatment applied',
        PassportEventType.trustUpdated => 'Trust score updated',
        PassportEventType.qrIssued => 'QR code issued',
        PassportEventType.verified => 'Passport verified',
        PassportEventType.shared => 'Passport shared',
      };
}

class PassportTimelineEvent {
  const PassportTimelineEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.occurredAt,
    this.description,
  });

  final String id;
  final PassportEventType type;
  final String title;
  final DateTime occurredAt;
  final String? description;
}

class CropPassport {
  const CropPassport({
    required this.id,
    required this.cropBatchId,
    required this.cropLabel,
    required this.farmName,
    required this.status,
    required this.qrPayload,
    required this.issuedAt,
    required this.updatedAt,
    this.trustScore,
    this.verificationCode,
    this.verifierName,
    this.expiresAt,
    this.summary,
  });

  final String id;
  final String cropBatchId;
  final String cropLabel;
  final String farmName;
  final PassportVerificationStatus status;
  final String qrPayload;
  final DateTime issuedAt;
  final DateTime updatedAt;
  final double? trustScore;
  final String? verificationCode;
  final String? verifierName;
  final DateTime? expiresAt;
  final String? summary;
}

class PassportDetail {
  const PassportDetail({
    required this.passport,
    required this.timeline,
  });

  final CropPassport passport;
  final List<PassportTimelineEvent> timeline;
}

class PassportVerificationResult {
  const PassportVerificationResult({
    required this.isValid,
    required this.message,
    this.passport,
    this.verifiedAt,
  });

  final bool isValid;
  final String message;
  final CropPassport? passport;
  final DateTime? verifiedAt;
}
