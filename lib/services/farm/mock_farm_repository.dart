import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../models/farm.dart';
import 'farm_repository.dart';

/// In-memory farm data for UI development. Swap for Dio when OpenAPI is ready.
class MockFarmRepository implements FarmRepository {
  MockFarmRepository() {
    _farms = [
      Farm(
        id: 'farm-001',
        name: 'Green Valley Farm',
        location: 'Nashik, Maharashtra',
        areaHectares: 4.5,
        notes: 'Primary tomato and grape plots.',
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Farm(
        id: 'farm-002',
        name: 'Riverbend Fields',
        location: 'Pune, Maharashtra',
        areaHectares: 2.2,
        notes: 'Seasonal leafy greens.',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
    ];
  }

  late List<Farm> _farms;
  static const _delay = Duration(milliseconds: 450);

  @override
  Future<Result<List<Farm>>> getFarms() async {
    await Future<void>.delayed(_delay);
    return Success(List.unmodifiable(_farms));
  }

  @override
  Future<Result<Farm>> getFarmById(String id) async {
    await Future<void>.delayed(_delay);
    try {
      return Success(_farms.firstWhere((farm) => farm.id == id));
    } on StateError {
      return const Failure(NotFoundException('Farm not found.'));
    }
  }

  @override
  Future<Result<Farm>> createFarm(FarmInput input) async {
    await Future<void>.delayed(_delay);
    final validation = _validate(input);
    if (validation != null) return Failure(validation);

    final farm = Farm(
      id: 'farm-${DateTime.now().millisecondsSinceEpoch}',
      name: input.name.trim(),
      location: input.location.trim(),
      areaHectares: input.areaHectares,
      notes: input.notes?.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _farms = [..._farms, farm];
    return Success(farm);
  }

  @override
  Future<Result<Farm>> updateFarm(String id, FarmInput input) async {
    await Future<void>.delayed(_delay);
    final validation = _validate(input);
    if (validation != null) return Failure(validation);

    final index = _farms.indexWhere((farm) => farm.id == id);
    if (index < 0) {
      return const Failure(NotFoundException('Farm not found.'));
    }

    final updated = _farms[index].copyWith(
      name: input.name.trim(),
      location: input.location.trim(),
      areaHectares: input.areaHectares,
      notes: input.notes?.trim(),
      updatedAt: DateTime.now(),
    );
    _farms = [..._farms]..[index] = updated;
    return Success(updated);
  }

  @override
  Future<Result<void>> deleteFarm(String id) async {
    await Future<void>.delayed(_delay);
    final before = _farms.length;
    _farms = _farms.where((farm) => farm.id != id).toList();
    if (_farms.length == before) {
      return const Failure(NotFoundException('Farm not found.'));
    }
    return const Success(null);
  }

  AppException? _validate(FarmInput input) {
    if (input.name.trim().isEmpty) {
      return const ValidationException('Farm name is required.');
    }
    if (input.location.trim().isEmpty) {
      return const ValidationException('Location is required.');
    }
    if (input.areaHectares <= 0) {
      return const ValidationException('Area must be greater than zero.');
    }
    return null;
  }
}
