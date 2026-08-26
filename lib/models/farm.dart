/// Farm entity. Field names stay backend-friendly for later OpenAPI mapping.
class Farm {
  const Farm({
    required this.id,
    required this.name,
    required this.location,
    required this.areaHectares,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String location;
  final double areaHectares;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Farm copyWith({
    String? id,
    String? name,
    String? location,
    double? areaHectares,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Farm(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      areaHectares: areaHectares ?? this.areaHectares,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      areaHectares: (json['area_hectares'] as num?)?.toDouble() ??
          (json['areaHectares'] as num?)?.toDouble() ??
          0,
      notes: json['notes'] as String?,
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'area_hectares': areaHectares,
    if (notes != null) 'notes': notes,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };

  static DateTime? _parseDate(Object? value) {
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }
}

class FarmInput {
  const FarmInput({
    required this.name,
    required this.location,
    required this.areaHectares,
    this.notes,
  });

  final String name;
  final String location;
  final double areaHectares;
  final String? notes;
}
