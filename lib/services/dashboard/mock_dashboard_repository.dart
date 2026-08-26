import '../../core/utils/result.dart';
import '../../models/crop_batch.dart';
import '../../models/dashboard_summary.dart';
import '../crop/crop_repository.dart';
import 'dashboard_repository.dart';

/// Assembles farmer dashboard data from mock sources.
class MockDashboardRepository implements DashboardRepository {
  MockDashboardRepository(this._cropRepository);

  final CropRepository _cropRepository;
  static const _delay = Duration(milliseconds: 500);

  @override
  Future<Result<DashboardSummary>> getFarmerDashboard() async {
    await Future<void>.delayed(_delay);
    final cropsResult = await _cropRepository.getCrops();
    final crops = cropsResult.valueOrNull ?? const <CropBatch>[];

    final healthy = crops
        .where((c) => c.healthStatus == CropHealthStatus.healthy)
        .length;
    final atRisk = crops
        .where(
          (c) =>
              c.healthStatus == CropHealthStatus.atRisk ||
              c.healthStatus == CropHealthStatus.critical ||
              c.healthStatus == CropHealthStatus.watch,
        )
        .length;

    final scores = crops
        .map((c) => c.trustScore)
        .whereType<double>()
        .toList();
    final avgTrust = scores.isEmpty
        ? 72.0
        : scores.reduce((a, b) => a + b) / scores.length;

    String healthLabel;
    if (crops.isEmpty) {
      healthLabel = 'No active crop batches yet';
    } else if (atRisk == 0) {
      healthLabel = 'All monitored crops look healthy';
    } else if (atRisk == 1) {
      healthLabel = '1 crop needs attention';
    } else {
      healthLabel = '$atRisk crops need attention';
    }

    return Success(
      DashboardSummary(
        healthSummaryLabel: healthLabel,
        healthyBatchCount: healthy,
        atRiskBatchCount: atRisk,
        activeBatches: crops,
        trustScore: avgTrust,
        trustConfidence: 0.84,
        trustUpdatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        latestDisease: crops.isEmpty
            ? null
            : LatestDiseaseSummary(
                cropBatchId: crops.first.id,
                cropLabel: crops.first.displayTitle,
                diseaseName: 'Early Blight',
                confidence: 0.91,
                severityLabel: 'Moderate',
                analyzedAt: DateTime.now().subtract(const Duration(hours: 14)),
              ),
        weather: const WeatherSummary(
          condition: 'Partly cloudy',
          temperatureC: 29,
          humidityPercent: 62,
          rainChancePercent: 35,
          advisory: 'Moderate humidity — monitor leaf wetness overnight.',
        ),
        market: MarketSummary(
          crop: 'Tomato',
          marketName: 'Nashik APMC',
          price: 28.5,
          unit: '₹/kg',
          updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        notifications: [
          NotificationSummary(
            id: 'n1',
            title: 'Disease alert',
            body: 'Early blight confidence above 90% on Tomato · Hybrid 61.',
            type: 'disease_alert',
            createdAt: DateTime.now().subtract(const Duration(hours: 14)),
          ),
          NotificationSummary(
            id: 'n2',
            title: 'Trust score update',
            body: 'Overall Dynamic Crop Trust Score refreshed.',
            type: 'trust_update',
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
            isRead: true,
          ),
          NotificationSummary(
            id: 'n3',
            title: 'Weather advisory',
            body: 'Rain chance 35% tonight. Check drainage on Riverbend Fields.',
            type: 'weather_alert',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
      ),
    );
  }
}
