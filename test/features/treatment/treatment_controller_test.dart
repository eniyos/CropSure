import 'package:cropsure/core/utils/load_state.dart';
import 'package:cropsure/core/utils/result.dart';
import 'package:cropsure/features/treatment/controllers/treatment_controller.dart';
import 'package:cropsure/models/treatment.dart';
import 'package:cropsure/services/treatment/treatment_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryTreatmentRepository implements TreatmentRepository {
  final items = <Treatment>[
    Treatment(
      id: 't1',
      name: 'Fungicide',
      date: DateTime(2026, 8, 20),
      status: TreatmentStatus.completed,
      cropBatchId: 'c1',
      cropLabel: 'Tomato · Hybrid 61',
    ),
  ];

  @override
  Future<Result<Treatment>> createTreatment(TreatmentInput input) async {
    final item = Treatment(
      id: 't2',
      name: input.name,
      date: input.date,
      status: input.status,
      cropBatchId: input.cropBatchId,
      cropLabel: 'Tomato · Hybrid 61',
      notes: input.notes,
    );
    items.add(item);
    return Success(item);
  }

  @override
  Future<Result<void>> deleteTreatment(String id) async {
    items.removeWhere((t) => t.id == id);
    return const Success(null);
  }

  @override
  Future<Result<Treatment>> getTreatmentById(String id) async =>
      Success(items.firstWhere((t) => t.id == id));

  @override
  Future<Result<List<Treatment>>> getTreatments({String? cropBatchId}) async =>
      Success(List.of(items));

  @override
  Future<Result<Treatment>> updateTreatment(
    String id,
    TreatmentInput input,
  ) async {
    final index = items.indexWhere((t) => t.id == id);
    final updated = items[index].copyWith(
      name: input.name,
      status: input.status,
    );
    items[index] = updated;
    return Success(updated);
  }
}

void main() {
  test('TreatmentController loads list', () async {
    final controller = TreatmentController(_MemoryTreatmentRepository());
    await controller.loadTreatments();
    expect(controller.listState, LoadState.success);
    expect(controller.treatments.first.name, 'Fungicide');
  });

  test('TreatmentController creates treatment', () async {
    final controller = TreatmentController(_MemoryTreatmentRepository());
    final saved = await controller.createTreatment(
      TreatmentInput(
        name: 'Neem oil',
        date: DateTime(2026, 8, 25),
        status: TreatmentStatus.planned,
        cropBatchId: 'c1',
      ),
    );
    expect(saved?.name, 'Neem oil');
    expect(controller.treatments.length, greaterThanOrEqualTo(2));
  });
}
