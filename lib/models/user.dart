/// Supported platform roles. Mobile Phase 1 focuses on [UserRole.farmer].
enum UserRole {
  farmer,
  agronomist,
  admin,
  inspector,
  unknown;

  static UserRole fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'farmer':
        return UserRole.farmer;
      case 'agronomist':
        return UserRole.agronomist;
      case 'admin':
        return UserRole.admin;
      case 'inspector':
        return UserRole.inspector;
      default:
        return UserRole.unknown;
    }
  }

  String get displayName => switch (this) {
    UserRole.farmer => 'Farmer',
    UserRole.agronomist => 'Agronomist',
    UserRole.admin => 'Admin',
    UserRole.inspector => 'Inspector',
    UserRole.unknown => 'User',
  };

  String get apiValue => name;
}

class User {
  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
  });

  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? phone;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? json['fullName'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String?),
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'role': role.apiValue,
    if (phone != null) 'phone': phone,
  };

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    UserRole? role,
    String? phone,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
    );
  }
}
