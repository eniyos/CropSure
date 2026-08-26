import 'package:flutter/foundation.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/utils/load_state.dart';
import '../../../core/utils/result.dart';
import '../../../models/treatment.dart';
import '../../../services/treatment/treatment_repository.dart';

class TreatmentController extends ChangeNotifier {
  TreatmentController(this._repository);

  final TreatmentRepository _repository;

  LoadState _listState = LoadState.idle;
  LoadState _detailState = LoadState.idle;
  LoadState _saveState = LoadState.idle;
  List<Treatment> _treatments = const [];
  Treatment? _selected;
  String? _filterCropId;
  String? _errorMessage;
  String? _successMessage;

  LoadState get listState => _listState;
  LoadState get detailState => _detailState;
  LoadState get saveState => _saveState;
  List<Treatment> get treatments => _treatments;
  Treatment? get selected => _selected;
  String? get filterCropId => _filterCropId;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isSaving => _saveState == LoadState.loading;

  Future<void> loadTreatments({String? cropBatchId}) async {
    _filterCropId = cropBatchId;
    _listState = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getTreatments(cropBatchId: cropBatchId);
    result.when(
      success: (items) {
        _treatments = items;
        _listState = items.isEmpty ? LoadState.empty : LoadState.success;
      },
      failure: (error) {
        _errorMessage = ErrorMapper.fromObject(error).message;
        _listState = LoadState.error;
      },
    );
    notifyListeners();
  }

  Future<void> loadTreatment(String id) async {
    _detailState = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getTreatmentById(id);
    result.when(
      success: (item) {
        _selected = item;
        _detailState = LoadState.success;
      },
      failure: (error) {
        _selected = null;
        _errorMessage = ErrorMapper.fromObject(error).message;
        _detailState = LoadState.error;
      },
    );
    notifyListeners();
  }

  Future<Treatment?> createTreatment(TreatmentInput input) =>
      _save(() => _repository.createTreatment(input));

  Future<Treatment?> updateTreatment(String id, TreatmentInput input) =>
      _save(() => _repository.updateTreatment(id, input));

  Future<bool> deleteTreatment(String id) async {
    _saveState = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.deleteTreatment(id);
    final ok = result.when(
      success: (_) {
        _successMessage = 'Treatment removed.';
        return true;
      },
      failure: (error) {
        _errorMessage = ErrorMapper.fromObject(error).message;
        return false;
      },
    );
    _saveState = ok ? LoadState.success : LoadState.error;
    notifyListeners();
    if (ok) await loadTreatments(cropBatchId: _filterCropId);
    return ok;
  }

  Future<Treatment?> _save(Future<Result<Treatment>> Function() action) async {
    _saveState = LoadState.loading;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await action();
    Treatment? saved;
    result.when(
      success: (item) {
        saved = item;
        _selected = item;
        _successMessage = 'Treatment saved.';
        _saveState = LoadState.success;
      },
      failure: (error) {
        _errorMessage = ErrorMapper.fromObject(error).message;
        _saveState = LoadState.error;
      },
    );
    notifyListeners();
    if (saved != null) await loadTreatments(cropBatchId: _filterCropId);
    return saved;
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
