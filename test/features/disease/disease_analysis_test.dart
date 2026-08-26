import 'dart:typed_data';

import 'package:cropsure/core/utils/result.dart';
import 'package:cropsure/features/disease/controllers/disease_analysis_controller.dart';
import 'package:cropsure/models/crop_batch.dart';
import 'package:cropsure/models/disease_analysis.dart';
import 'package:cropsure/models/disease_severity.dart';
import 'package:cropsure/services/crop/crop_repository.dart';
import 'package:cropsure/services/disease/disease_analysis_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _CropRepo implements CropRepository {
  @override
  Future<Result<CropBatch>> createCrop(CropBatchInput input) async =>
      const Failure('unused');

  @override
  Future<Result<void>> deleteCrop(String id) async => const Success(null);

  @override
  Future<Result<CropBatch>> getCropById(String id) async => Success(_crop);

  @override
  Future<Result<List<CropBatch>>> getCrops({String? farmId}) async =>
      Success([_crop]);

  @override
  Future<Result<CropBatch>> updateCrop(String id, CropBatchInput input) async =>
      const Failure('unused');

  static final _crop = CropBatch(
    id: 'crop-001',
    farmId: 'farm-001',
    farmName: 'Green Valley Farm',
    cropType: 'Tomato',
    variety: 'Hybrid 61',
    plantingDate: DateTime(2026, 1, 1),
    growthStage: GrowthStage.fruiting,
    healthStatus: CropHealthStatus.watch,
  );
}

class _AnalysisRepo implements DiseaseAnalysisRepository {
  @override
  Future<Result<DiseaseAnalysisResult>> analyzeCropImage({
    required String cropBatchId,
    required String cropLabel,
    required Uint8List imageBytes,
    String? fileName,
  }) async {
    return Success(
      DiseaseAnalysisResult(
        id: 'a1',
        cropBatchId: cropBatchId,
        cropLabel: cropLabel,
        diseaseName: 'Early Blight',
        confidence: 0.91,
        severity: DiseaseSeverityLevel.moderate,
        severityScore: 58,
        analyzedAt: DateTime(2026, 8, 25),
        explanation: 'Mock explanation',
        gradCam: const GradCamResult(
          explanation: 'Focus regions',
          attentionAreas: ['Lesion cluster'],
        ),
        progression: DiseaseProgression(
          horizon: ProgressionHorizon.days7,
          points: [
            ProgressionPoint(
              dayOffset: 0,
              date: DateTime(2026, 8, 25),
              riskScore: 40,
            ),
          ],
          riskLabel: 'Moderate predicted risk',
          explanation: 'Forecast only',
        ),
        yieldPrediction: const YieldPrediction(
          predictedYield: 18.4,
          unit: 't/ha',
          seasonLabel: 'Kharif 2026',
          confidence: 0.8,
        ),
      ),
    );
  }

  @override
  Future<Result<DiseaseProgression>> getProgression({
    required String analysisId,
    required ProgressionHorizon horizon,
  }) async {
    return Success(
      DiseaseProgression(
        horizon: horizon,
        points: [
          ProgressionPoint(
            dayOffset: 0,
            date: DateTime(2026, 8, 25),
            riskScore: 40,
          ),
        ],
        riskLabel: 'Moderate predicted risk',
        explanation: 'Forecast only',
      ),
    );
  }
}

void main() {
  test('bootstrap with cropId skips crop selection', () async {
    final controller = DiseaseAnalysisController(
      analysisRepository: _AnalysisRepo(),
      cropRepository: _CropRepo(),
    );

    await controller.bootstrap(cropId: 'crop-001');
    expect(controller.selectedCrop?.id, 'crop-001');
    expect(controller.step, AnalysisFlowStep.selectImage);
  });

  test('confirmAndAnalyze stores AI service result', () async {
    final controller = DiseaseAnalysisController(
      analysisRepository: _AnalysisRepo(),
      cropRepository: _CropRepo(),
    );
    await controller.bootstrap(cropId: 'crop-001');
    controller.setPickedImage(Uint8List.fromList(List<int>.filled(16, 1)));

    final ok = await controller.confirmAndAnalyze();
    expect(ok, isTrue);
    expect(controller.step, AnalysisFlowStep.result);
    expect(controller.result?.diseaseName, 'Early Blight');
    expect(controller.result?.severity, DiseaseSeverityLevel.moderate);
    expect(controller.result?.gradCam, isNotNull);
    expect(controller.result?.yieldPrediction?.unit, 't/ha');
  });

  test('loadProgression updates horizon prediction', () async {
    final controller = DiseaseAnalysisController(
      analysisRepository: _AnalysisRepo(),
      cropRepository: _CropRepo(),
    );
    await controller.bootstrap(cropId: 'crop-001');
    controller.setPickedImage(Uint8List.fromList([1, 2, 3]));
    await controller.confirmAndAnalyze();
    await controller.loadProgression(ProgressionHorizon.days30);

    expect(controller.horizon, ProgressionHorizon.days30);
    expect(controller.progression?.horizon, ProgressionHorizon.days30);
  });
}
