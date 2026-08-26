/// Pending write queued while offline for later sync.
enum SyncOperationType {
  createFarm,
  updateFarm,
  deleteFarm,
  createCrop,
  updateCrop,
  deleteCrop,
}

enum SyncOperationStatus {
  pending,
  syncing,
  failed,
  synced,
}

class SyncOperation {
  const SyncOperation({
    required this.id,
    required this.type,
    required this.status,
    required this.createdAt,
    this.entityId,
    this.label,
    this.payload,
    this.errorMessage,
    this.completedAt,
  });

  final String id;
  final SyncOperationType type;
  final SyncOperationStatus status;
  final DateTime createdAt;
  final String? entityId;
  final String? label;
  final Map<String, dynamic>? payload;
  final String? errorMessage;
  final DateTime? completedAt;

  SyncOperation copyWith({
    SyncOperationStatus? status,
    String? errorMessage,
    DateTime? completedAt,
  }) {
    return SyncOperation(
      id: id,
      type: type,
      status: status ?? this.status,
      createdAt: createdAt,
      entityId: entityId,
      label: label,
      payload: payload,
      errorMessage: errorMessage ?? this.errorMessage,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String? ?? '',
      type: SyncOperationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => SyncOperationType.updateFarm,
      ),
      status: SyncOperationStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => SyncOperationStatus.pending,
      ),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      entityId: json['entity_id'] as String?,
      label: json['label'] as String?,
      payload: (json['payload'] as Map?)?.cast<String, dynamic>(),
      errorMessage: json['error_message'] as String?,
      completedAt: DateTime.tryParse(json['completed_at'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
        if (entityId != null) 'entity_id': entityId,
        if (label != null) 'label': label,
        if (payload != null) 'payload': payload,
        if (errorMessage != null) 'error_message': errorMessage,
        if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      };

  String get typeLabel => switch (type) {
        SyncOperationType.createFarm => 'Create farm',
        SyncOperationType.updateFarm => 'Update farm',
        SyncOperationType.deleteFarm => 'Delete farm',
        SyncOperationType.createCrop => 'Create crop',
        SyncOperationType.updateCrop => 'Update crop',
        SyncOperationType.deleteCrop => 'Delete crop',
      };

  String get statusLabel => switch (status) {
        SyncOperationStatus.pending => 'Pending sync',
        SyncOperationStatus.syncing => 'Syncing…',
        SyncOperationStatus.failed => 'Sync failed',
        SyncOperationStatus.synced => 'Synced',
      };
}
