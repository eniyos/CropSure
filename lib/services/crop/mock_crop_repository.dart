import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../models/crop_batch.dart';
import '../farm/farm_repository.dart';
import 'crop_repository.dart';

/// In-memory crop batches for UI development.
class MockCropRepository implements CropRepository {
  MockCropRepository(this._farmRepository) {
    _crops = [
      CropBatch(
        id: 'crop-001',
        farmId: 'farm-001',
        farmName: 'Green Valley Farm',
        cropType: 'Tomato',
        variety: 'Hybrid 61',
        plantingDate: DateTime.now().subtract(const Duration(days: 55)),
        growthStage: GrowthStage.fruiting,
        healthStatus: CropHealthStatus.watch,
        areaHectares: 1.2,
        trustScore: 78,
        notes: 'North block near irrigation line.',
        createdAt: DateTime.now().subtract(const Duration(days: 55)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CropBatch(
        id: 'crop-002',
        farmId: 'farm-001',
        farmName: 'Green Valley Farm',
        cropType: 'Grape',
        variety: 'Thompson Seedless',
        plantingDate: DateTime.now().subtract(const Duration(days: 200)),
        growthStage: GrowthStage.flowering,
        healthStatus: CropHealthStatus.healthy,
        areaHectares: 2.0,
        trustScore: 86,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      CropBatch(
        id: 'crop-003',
        farmId: 'farm-002',
        farmName: 'Riverbend Fields',
        cropType: 'Spinach',
        variety: 'All Green',
        plantingDate: DateTime.now().subtract(const Duration(days: 28)),
        growthStage: GrowthStage.vegetative,
        healthStatus: CropHealthStatus.atRisk,
        areaHectares: 0.8,
        trustScore: 64,
        notes: 'Leaf spotting observed last week.',
        createdAt: DateTime.now().subtract(const Duration(days: 28)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 18)),
      ),
    ];
  }

  final FarmRepository _farmRepository;
  late List<CropBatch> _crops;
  static const _delay = Duration(milliseconds: 450);

  @override
  Future<Result<List<CropBatch>>> getCrops({String? farmId}) async {
    await Future<void>.delayed(_delay);
    final filtered = farmId == null
        ? _crops
        : _crops.where((crop) => crop.farmId == farmId).toList();
    return Success(List.unmodifiable(filtered));
  }

  @override
  Future<Result<CropBatch>> getCropById(String id) async {
    await Future<void>.delayed(_delay);
    try {
      return Success(_crops.firstWhere((crop) => crop.id == id));
    } on StateError {
      return const Failure(NotFoundException('Crop batch not found.'));
    }
  }

  @override
  Future<Result<CropBatch>> createCrop(CropBatchInput input) async {
    await Future<void>.delayed(_delay);
    final validation = _validate(input);
    if (validation != null) return Failure(validation);

    final farmResult = await _farmRepository.getFarmById(input.farmId);
    final farm = farmResult.valueOrNull;
    if (farm == null) {
      return const Failure(ValidationException('Select a valid farm.'));
    }

    final crop = CropBatch(
      id: 'crop-${DateTime.now().millisecondsSinceEpoch}',
      farmId: farm.id,
      farmName: farm.name,
      cropType: input.cropType.trim(),
      variety: input.variety.trim(),
      plantingDate: input.plantingDate,
      growthStage: input.growthStage,
      healthStatus: CropHealthStatus.healthy,
      areaHectares: input.areaHectares,
      notes: input.notes?.trim(),
      trustScore: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _crops = [..._crops, crop];
    return Success(crop);
  }

  @override
  Future<Result<CropBatch>> updateCrop(String id, CropBatchInput input) async {
    await Future<void>.delayed(_delay);
    final validation = _validate(input);
    if (validation != null) return Failure(validation);

    final index = _crops.indexWhere((crop) => crop.id == id);
    if (index < 0) {
      return const Failure(NotFoundException('Crop batch not found.'));
    }

    final farmResult = await _farmRepository.getFarmById(input.farmId);
    final farm = farmResult.valueOrNull;
    if (farm == null) {
      return const Failure(ValidationException('Select a valid farm.'));
    }

    final existing = _crops[index];
    final updated = existing.copyWith(
      farmId: farm.id,
      farmName: farm.name,
      cropType: input.cropType.trim(),
      variety: input.variety.trim(),
      plantingDate: input.plantingDate,
      growthStage: input.growthStage,
      areaHectares: input.areaHectares,
      notes: input.notes?.trim(),
      updatedAt: DateTime.now(),
    );
    _crops = [..._crops]..[index] = updated;
    return Success(updated);
  }

  @override
  Future<Result<void>> deleteCrop(String id) async {
    await Future<void>.delayed(_delay);
    final before = _crops.length;
    _crops = _crops.where((crop) => crop.id != id).toList();
    if (_crops.length == before) {
      return const Failure(NotFoundException('Crop batch not found.'));
    }
    return const Success(null);
  }

  AppException? _validate(CropBatchInput input) {
    if (input.farmId.trim().isEmpty) {
      return const ValidationException('Farm is required.');
    }
    if (input.cropType.trim().isEmpty) {
      return const ValidationException('Crop type is required.');
    }
    if (input.variety.trim().isEmpty) {
      return const ValidationException('Variety is required.');
    }
    if (input.areaHectares != null && input.areaHectares! <= 0) {
      return const ValidationException('Area must be greater than zero.');
    }
    return null;
  }
}
