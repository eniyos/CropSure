import '../../core/utils/result.dart';
import '../../models/weather.dart';
import 'weather_repository.dart';

/// Mock weather service. UI never calls a third-party weather API directly.
class MockWeatherRepository implements WeatherRepository {
  static const _delay = Duration(milliseconds: 500);

  @override
  Future<Result<WeatherReport>> getWeather() async {
    await Future<void>.delayed(_delay);
    final now = DateTime.now();

    return Success(
      WeatherReport(
        locationLabel: 'Nashik, Maharashtra',
        condition: 'Partly cloudy',
        temperatureC: 29,
        humidityPercent: 62,
        rainChancePercent: 35,
        rainfallMm: 1.2,
        windKph: 12,
        updatedAt: now.subtract(const Duration(minutes: 25)),
        advisory:
            'Moderate humidity overnight. Monitor leaf wetness on tomato blocks.',
        forecast: [
          for (var i = 0; i < 5; i++)
            WeatherForecastDay(
              date: now.add(Duration(days: i)),
              condition: i == 2 ? 'Light rain' : (i.isEven ? 'Sunny' : 'Cloudy'),
              highC: 30 - (i * 0.4),
              lowC: 22 - (i * 0.2),
              rainChancePercent: i == 2 ? 65 : 20.0 + i * 5,
            ),
        ],
        agriculturalRisks: const [
          AgriculturalRisk(
            title: 'Fungal disease pressure',
            levelLabel: 'Moderate',
            description:
                'Humidity above 60% with overnight leaf wetness can favor blight.',
          ),
          AgriculturalRisk(
            title: 'Irrigation planning',
            levelLabel: 'Low',
            description:
                'Light rain expected mid-week. Delay heavy irrigation if soils are wet.',
          ),
        ],
      ),
    );
  }
}
