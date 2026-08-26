import 'package:cropsure/core/utils/load_state.dart';
import 'package:cropsure/core/utils/result.dart';
import 'package:cropsure/features/crop/controllers/crop_controller.dart';
import 'package:cropsure/models/crop_batch.dart';
import 'package:cropsure/services/crop/crop_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryCropRepository implements CropRepository {
  final crops = <CropBatch>[
    CropBatch(
      id: 'c1',
      farmId: 'f1',
      farmName: 'Farm',
      cropType: 'Tomato',
      variety: 'Hybrid',
      plantingDate: DateTime(2026, 1, 1),
      growthStage: GrowthStage.vegetative,
      healthStatus: CropHealthStatus.healthy,
    ),
  ];

  @override
  Future<Result<CropBatch>> createCrop(CropBatchInput input) async {
    final crop = CropBatch(
      id: 'c2',
      farmId: input.farmId,
      farmName: 'Farm',
      cropType: input.cropType,
      variety: input.variety,
      plantingDate: input.plantingDate,
      growthStage: input.growthStage,
    );
    crops.add(crop);
    return Success(crop);
  }

  @override
  Future<Result<void>> deleteCrop(String id) async {
    crops.removeWhere((c) => c.id == id);
    return const Success(null);
  }

  @override
  Future<Result<CropBatch>> getCropById(String id) async =>
      Success(crops.firstWhere((c) => c.id == id));

  @override
  Future<Result<List<CropBatch>>> getCrops({String? farmId}) async =>
      Success(List.of(crops));

  @override
  Future<Result<CropBatch>> updateCrop(String id, CropBatchInput input) async {
    final index = crops.indexWhere((c) => c.id == id);
    final updated = crops[index].copyWith(
      cropType: input.cropType,
      variety: input.variety,
      growthStage: input.growthStage,
    );
    crops[index] = updated;
    return Success(updated);
  }
}

void main() {
  test('CropController loads crops', () async {
    final controller = CropController(_MemoryCropRepository());
    await controller.loadCrops();
    expect(controller.listState, LoadState.success);
    expect(controller.crops.first.cropType, 'Tomato');
  });
}
