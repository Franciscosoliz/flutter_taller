// lib/domain/model/auth_models.dart

class AuthTokens {
  final String access;
  final String refresh;

  const AuthTokens({
    required this.access,
    required this.refresh,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      access: json['access'] as String? ?? '',
      refresh: json['refresh'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': access,
      'refresh': refresh,
    };
  }
}

class LoggedUser {
  final int id;
  final String username;
  final String email;
  final bool isStaff;
  final String rol;
  final String? accessToken;
  final String? refreshToken;

  const LoggedUser({
    required this.id,
    required this.username,
    required this.email,
    required this.isStaff,
    this.rol = 'CLIENTE',
    this.accessToken,
    this.refreshToken,
  });

  bool get isAdminOrStaff {
    final rolNormalizado = rol.toLowerCase().trim();
    return isStaff ||
        rolNormalizado == 'administrador' ||
        rolNormalizado == 'admin' ||
        rolNormalizado == 'empleado' ||
        rolNormalizado == 'staff';
  }

  // Constructor factory principal para JSON
  factory LoggedUser.fromJson(Map<String, dynamic> json) {
    final isStaffVal = (json['is_staff'] ?? false) == true ||
        json['is_staff'].toString().toLowerCase() == 'true' ||
        json['is_staff'].toString() == '1';

    // Obtención del campo "rol" proveniente de Django
    final String rolDetectado = (json['rol'] ?? json['role'] ?? '').toString();

    return LoggedUser(
      id: json['user_id'] as int? ?? json['id'] as int? ?? 0,
      username: (json['username'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      isStaff: isStaffVal,
      rol: rolDetectado.isNotEmpty
          ? rolDetectado
          : (isStaffVal ? 'Administrador' : 'CLIENTE'),
      accessToken: json['access'] as String?,
      refreshToken: json['refresh'] as String?,
    );
  }

  // Alias para mantener compatibilidad con fromMap
  factory LoggedUser.fromMap(Map<String, dynamic> map) =>
      LoggedUser.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'username': username,
      'email': email,
      'is_staff': isStaff,
      'rol': rol,
      if (accessToken != null) 'access': accessToken,
      if (refreshToken != null) 'refresh': refreshToken,
    };
  }

  // Alias para mantener compatibilidad con toMap
  Map<String, dynamic> toMap() => toJson();
}