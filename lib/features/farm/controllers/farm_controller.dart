import 'package:flutter/foundation.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/offline/connectivity_controller.dart';
import '../../../core/utils/load_state.dart';
import '../../../core/utils/result.dart';
import '../../../models/farm.dart';
import '../../../services/farm/farm_repository.dart';
import '../../sync/controllers/sync_controller.dart';

class FarmController extends ChangeNotifier {
  FarmController(
    this._repository, {
    ConnectivityController? connectivity,
    SyncController? syncController,
  })  : _connectivity = connectivity,
        _syncController = syncController;

  final FarmRepository _repository;
  final ConnectivityController? _connectivity;
  final SyncController? _syncController;

  LoadState _listState = LoadState.idle;
  LoadState _detailState = LoadState.idle;
  LoadState _saveState = LoadState.idle;
  List<Farm> _farms = const [];
  Farm? _selected;
  String? _errorMessage;
  String? _successMessage;
  bool _servingFromCache = false;

  LoadState get listState => _listState;
  LoadState get detailState => _detailState;
  LoadState get saveState => _saveState;
  List<Farm> get farms => _farms;
  Farm? get selected => _selected;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isSaving => _saveState == LoadState.loading;
  bool get servingFromCache =>
      _servingFromCache || (_syncController?.lastFarmReadFromCache ?? false);

  Future<void> loadFarms() async {
    _listState = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getFarms();
    result.when(
      success: (farms) {
        _farms = farms;
        _servingFromCache = _syncController?.lastFarmReadFromCache ?? false;
        _listState = farms.isEmpty ? LoadState.empty : LoadState.success;
      },
      failure: (error) {
        _errorMessage = ErrorMapper.fromObject(error).message;
        _listState = LoadState.error;
      },
    );
    notifyListeners();
  }

  Future<void> loadFarm(String id) async {
    _detailState = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getFarmById(id);
    result.when(
      success: (farm) {
        _selected = farm;
        _servingFromCache = _syncController?.lastFarmReadFromCache ?? false;
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

  Future<Farm?> createFarm(FarmInput input) => _save(() => _repository.createFarm(input));

  Future<Farm?> updateFarm(String id, FarmInput input) =>
      _save(() => _repository.updateFarm(id, input));

  Future<bool> deleteFarm(String id) async {
    _saveState = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.deleteFarm(id);
    final offline = _connectivity?.isOffline ?? false;
    final ok = result.when(
      success: (_) {
        _successMessage = offline
            ? 'Removed on this device — pending sync.'
            : 'Farm removed.';
        return true;
      },
      failure: (error) {
        _errorMessage = ErrorMapper.fromObject(error).message;
        return false;
      },
    );
    _saveState = ok ? LoadState.success : LoadState.error;
    notifyListeners();
    if (ok) await loadFarms();
    return ok;
  }

  Future<Farm?> _save(Future<Result<Farm>> Function() action) async {
    _saveState = LoadState.loading;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await action();
    final offline = _connectivity?.isOffline ?? false;
    Farm? saved;
    result.when(
      success: (farm) {
        saved = farm;
        _selected = farm;
        _successMessage = offline
            ? 'Saved on this device — pending sync when online.'
            : 'Farm saved.';
        _saveState = LoadState.success;
      },
      failure: (error) {
        _errorMessage = ErrorMapper.fromObject(error).message;
        _saveState = LoadState.error;
      },
    );
    notifyListeners();
    if (saved != null) await loadFarms();
    return saved;
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
