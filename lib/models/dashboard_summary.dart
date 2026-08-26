import 'crop_batch.dart';

/// Dashboard payload assembled by backend (or mock) for the farmer home screen.
class DashboardSummary {
  const DashboardSummary({
    required this.healthSummaryLabel,
    required this.healthyBatchCount,
    required this.atRiskBatchCount,
    required this.activeBatches,
    required this.trustScore,
    required this.trustConfidence,
    required this.trustUpdatedAt,
    this.latestDisease,
    this.weather,
    this.market,
    this.notifications = const [],
  });

  final String healthSummaryLabel;
  final int healthyBatchCount;
  final int atRiskBatchCount;
  final List<CropBatch> activeBatches;
  final double trustScore;
  final double trustConfidence;
  final DateTime trustUpdatedAt;
  final LatestDiseaseSummary? latestDisease;
  final WeatherSummary? weather;
  final MarketSummary? market;
  final List<NotificationSummary> notifications;
}

class LatestDiseaseSummary {
  const LatestDiseaseSummary({
    required this.cropBatchId,
    required this.cropLabel,
    required this.diseaseName,
    required this.confidence,
    required this.severityLabel,
    required this.analyzedAt,
  });

  final String cropBatchId;
  final String cropLabel;
  final String diseaseName;
  final double confidence;
  final String severityLabel;
  final DateTime analyzedAt;
}

class WeatherSummary {
  const WeatherSummary({
    required this.condition,
    required this.temperatureC,
    required this.humidityPercent,
    this.rainChancePercent,
    this.advisory,
  });

  final String condition;
  final double temperatureC;
  final double humidityPercent;
  final double? rainChancePercent;
  final String? advisory;
}

class MarketSummary {
  const MarketSummary({
    required this.crop,
    required this.marketName,
    required this.price,
    required this.unit,
    required this.updatedAt,
  });

  final String crop;
  final String marketName;
  final double price;
  final String unit;
  final DateTime updatedAt;
}

class NotificationSummary {
  const NotificationSummary({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  final bool isRead;
}
