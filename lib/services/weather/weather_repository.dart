import '../../core/utils/result.dart';
import '../../models/weather.dart';

abstract class WeatherRepository {
  Future<Result<WeatherReport>> getWeather();
}
