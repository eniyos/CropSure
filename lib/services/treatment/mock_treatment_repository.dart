import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../models/treatment.dart';
import '../crop/crop_repository.dart';
import 'treatment_repository.dart';

class MockTreatmentRepository implements TreatmentRepository {
  MockTreatmentRepository(this._cropRepository) {
    _items = [
      Treatment(
        id: 'trt-001',
        name: 'Copper fungicide spray',
        date: DateTime.now().subtract(const Duration(days: 6)),
        status: TreatmentStatus.completed,
        cropBatchId: 'crop-001',
        cropLabel: 'Tomato · Hybrid 61',
        notes: 'Applied early morning on north block.',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        updatedAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      Treatment(
        id: 'trt-002',
        name: 'Neem oil follow-up',
        date: DateTime.now().add(const Duration(days: 2)),
        status: TreatmentStatus.planned,
        cropBatchId: 'crop-001',
        cropLabel: 'Tomato · Hybrid 61',
        notes: 'Scheduled after disease alert.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Treatment(
        id: 'trt-003',
        name: 'Foliar nutrient boost',
        date: DateTime.now().subtract(const Duration(days: 12)),
        status: TreatmentStatus.completed,
        cropBatchId: 'crop-003',
        cropLabel: 'Spinach · All Green',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        updatedAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
    ];
  }

  final CropRepository _cropRepository;
  late List<Treatment> _items;
  static const _delay = Duration(milliseconds: 450);

  @override
  Future<Result<List<Treatment>>> getTreatments({String? cropBatchId}) async {
    await Future<void>.delayed(_delay);
    final filtered = cropBatchId == null
        ? _items
        : _items.where((t) => t.cropBatchId == cropBatchId).toList();
    final sorted = [...filtered]
      ..sort((a, b) => b.date.compareTo(a.date));
    return Success(List.unmodifiable(sorted));
  }

  @override
  Future<Result<Treatment>> getTreatmentById(String id) async {
    await Future<void>.delayed(_delay);
    try {
      return Success(_items.firstWhere((t) => t.id == id));
    } on StateError {
      return const Failure(NotFoundException('Treatment not found.'));
    }
  }

  @override
  Future<Result<Treatment>> createTreatment(TreatmentInput input) async {
    await Future<void>.delayed(_delay);
    final validation = _validate(input);
    if (validation != null) return Failure(validation);

    final cropResult = await _cropRepository.getCropById(input.cropBatchId);
    final crop = cropResult.valueOrNull;
    if (crop == null) {
      return const Failure(ValidationException('Select a valid crop batch.'));
    }

    final treatment = Treatment(
      id: 'trt-${DateTime.now().millisecondsSinceEpoch}',
      name: input.name.trim(),
      date: input.date,
      status: input.status,
      cropBatchId: crop.id,
      cropLabel: crop.displayTitle,
      notes: input.notes?.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _items = [..._items, treatment];
    return Success(treatment);
  }

  @override
  Future<Result<Treatment>> updateTreatment(
    String id,
    TreatmentInput input,
  ) async {
    await Future<void>.delayed(_delay);
    final validation = _validate(input);
    if (validation != null) return Failure(validation);

    final index = _items.indexWhere((t) => t.id == id);
    if (index < 0) {
      return const Failure(NotFoundException('Treatment not found.'));
    }

    final cropResult = await _cropRepository.getCropById(input.cropBatchId);
    final crop = cropResult.valueOrNull;
    if (crop == null) {
      return const Failure(ValidationException('Select a valid crop batch.'));
    }

    final updated = _items[index].copyWith(
      name: input.name.trim(),
      date: input.date,
      status: input.status,
      cropBatchId: crop.id,
      cropLabel: crop.displayTitle,
      notes: input.notes?.trim(),
      updatedAt: DateTime.now(),
    );
    _items = [..._items]..[index] = updated;
    return Success(updated);
  }

  @override
  Future<Result<void>> deleteTreatment(String id) async {
    await Future<void>.delayed(_delay);
    final before = _items.length;
    _items = _items.where((t) => t.id != id).toList();
    if (_items.length == before) {
      return const Failure(NotFoundException('Treatment not found.'));
    }
    return const Success(null);
  }

  AppException? _validate(TreatmentInput input) {
    if (input.name.trim().isEmpty) {
      return const ValidationException('Treatment name is required.');
    }
    if (input.cropBatchId.trim().isEmpty) {
      return const ValidationException('Crop batch is required.');
    }
    return null;
  }
}
