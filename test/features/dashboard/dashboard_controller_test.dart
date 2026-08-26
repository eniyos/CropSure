import 'package:cropsure/core/utils/load_state.dart';
import 'package:cropsure/core/utils/result.dart';
import 'package:cropsure/features/dashboard/controllers/dashboard_controller.dart';
import 'package:cropsure/models/dashboard_summary.dart';
import 'package:cropsure/services/dashboard/dashboard_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDashboardRepository implements DashboardRepository {
  @override
  Future<Result<DashboardSummary>> getFarmerDashboard() async {
    return Success(
      DashboardSummary(
        healthSummaryLabel: 'All monitored crops look healthy',
        healthyBatchCount: 2,
        atRiskBatchCount: 0,
        activeBatches: const [],
        trustScore: 80,
        trustConfidence: 0.9,
        trustUpdatedAt: DateTime(2026, 8, 25),
      ),
    );
  }
}

void main() {
  test('DashboardController loads summary', () async {
    final controller = DashboardController(_FakeDashboardRepository());
    await controller.load();
    expect(controller.state, LoadState.success);
    expect(controller.summary?.trustScore, 80);
  });
}
