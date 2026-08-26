import 'package:cropsure/core/offline/connectivity_controller.dart';
import 'package:cropsure/core/utils/load_state.dart';
import 'package:cropsure/core/utils/result.dart';
import 'package:cropsure/features/farm/controllers/farm_controller.dart';
import 'package:cropsure/models/farm.dart';
import 'package:cropsure/services/farm/farm_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryFarmRepository implements FarmRepository {
  final farms = <Farm>[
    const Farm(
      id: 'f1',
      name: 'Test Farm',
      location: 'Nashik',
      areaHectares: 2,
    ),
  ];

  @override
  Future<Result<Farm>> createFarm(FarmInput input) async {
    final farm = Farm(
      id: 'f2',
      name: input.name,
      location: input.location,
      areaHectares: input.areaHectares,
      notes: input.notes,
    );
    farms.add(farm);
    return Success(farm);
  }

  @override
  Future<Result<void>> deleteFarm(String id) async {
    farms.removeWhere((f) => f.id == id);
    return const Success(null);
  }

  @override
  Future<Result<Farm>> getFarmById(String id) async {
    return Success(farms.firstWhere((f) => f.id == id));
  }

  @override
  Future<Result<List<Farm>>> getFarms() async => Success(List.of(farms));

  @override
  Future<Result<Farm>> updateFarm(String id, FarmInput input) async {
    final index = farms.indexWhere((f) => f.id == id);
    final updated = farms[index].copyWith(
      name: input.name,
      location: input.location,
      areaHectares: input.areaHectares,
      notes: input.notes,
    );
    farms[index] = updated;
    return Success(updated);
  }
}

void main() {
  test('FarmController loads farms', () async {
    final controller = FarmController(_MemoryFarmRepository());
    await controller.loadFarms();
    expect(controller.listState, LoadState.success);
    expect(controller.farms, hasLength(1));
  });

  test('FarmController creates farm', () async {
    final controller = FarmController(_MemoryFarmRepository());
    final farm = await controller.createFarm(
      const FarmInput(name: 'New', location: 'Pune', areaHectares: 1.5),
    );
    expect(farm?.name, 'New');
    expect(controller.farms.length, greaterThanOrEqualTo(2));
  });

  test('FarmController offline save message is pending sync', () async {
    final connectivity = ConnectivityController(skipPlatform: true);
    await connectivity.start();
    connectivity.setForceOffline(true);
    final controller = FarmController(
      _MemoryFarmRepository(),
      connectivity: connectivity,
    );
    await controller.createFarm(
      const FarmInput(name: 'Local', location: 'Pune', areaHectares: 1),
    );
    expect(controller.successMessage, contains('pending sync'));
  });
}
