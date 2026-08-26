/// Full weather report from the backend weather service.
class WeatherReport {
  const WeatherReport({
    required this.locationLabel,
    required this.condition,
    required this.temperatureC,
    required this.humidityPercent,
    required this.updatedAt,
    required this.forecast,
    this.rainChancePercent,
    this.rainfallMm,
    this.windKph,
    this.agriculturalRisks = const [],
    this.advisory,
  });

  final String locationLabel;
  final String condition;
  final double temperatureC;
  final double humidityPercent;
  final DateTime updatedAt;
  final List<WeatherForecastDay> forecast;
  final double? rainChancePercent;
  final double? rainfallMm;
  final double? windKph;
  final List<AgriculturalRisk> agriculturalRisks;
  final String? advisory;
}

class WeatherForecastDay {
  const WeatherForecastDay({
    required this.date,
    required this.condition,
    required this.highC,
    required this.lowC,
    this.rainChancePercent,
  });

  final DateTime date;
  final String condition;
  final double highC;
  final double lowC;
  final double? rainChancePercent;
}

class AgriculturalRisk {
  const AgriculturalRisk({
    required this.title,
    required this.levelLabel,
    required this.description,
  });

  final String title;
  final String levelLabel;
  final String description;
}
