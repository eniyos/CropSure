import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../models/trust_score.dart';
import '../crop/crop_repository.dart';
import 'trust_repository.dart';

/// Mock Trust Engine responses for UI development.
///
/// Does not compute Bayesian trust. Values are backend-shaped fixtures.
class MockTrustRepository implements TrustRepository {
  MockTrustRepository(this._cropRepository);

  final CropRepository _cropRepository;
  static const _delay = Duration(milliseconds: 550);

  @override
  Future<Result<TrustScoreDetail>> getTrustScore({String? cropBatchId}) async {
    await Future<void>.delayed(_delay);

    if (cropBatchId != null) {
      final cropResult = await _cropRepository.getCropById(cropBatchId);
      final crop = cropResult.valueOrNull;
      if (crop == null) {
        return const Failure(NotFoundException('Crop batch not found.'));
      }

      final score = crop.trustScore ?? 72;
      return Success(
        _buildDetail(
          score: score,
          cropBatchId: crop.id,
          cropLabel: crop.displayTitle,
          baseConfidence: 0.86,
        ),
      );
    }

    final cropsResult = await _cropRepository.getCrops();
    final crops = cropsResult.valueOrNull ?? const [];
    final scores = crops.map((c) => c.trustScore).whereType<double>().toList();
    final avg = scores.isEmpty
        ? 74.0
        : scores.reduce((a, b) => a + b) / scores.length;

    return Success(
      _buildDetail(
        score: avg,
        cropBatchId: null,
        cropLabel: null,
        baseConfidence: 0.84,
      ),
    );
  }

  TrustScoreDetail _buildDetail({
    required double score,
    required double baseConfidence,
    String? cropBatchId,
    String? cropLabel,
  }) {
    final now = DateTime.now();
    final history = [
      for (var i = 13; i >= 0; i--)
        TrustHistoryPoint(
          date: now.subtract(Duration(days: i)),
          score: (score - 8 + (13 - i) * 0.6).clamp(40, 98).toDouble(),
        ),
    ];

    final delta = history.last.score - history.first.score;
    final trendLabel = delta >= 2
        ? 'Improving'
        : delta <= -2
        ? 'Declining'
        : 'Stable';

    return TrustScoreDetail(
      score: score,
      confidence: baseConfidence,
      updatedAt: now.subtract(const Duration(hours: 4)),
      trendLabel: trendLabel,
      cropBatchId: cropBatchId,
      cropLabel: cropLabel,
      explanation:
          'Dynamic Crop Trust Score is produced by the CropSure Trust Engine '
          'from disease, treatment, weather, and market signals. '
          'The mobile app only displays the engine result.',
      history: history,
      signals: [
        TrustSignal(
          id: 'disease',
          name: 'Disease risk',
          contribution: score >= 80 ? 0.18 : -0.22,
          statusLabel: score >= 80 ? 'Favorable' : 'Watch',
          description: 'Recent AI disease findings and severity.',
        ),
        TrustSignal(
          id: 'treatment',
          name: 'Treatment compliance',
          contribution: 0.14,
          statusLabel: 'On track',
          description: 'Logged treatments relative to advisory schedule.',
        ),
        TrustSignal(
          id: 'weather',
          name: 'Weather stress',
          contribution: -0.08,
          statusLabel: 'Mild stress',
          description: 'Humidity and rainfall risk for the farm region.',
        ),
        TrustSignal(
          id: 'growth',
          name: 'Growth stage health',
          contribution: 0.11,
          statusLabel: 'Healthy',
          description: 'Crop stage consistency with expected development.',
        ),
      ],
    );
  }
}
