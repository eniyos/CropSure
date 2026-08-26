import 'package:flutter/foundation.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/offline/connectivity_controller.dart';
import '../../../core/utils/load_state.dart';
import '../../../core/utils/result.dart';
import '../../../models/crop_batch.dart';
import '../../../services/crop/crop_repository.dart';
import '../../sync/controllers/sync_controller.dart';

class CropController extends ChangeNotifier {
  CropController(
    this._repository, {
    ConnectivityController? connectivity,
    SyncController? syncController,
  })  : _connectivity = connectivity,
        _syncController = syncController;

  final CropRepository _repository;
  final ConnectivityController? _connectivity;
  final SyncController? _syncController;

  LoadState _listState = LoadState.idle;
  LoadState _detailState = LoadState.idle;
  LoadState _saveState = LoadState.idle;
  List<CropBatch> _crops = const [];
  CropBatch? _selected;
  String? _filterFarmId;
  String? _errorMessage;
  String? _successMessage;
  bool _servingFromCache = false;

  LoadState get listState => _listState;
  LoadState get detailState => _detailState;
  LoadState get saveState => _saveState;
  List<CropBatch> get crops => _crops;
  CropBatch? get selected => _selected;
  String? get filterFarmId => _filterFarmId;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isSaving => _saveState == LoadState.loading;
  bool get servingFromCache =>
      _servingFromCache || (_syncController?.lastCropReadFromCache ?? false);

  Future<void> loadCrops({String? farmId}) async {
    _filterFarmId = farmId;
    _listState = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getCrops(farmId: farmId);
    result.when(
      success: (crops) {
        _crops = crops;
        _servingFromCache = _syncController?.lastCropReadFromCache ?? false;
        _listState = crops.isEmpty ? LoadState.empty : LoadState.success;
      },
      failure: (error) {
        _errorMessage = ErrorMapper.fromObject(error).message;
        _listState = LoadState.error;
      },
    );
    notifyListeners();
  }

  Future<void> loadCrop(String id) async {
    _detailState = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getCropById(id);
    result.when(
      success: (crop) {
        _selected = crop;
        _servingFromCache = _syncController?.lastCropReadFromCache ?? false;
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

  Future<CropBatch?> createCrop(CropBatchInput input) =>
      _save(() => _repository.createCrop(input));

  Future<CropBatch?> updateCrop(String id, CropBatchInput input) =>
      _save(() => _repository.updateCrop(id, input));

  Future<bool> deleteCrop(String id) async {
    _saveState = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.deleteCrop(id);
    final offline = _connectivity?.isOffline ?? false;
    final ok = result.when(
      success: (_) {
        _successMessage = offline
            ? 'Removed on this device — pending sync.'
            : 'Crop batch removed.';
        return true;
      },
      failure: (error) {
        _errorMessage = ErrorMapper.fromObject(error).message;
        return false;
      },
    );
    _saveState = ok ? LoadState.success : LoadState.error;
    notifyListeners();
    if (ok) await loadCrops(farmId: _filterFarmId);
    return ok;
  }

  Future<CropBatch?> _save(Future<Result<CropBatch>> Function() action) async {
    _saveState = LoadState.loading;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await action();
    final offline = _connectivity?.isOffline ?? false;
    CropBatch? saved;
    result.when(
      success: (crop) {
        saved = crop;
        _selected = crop;
        _successMessage = offline
            ? 'Saved on this device — pending sync when online.'
            : 'Crop batch saved.';
        _saveState = LoadState.success;
      },
      failure: (error) {
        _errorMessage = ErrorMapper.fromObject(error).message;
        _saveState = LoadState.error;
      },
    );
    notifyListeners();
    if (saved != null) await loadCrops(farmId: _filterFarmId);
    return saved;
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
