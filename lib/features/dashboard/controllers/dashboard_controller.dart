import 'package:flutter/foundation.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/utils/load_state.dart';
import '../../../models/dashboard_summary.dart';
import '../../../services/dashboard/dashboard_repository.dart';

class DashboardController extends ChangeNotifier {
  DashboardController(this._repository);

  final DashboardRepository _repository;

  LoadState _state = LoadState.idle;
  DashboardSummary? _summary;
  String? _errorMessage;

  LoadState get state => _state;
  DashboardSummary? get summary => _summary;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _state = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getFarmerDashboard();
    result.when(
      success: (summary) {
        _summary = summary;
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
