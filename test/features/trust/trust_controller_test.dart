import 'package:cropsure/core/utils/load_state.dart';
import 'package:cropsure/core/utils/result.dart';
import 'package:cropsure/features/trust/controllers/trust_controller.dart';
import 'package:cropsure/models/trust_score.dart';
import 'package:cropsure/services/trust/trust_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTrustRepository implements TrustRepository {
  @override
  Future<Result<TrustScoreDetail>> getTrustScore({String? cropBatchId}) async {
    return Success(
      TrustScoreDetail(
        score: 82,
        confidence: 0.88,
        updatedAt: DateTime(2026, 8, 25),
        trendLabel: 'Improving',
        cropBatchId: cropBatchId,
        cropLabel: cropBatchId == null ? null : 'Tomato · Hybrid 61',
        history: [
          TrustHistoryPoint(date: DateTime(2026, 8, 20), score: 75),
          TrustHistoryPoint(date: DateTime(2026, 8, 25), score: 82),
        ],
        signals: const [
          TrustSignal(
            id: 'disease',
            name: 'Disease risk',
            contribution: 0.1,
            statusLabel: 'Favorable',
          ),
        ],
      ),
    );
  }
}

void main() {
  test('TrustController loads overall score', () async {
    final controller = TrustController(_FakeTrustRepository());
    await controller.load();
    expect(controller.state, LoadState.success);
    expect(controller.detail?.score, 82);
    expect(controller.detail?.trendLabel, 'Improving');
  });

  test('TrustController loads crop-scoped score', () async {
    final controller = TrustController(_FakeTrustRepository());
    await controller.load(cropBatchId: 'crop-001');
    expect(controller.detail?.cropBatchId, 'crop-001');
    expect(controller.detail?.cropLabel, isNotNull);
  });
}
