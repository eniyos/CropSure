enum TreatmentStatus {
  planned,
  inProgress,
  completed,
  cancelled;

  String get displayName => switch (this) {
    TreatmentStatus.planned => 'Planned',
    TreatmentStatus.inProgress => 'In progress',
    TreatmentStatus.completed => 'Completed',
    TreatmentStatus.cancelled => 'Cancelled',
  };

  static TreatmentStatus fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'in_progress':
      case 'in progress':
      case 'inprogress':
        return TreatmentStatus.inProgress;
      case 'completed':
        return TreatmentStatus.completed;
      case 'cancelled':
      case 'canceled':
        return TreatmentStatus.cancelled;
      case 'planned':
      default:
        return TreatmentStatus.planned;
    }
  }
}

class Treatment {
  const Treatment({
    required this.id,
    required this.name,
    required this.date,
    required this.status,
    required this.cropBatchId,
    required this.cropLabel,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final DateTime date;
  final TreatmentStatus status;
  final String cropBatchId;
  final String cropLabel;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Treatment copyWith({
    String? id,
    String? name,
    DateTime? date,
    TreatmentStatus? status,
    String? cropBatchId,
    String? cropLabel,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Treatment(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      status: status ?? this.status,
      cropBatchId: cropBatchId ?? this.cropBatchId,
      cropLabel: cropLabel ?? this.cropLabel,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TreatmentInput {
  const TreatmentInput({
    required this.name,
    required this.date,
    required this.status,
    required this.cropBatchId,
    this.notes,
  });

  final String name;
  final DateTime date;
  final TreatmentStatus status;
  final String cropBatchId;
  final String? notes;
}
