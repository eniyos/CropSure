import 'dart:typed_data';

import '../../core/utils/result.dart';
import '../../models/disease_analysis.dart';

/// Contract for AI disease analysis. UI never calls HTTP directly.
abstract class DiseaseAnalysisRepository {
  Future<Result<DiseaseAnalysisResult>> analyzeCropImage({
    required String cropBatchId,
    required String cropLabel,
    required Uint8List imageBytes,
    String? fileName,
  });

  Future<Result<DiseaseProgression>> getProgression({
    required String analysisId,
    required ProgressionHorizon horizon,
  });
}
