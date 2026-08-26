import 'package:flutter/foundation.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/utils/load_state.dart';
import '../../../models/market_price.dart';
import '../../../services/market/market_repository.dart';

class MarketController extends ChangeNotifier {
  MarketController(this._repository);

  final MarketRepository _repository;

  LoadState _state = LoadState.idle;
  MarketOverview? _overview;
  String? _errorMessage;

  LoadState get state => _state;
  MarketOverview? get overview => _overview;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _state = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getMarketOverview();
    result.when(
      success: (overview) {
        _overview = overview;
        _state = overview.prices.isEmpty ? LoadState.empty : LoadState.success;
      },
      failure: (error) {
        _errorMessage = ErrorMapper.fromObject(error).message;
        _state = LoadState.error;
      },
    );
    notifyListeners();
  }
}
