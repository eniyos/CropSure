import 'package:cropsure/core/utils/load_state.dart';
import 'package:cropsure/features/weather/controllers/weather_controller.dart';
import 'package:cropsure/services/weather/mock_weather_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('WeatherController loads report', () async {
    final controller = WeatherController(MockWeatherRepository());
    await controller.load();
    expect(controller.state, LoadState.success);
    expect(controller.report?.temperatureC, 29);
    expect(controller.report?.forecast, isNotEmpty);
  });
}
