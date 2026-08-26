import 'package:flutter/foundation.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/utils/load_state.dart';
import '../../../models/crop_passport.dart';
import '../../../services/passport/passport_repository.dart';

class PassportController extends ChangeNotifier {
  PassportController(this._repository);

  final PassportRepository _repository;

  LoadState _listState = LoadState.idle;
  LoadState _detailState = LoadState.idle;
  LoadState _verifyState = LoadState.idle;

  List<CropPassport> _passports = const [];
  PassportDetail? _detail;
  PassportVerificationResult? _verification;
  String? _errorMessage;
  String? _filterCropId;

  LoadState get listState => _listState;
  LoadState get detailState => _detailState;
  LoadState get verifyState => _verifyState;
  List<CropPassport> get passports => _passports;
  PassportDetail? get detail => _detail;
  PassportVerificationResult? get verification => _verification;
  String? get errorMessage => _errorMessage;
  String? get filterCropId => _filterCropId;

  Future<void> loadList({String? cropBatchId}) async {
    _filterCropId = cropBatchId;
    _listState = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.listPassports(cropBatchId: cropBatchId);
    result.when(
      success: (items) {
        _passports = items;
        _listState = items.isEmpty ? LoadState.empty : LoadState.success;
      },
      failure: (error) {
        _errorMessage = ErrorMapper.fromObject(error).message;
        _listState = LoadState.error;
      },
    );
    notifyListeners();
  }

  Future<void> loadDetail(String passportId) async {
    _detailState = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getPassport(passportId);
    result.when(
      success: (detail) {
        _detail = detail;
        _detailState = LoadState.success;
      },
      failure: (error) {
        _errorMessage = ErrorMapper.fromObject(error).message;
        _detailState = LoadState.error;
      },
    );
    notifyListeners();
  }

  Future<void> loadForCrop(String cropBatchId) async {
    _detailState = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getPassportForCrop(cropBatchId);
    result.when(
      success: (detail) {
        _detail = detail;
        _detailState = LoadState.success;
      },
      failure: (error) {
        _errorMessage = ErrorMapper.fromObject(error).message;
        _detailState = LoadState.error;
      },
    );
    notifyListeners();
  }

  Future<void> verify(String code) async {
    _verifyState = LoadState.loading;
    _verification = null;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.verifyCode(code);
    result.when(
      success: (value) {
        _verification = value;
        _verifyState = LoadState.success;
      },
      failure: (error) {
        _errorMessage = ErrorMapper.fromObject(error).message;
        _verifyState = LoadState.error;
      },
    );
    notifyListeners();
  }

  void clearVerification() {
    _verification = null;
    _verifyState = LoadState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
