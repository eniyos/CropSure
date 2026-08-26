import 'package:flutter/foundation.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/utils/load_state.dart';
import '../../../models/weather.dart';
import '../../../services/weather/weather_repository.dart';

class WeatherController extends ChangeNotifier {
  WeatherController(this._repository);

  final WeatherRepository _repository;

  LoadState _state = LoadState.idle;
  WeatherReport? _report;
  String? _errorMessage;

  LoadState get state => _state;
  WeatherReport? get report => _report;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _state = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getWeather();
    result.when(
      success: (report) {
        _report = report;
        _state = LoadState.success;
      },
      failure: (error) {
        _errorMessage = ErrorMapper.fromObject(error).message;
        _state = LoadState.error;
      },
    );
    notifyListeners();
  }
}
