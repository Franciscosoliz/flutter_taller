class Employee {
  final int id;
  final int userId;
  final String userName;
  final String role;
  final String phone;
  final String hireDate;
  final List<dynamic> specialties;
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
    // Extracción robusta del nombre del usuario basado en la estructura de Django
    String extractedUserName = 'Sin Usuario';
    if (json['nombre_completo'] != null) {
      extractedUserName = json['nombre_completo'].toString();
    } else if (json['usuario_nombre'] != null) {
      extractedUserName = json['usuario_nombre'].toString();
    } else if (json['usuario'] is Map) {
      extractedUserName = json['usuario']['nombre_completo'] ?? 
                          json['usuario']['username'] ?? 
                          'Sin Usuario';
    }

    return Employee(
      id: json['id'] ?? 0,
      userId: json['usuario'] is int ? json['usuario'] : (json['usuario']?['id'] ?? 0),
      userName: extractedUserName,
      role: json['cargo'] ?? 'MECANICO',
      phone: json['telefono'] ?? 'N/A',
      hireDate: json['fecha_ingreso'] ?? '',
      specialties: json['especialidades'] ?? [],
      isActive: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario': userId,
      'cargo': role,
      'telefono': phone,
      'fecha_ingreso': hireDate,
      'especialidades': specialties,
      'activo': isActive,
    };
  }
}

class UserOption {
  final int id;
  final String username;
  final String email;
  final String rol;

  UserOption({
    required this.id,
    required this.username,
    required this.email,
    required this.rol,
  });

  factory UserOption.fromJson(Map<String, dynamic> json) {
    return UserOption(
      id: json['id'] ?? 0,
      username: json['username'] ?? json['nombre_completo'] ?? '',
      email: json['email'] ?? '',
      rol: json['rol'] ?? json['role'] ?? '',
    );
  }
}