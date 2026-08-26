/// Crop growth stages displayed in the app. Backend may map different labels later.
enum GrowthStage {
  seedling,
  vegetative,
  flowering,
  fruiting,
  maturity,
  harvest;

  String get displayName => switch (this) {
    GrowthStage.seedling => 'Seedling',
    GrowthStage.vegetative => 'Vegetative',
    GrowthStage.flowering => 'Flowering',
    GrowthStage.fruiting => 'Fruiting',
    GrowthStage.maturity => 'Maturity',
    GrowthStage.harvest => 'Harvest',
  };

  static GrowthStage fromString(String? value) {
    return GrowthStage.values.firstWhere(
      (stage) => stage.name == value?.toLowerCase().trim(),
      orElse: () => GrowthStage.vegetative,
    );
  }
}

/// Health label for list/dashboard summaries (backend-provided in production).
enum CropHealthStatus {
  healthy,
  watch,
  atRisk,
  critical,
  unknown;

  String get displayName => switch (this) {
    CropHealthStatus.healthy => 'Healthy',
    CropHealthStatus.watch => 'Watch',
    CropHealthStatus.atRisk => 'At risk',
    CropHealthStatus.critical => 'Critical',
    CropHealthStatus.unknown => 'Unknown',
  };

  static CropHealthStatus fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'healthy':
        return CropHealthStatus.healthy;
      case 'watch':
        return CropHealthStatus.watch;
      case 'at_risk':
      case 'atrisk':
        return CropHealthStatus.atRisk;
      case 'critical':
        return CropHealthStatus.critical;
      default:
        return CropHealthStatus.unknown;
    }
  }
}

class CropBatch {
  const CropBatch({
    required this.id,
    required this.farmId,
    required this.farmName,
    required this.cropType,
    required this.variety,
    required this.plantingDate,
    required this.growthStage,
    this.healthStatus = CropHealthStatus.unknown,
    this.areaHectares,
    this.notes,
    this.trustScore,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String farmId;
  final String farmName;
  final String cropType;
  final String variety;
  final DateTime plantingDate;
  final GrowthStage growthStage;
  final CropHealthStatus healthStatus;
  final double? areaHectares;
  final String? notes;
  final double? trustScore;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayTitle => '$cropType · $variety';

  CropBatch copyWith({
    String? id,
    String? farmId,
    String? farmName,
    String? cropType,
    String? variety,
    DateTime? plantingDate,
    GrowthStage? growthStage,
    CropHealthStatus? healthStatus,
    double? areaHectares,
    String? notes,
    double? trustScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CropBatch(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      farmName: farmName ?? this.farmName,
      cropType: cropType ?? this.cropType,
      variety: variety ?? this.variety,
      plantingDate: plantingDate ?? this.plantingDate,
      growthStage: growthStage ?? this.growthStage,
      healthStatus: healthStatus ?? this.healthStatus,
      areaHectares: areaHectares ?? this.areaHectares,
      notes: notes ?? this.notes,
      trustScore: trustScore ?? this.trustScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory CropBatch.fromJson(Map<String, dynamic> json) {
    return CropBatch(
      id: json['id'] as String? ?? '',
      farmId: json['farm_id'] as String? ?? json['farmId'] as String? ?? '',
      farmName:
          json['farm_name'] as String? ?? json['farmName'] as String? ?? '',
      cropType:
          json['crop_type'] as String? ?? json['cropType'] as String? ?? '',
      variety: json['variety'] as String? ?? '',
      plantingDate:
          DateTime.tryParse(
            json['planting_date'] as String? ??
                json['plantingDate'] as String? ??
                '',
          ) ??
          DateTime.now(),
      growthStage: GrowthStage.fromString(
        json['growth_stage'] as String? ?? json['growthStage'] as String?,
      ),
      healthStatus: CropHealthStatus.fromString(
        json['health_status'] as String? ?? json['healthStatus'] as String?,
      ),
      areaHectares: (json['area_hectares'] as num?)?.toDouble() ??
          (json['areaHectares'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      trustScore: (json['trust_score'] as num?)?.toDouble() ??
          (json['trustScore'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse(
        json['created_at'] as String? ?? json['createdAt'] as String? ?? '',
      ),
      updatedAt: DateTime.tryParse(
        json['updated_at'] as String? ?? json['updatedAt'] as String? ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'farm_id': farmId,
    'farm_name': farmName,
    'crop_type': cropType,
    'variety': variety,
    'planting_date': plantingDate.toIso8601String(),
    'growth_stage': growthStage.name,
    'health_status': healthStatus.name,
    if (areaHectares != null) 'area_hectares': areaHectares,
    if (notes != null) 'notes': notes,
    if (trustScore != null) 'trust_score': trustScore,
  };
}

class CropBatchInput {
  const CropBatchInput({
    required this.farmId,
    required this.cropType,
    required this.variety,
    required this.plantingDate,
    required this.growthStage,
    this.areaHectares,
    this.notes,
  });

  final String farmId;
  final String cropType;
  final String variety;
  final DateTime plantingDate;
  final GrowthStage growthStage;
  final double? areaHectares;
  final String? notes;
}
