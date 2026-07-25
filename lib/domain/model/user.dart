// lib/domain/model/user.dart

class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String rol; // 👈 Agregado para recibir "Administrador", "Empleado", etc.
  final bool isStaff; // Representa si es Mecánico/Administrador del taller
  final bool isActive;
  final String dateJoined;
  final int numOrders; // Cantidad de órdenes asociadas al usuario

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.rol,
    required this.isStaff,
    required this.isActive,
    required this.dateJoined,
    required this.numOrders,
  });

  /// Getter auxiliar que determina si el usuario tiene permisos administrativos/staff
  bool get isAdminOrStaff {
    final rolNormalizado = rol.toLowerCase().trim();
    return isStaff ||
        rolNormalizado == 'administrador' ||
        rolNormalizado == 'admin' ||
        rolNormalizado == 'empleado';
  }

  factory User.fromJson(Map<String, dynamic> j) {
    // Lectura tolerante de booleanos (acepta bool, int 1/0 o String "true")
    final rawStaff = j['is_staff'] ?? j['isStaff'];
    final parsedStaff = rawStaff == true ||
        rawStaff.toString().toLowerCase() == 'true' ||
        rawStaff.toString() == '1';

    final rawActive = j['is_active'] ?? j['isActive'];
    final parsedActive = rawActive == true ||
        rawActive.toString().toLowerCase() == 'true' ||
        rawActive.toString() == '1';

    return User(
      id: j['id'] ?? 0,
      username: j['username'] ?? '',
      email: j['email'] ?? '',
      firstName: j['first_name'] ?? j['firstName'] ?? '',
      lastName: j['last_name'] ?? j['lastName'] ?? '',
      // Se mapea la clave "rol" recibida de Django (con fallback a "CLIENTE")
      rol: j['rol'] ?? j['role'] ?? 'CLIENTE',
      isStaff: parsedStaff,
      isActive: parsedActive,
      dateJoined: j['date_joined'] ?? j['dateJoined'] ?? '',
      numOrders: j['num_orders'] ?? j['numOrders'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'rol': rol,
        'is_staff': isStaff,
        'is_active': isActive,
        'date_joined': dateJoined,
        'num_orders': numOrders,
      };

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? rol,
    bool? isStaff,
    bool? isActive,
    String? dateJoined,
    int? numOrders,
  }) =>
      User(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        rol: rol ?? this.rol,
        isStaff: isStaff ?? this.isStaff,
        isActive: isActive ?? this.isActive,
        dateJoined: dateJoined ?? this.dateJoined,
        numOrders: numOrders ?? this.numOrders,
      );
}