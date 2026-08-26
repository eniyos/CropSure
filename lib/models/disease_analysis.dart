import 'disease_severity.dart';

/// Full AI disease analysis payload returned by the backend AI service.
///
/// Flutter never runs inference locally — this model only displays API results.
class DiseaseAnalysisResult {
  const DiseaseAnalysisResult({
    required this.id,
    required this.cropBatchId,
    required this.cropLabel,
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    required this.severityScore,
    required this.analyzedAt,
    required this.explanation,
    this.gradCam,
    this.progression,
    this.yieldPrediction,
  });

  final String id;
  final String cropBatchId;
  final String cropLabel;
  final String diseaseName;
  final double confidence;
  final DiseaseSeverityLevel severity;
  final double severityScore;
  final DateTime analyzedAt;
  final String explanation;
  final GradCamResult? gradCam;
  final DiseaseProgression? progression;
  final YieldPrediction? yieldPrediction;
}

/// Grad-CAM visualization metadata from the AI service (not computed in-app).
class GradCamResult {
  const GradCamResult({
    required this.explanation,
    required this.attentionAreas,
    this.heatmapImageUrl,
    this.overlayOpacity = 0.55,
  });

  final String explanation;
  final List<String> attentionAreas;

  /// Optional remote heatmap URL when the AI service provides one.
  final String? heatmapImageUrl;
  final double overlayOpacity;
}

enum ProgressionHorizon { days7, days14, days30 }

extension ProgressionHorizonX on ProgressionHorizon {
  String get label => switch (this) {
    ProgressionHorizon.days7 => '7-day',
    ProgressionHorizon.days14 => '14-day',
    ProgressionHorizon.days30 => '30-day',
  };

  int get dayCount => switch (this) {
    ProgressionHorizon.days7 => 7,
    ProgressionHorizon.days14 => 14,
    ProgressionHorizon.days30 => 30,
  };
}

class ProgressionPoint {
  const ProgressionPoint({
    required this.dayOffset,
    required this.date,
    required this.riskScore,
  });

  final int dayOffset;
  final DateTime date;

  /// Predicted disease risk score 0–100 from the backend model.
  final double riskScore;
}

class DiseaseProgression {
  const DiseaseProgression({
    required this.horizon,
    required this.points,
    required this.riskLabel,
    required this.explanation,
  });

  final ProgressionHorizon horizon;
  final List<ProgressionPoint> points;
  final String riskLabel;
  final String explanation;
}

class YieldPrediction {
  const YieldPrediction({
    required this.predictedYield,
    required this.unit,
    required this.seasonLabel,
    this.confidence,
    this.asOf,
    this.explanation,
  });

  final double predictedYield;
  final String unit;
  final String seasonLabel;
  final double? confidence;
  final DateTime? asOf;
  final String? explanation;
}
