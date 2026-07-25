// domain/model/employee.dart

class UserOption {
  final int id;
  final String username;
  final String fullName;

  UserOption({
    required this.id,
    required this.username,
    required this.fullName,
  });

  factory UserOption.fromJson(Map<String, dynamic> json) {
    return UserOption(
      id: json['id'],
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? json['username'] ?? '',
    );
  }
}

class Employee {
  final int id;
  final int userId;
  final String userName;
  final String role; // Administrador, Recepcionista, Mecánico, Supervisor
  final String phone;
  final DateTime hireDate;
  final List<String> specialties;
  final bool isActive;

  Employee({
    required this.id,
    required this.userId,
    required this.userName,
    required this.role,
    required this.phone,
    required this.hireDate,
    required this.specialties,
    required this.isActive,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      userId: json['user_id'] ?? json['user']?['id'] ?? 0,
      userName: json['user_name'] ?? json['user']?['username'] ?? 'Sin Usuario',
      role: json['role'] ?? 'Mecánico',
      phone: json['phone'] ?? '',
      hireDate: DateTime.tryParse(json['hire_date'] ?? '') ?? DateTime.now(),
      specialties: List<String>.from(json['specialties'] ?? []),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'role': role,
      'phone': phone,
      'hire_date': hireDate.toIso8601String().split('T')[0],
      'specialties': specialties,
      'is_active': isActive,
    };
  }
}