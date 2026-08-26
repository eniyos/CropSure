import 'dart:typed_data';

import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../models/disease_analysis.dart';
import '../../models/disease_severity.dart';
import 'disease_analysis_repository.dart';

/// Development mock for the AI disease analysis service.
///
/// Does **not** run ML inference. Returns realistic backend-shaped results
/// so the Flutter UI can be demonstrated before FastAPI integration.
class MockDiseaseAnalysisRepository implements DiseaseAnalysisRepository {
  static const _uploadDelay = Duration(milliseconds: 900);
  static const _analysisDelay = Duration(milliseconds: 1600);

  @override
  Future<Result<DiseaseAnalysisResult>> analyzeCropImage({
    required String cropBatchId,
    required String cropLabel,
    required Uint8List imageBytes,
    String? fileName,
  }) async {
    if (imageBytes.isEmpty) {
      return const Failure(
        ValidationException('Please select a crop leaf image first.'),
      );
    }

    await Future<void>.delayed(_uploadDelay);
    await Future<void>.delayed(_analysisDelay);

    final now = DateTime.now();
    final analysisId = 'analysis-${now.millisecondsSinceEpoch}';

    return Success(
      DiseaseAnalysisResult(
        id: analysisId,
        cropBatchId: cropBatchId,
        cropLabel: cropLabel,
        diseaseName: 'Early Blight',
        confidence: 0.913,
        severity: DiseaseSeverityLevel.moderate,
        severityScore: 58,
        analyzedAt: now,
        explanation:
            'The AI service detected lesion patterns consistent with Early Blight '
            'on the submitted leaf sample. Confidence is high based on texture and '
            'color features returned by the remote model. Review Grad-CAM to see '
            'which regions influenced this prediction.',
        gradCam: const GradCamResult(
          explanation:
              'Highlighted regions show where the remote model focused while '
              'classifying this leaf. Warmer areas indicate stronger attention.',
          attentionAreas: [
            'Lower-left lesion cluster',
            'Mid-leaf chlorotic patches',
            'Leaf margin irregularities',
          ],
        ),
        progression: _buildProgression(ProgressionHorizon.days14, now),
        yieldPrediction: YieldPrediction(
          predictedYield: 18.4,
          unit: 't/ha',
          seasonLabel: 'Kharif 2026',
          confidence: 0.79,
          asOf: now,
          explanation:
              'Yield estimate from the backend prediction service using current '
              'crop stage, recent disease signals, and seasonal context. '
              'This is not calculated inside the mobile app.',
        ),
      ),
    );
  }

  @override
  Future<Result<DiseaseProgression>> getProgression({
    required String analysisId,
    required ProgressionHorizon horizon,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (analysisId.isEmpty) {
      return const Failure(NotFoundException('Analysis not found.'));
    }
    return Success(_buildProgression(horizon, DateTime.now()));
  }

  DiseaseProgression _buildProgression(
    ProgressionHorizon horizon,
    DateTime start,
  ) {
    final days = horizon.dayCount;
    final points = <ProgressionPoint>[
      for (var day = 0; day <= days; day += horizon == ProgressionHorizon.days7 ? 1 : 2)
        ProgressionPoint(
          dayOffset: day,
          date: start.add(Duration(days: day)),
          riskScore: (42 + day * (horizon == ProgressionHorizon.days30 ? 1.1 : 1.6))
              .clamp(0, 95)
              .toDouble(),
        ),
    ];

    final last = points.last.riskScore;
    final riskLabel = last < 50
        ? 'Moderate predicted risk'
        : last < 70
        ? 'Elevated predicted risk'
        : 'High predicted risk';

    return DiseaseProgression(
      horizon: horizon,
      points: points,
      riskLabel: riskLabel,
      explanation:
          'These ${horizon.label} values are predictions from the backend '
          'disease-progression service. They are forecasts only and do not '
          'replace field inspection.',
    );
  }
}
