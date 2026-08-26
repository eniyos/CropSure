import 'package:flutter/foundation.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/utils/load_state.dart';
import '../../../models/trust_score.dart';
import '../../../services/trust/trust_repository.dart';

class TrustController extends ChangeNotifier {
  TrustController(this._repository);

  final TrustRepository _repository;

  LoadState _state = LoadState.idle;
  TrustScoreDetail? _detail;
  String? _cropBatchId;
  String? _errorMessage;

  LoadState get state => _state;
  TrustScoreDetail? get detail => _detail;
  String? get cropBatchId => _cropBatchId;
  String? get errorMessage => _errorMessage;

  Future<void> load({String? cropBatchId}) async {
    _cropBatchId = cropBatchId;
    _state = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getTrustScore(cropBatchId: cropBatchId);
    result.when(
      success: (detail) {
        _detail = detail;
        _state = LoadState.success;
      },
      failure: (error) {
        _errorMessage = ErrorMapper.fromObject(error).message;
        _state = LoadState.error;
      },
    );
    notifyListeners();
  }

  Future<void> refresh() => load(cropBatchId: _cropBatchId);
}
