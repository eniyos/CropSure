import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/utils/load_state.dart';
import '../../../models/crop_batch.dart';
import '../../../models/disease_analysis.dart';
import '../../../services/crop/crop_repository.dart';
import '../../../services/disease/disease_analysis_repository.dart';

enum AnalysisFlowStep {
  selectCrop,
  selectImage,
  preview,
  analyzing,
  result,
  failed,
}

/// Orchestrates the AI disease analysis UI flow (no local ML).
class DiseaseAnalysisController extends ChangeNotifier {
  DiseaseAnalysisController({
    required DiseaseAnalysisRepository analysisRepository,
    required CropRepository cropRepository,
    ImagePicker? imagePicker,
  }) : _analysisRepository = analysisRepository,
       _cropRepository = cropRepository,
       _imagePicker = imagePicker ?? ImagePicker();

  final DiseaseAnalysisRepository _analysisRepository;
  final CropRepository _cropRepository;
  final ImagePicker _imagePicker;

  AnalysisFlowStep _step = AnalysisFlowStep.selectCrop;
  LoadState _cropsState = LoadState.idle;
  List<CropBatch> _crops = const [];
  CropBatch? _selectedCrop;
  Uint8List? _imageBytes;
  String? _imageName;
  DiseaseAnalysisResult? _result;
  DiseaseProgression? _progression;
  ProgressionHorizon _horizon = ProgressionHorizon.days14;
  LoadState _progressionState = LoadState.idle;
  String? _errorMessage;
  String? _statusMessage;
  bool _busy = false;

  AnalysisFlowStep get step => _step;
  LoadState get cropsState => _cropsState;
  List<CropBatch> get crops => _crops;
  CropBatch? get selectedCrop => _selectedCrop;
  Uint8List? get imageBytes => _imageBytes;
  String? get imageName => _imageName;
  DiseaseAnalysisResult? get result => _result;
  DiseaseProgression? get progression => _progression;
  ProgressionHorizon get horizon => _horizon;
  LoadState get progressionState => _progressionState;
  String? get errorMessage => _errorMessage;
  String? get statusMessage => _statusMessage;
  bool get isBusy => _busy;
  bool get hasImage => _imageBytes != null && _imageBytes!.isNotEmpty;

  Future<void> bootstrap({String? cropId}) async {
    _errorMessage = null;
    _result = null;
    _imageBytes = null;
    _imageName = null;
    _progression = null;
    _statusMessage = null;

    _cropsState = LoadState.loading;
    _step = AnalysisFlowStep.selectCrop;
    notifyListeners();

    final cropsResult = await _cropRepository.getCrops();
    cropsResult.when(
      success: (crops) {
        _crops = crops;
        _cropsState = crops.isEmpty ? LoadState.empty : LoadState.success;
        if (cropId != null) {
          try {
            _selectedCrop = crops.firstWhere((c) => c.id == cropId);
            _step = AnalysisFlowStep.selectImage;
          } on StateError {
            _selectedCrop = null;
          }
        } else if (crops.length == 1) {
          _selectedCrop = crops.first;
          _step = AnalysisFlowStep.selectImage;
        }
      },
      failure: (error) {
        _cropsState = LoadState.error;
        _errorMessage = ErrorMapper.fromObject(error).message;
      },
    );
    notifyListeners();
  }

  void selectCrop(CropBatch crop) {
    _selectedCrop = crop;
    _step = AnalysisFlowStep.selectImage;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> pickFromCamera() => _pick(ImageSource.camera);

  Future<bool> pickFromGallery() => _pick(ImageSource.gallery);

  Future<bool> _pick(ImageSource source) async {
    _errorMessage = null;
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file == null) return false;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        _errorMessage = 'Could not read the selected image. Try another one.';
        notifyListeners();
        return false;
      }
      setPickedImage(bytes, name: file.name);
      return true;
    } on Object catch (error) {
      _errorMessage = ErrorMapper.fromObject(error).message;
      if (source == ImageSource.camera) {
        _errorMessage =
            'Camera is unavailable here. Try choosing an image from the gallery.';
      }
      notifyListeners();
      return false;
    }
  }

  void clearImage() {
    _imageBytes = null;
    _imageName = null;
    _step = AnalysisFlowStep.selectImage;
    notifyListeners();
  }

  /// Applies a picked image (used by camera/gallery and tests).
  void setPickedImage(Uint8List bytes, {String? name}) {
    _imageBytes = bytes;
    _imageName = name;
    _step = AnalysisFlowStep.preview;
    _errorMessage = null;
    notifyListeners();
  }

  void backToImageSelection() {
    _step = AnalysisFlowStep.selectImage;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> confirmAndAnalyze() async {
    final crop = _selectedCrop;
    final bytes = _imageBytes;
    if (crop == null) {
      _errorMessage = 'Select a crop batch before analyzing.';
      notifyListeners();
      return false;
    }
    if (bytes == null || bytes.isEmpty) {
      _errorMessage = 'Select or capture a leaf image first.';
      notifyListeners();
      return false;
    }

    _busy = true;
    _step = AnalysisFlowStep.analyzing;
    _statusMessage = 'Uploading image to the AI service…';
    _errorMessage = null;
    _result = null;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!_busy) return false;
    _statusMessage = 'Running disease analysis…';
    notifyListeners();

    final result = await _analysisRepository.analyzeCropImage(
      cropBatchId: crop.id,
      cropLabel: crop.displayTitle,
      imageBytes: bytes,
      fileName: _imageName,
    );

    return result.when(
      success: (analysis) {
        _result = analysis;
        _progression = analysis.progression;
        _horizon = analysis.progression?.horizon ?? ProgressionHorizon.days14;
        _step = AnalysisFlowStep.result;
        _statusMessage = null;
        _busy = false;
        notifyListeners();
        return true;
      },
      failure: (error) {
        _errorMessage = ErrorMapper.fromObject(error).message;
        _step = AnalysisFlowStep.failed;
        _statusMessage = null;
        _busy = false;
        notifyListeners();
        return false;
      },
    );
  }

  Future<void> retryAnalysis() async {
    if (!hasImage) {
      _step = AnalysisFlowStep.selectImage;
      notifyListeners();
      return;
    }
    await confirmAndAnalyze();
  }

  Future<void> loadProgression(ProgressionHorizon horizon) async {
    final analysis = _result;
    if (analysis == null) return;

    _horizon = horizon;
    _progressionState = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _analysisRepository.getProgression(
      analysisId: analysis.id,
      horizon: horizon,
    );
    result.when(
      success: (progression) {
        _progression = progression;
        _progressionState = LoadState.success;
      },
      failure: (error) {
        _errorMessage = ErrorMapper.fromObject(error).message;
        _progressionState = LoadState.error;
      },
    );
    notifyListeners();
  }

  void resetFlow() {
    _step = _selectedCrop == null
        ? AnalysisFlowStep.selectCrop
        : AnalysisFlowStep.selectImage;
    _imageBytes = null;
    _imageName = null;
    _result = null;
    _progression = null;
    _errorMessage = null;
    _statusMessage = null;
    _busy = false;
    notifyListeners();
  }

  AppException? validateReadyToAnalyze() {
    if (_selectedCrop == null) {
      return const ValidationException('Select a crop batch first.');
    }
    if (!hasImage) {
      return const ValidationException('Select a leaf image first.');
    }
    return null;
  }
}
