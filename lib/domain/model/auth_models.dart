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
  final String role;
  final String? accessToken;
  final String? refreshToken;

  const LoggedUser({
    required this.id,
    required this.username,
    required this.email,
    required this.isStaff,
    this.role = 'CLIENTE',
    this.accessToken,
    this.refreshToken,
  });

  // Constructor factory principal para JSON
  factory LoggedUser.fromJson(Map<String, dynamic> json) {
    final isStaffVal = (json['is_staff'] ?? false) == true ||
        json['is_staff'].toString() == 'true';

    return LoggedUser(
      id: json['user_id'] as int? ?? json['id'] as int? ?? 0,
      username: (json['username'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      isStaff: isStaffVal,
      role: json['role']?.toString() ?? (isStaffVal ? 'ADMIN' : 'CLIENTE'),
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
      'role': role,
      if (accessToken != null) 'access': accessToken,
      if (refreshToken != null) 'refresh': refreshToken,
    };
  }

  // Alias para mantener compatibilidad con toMap
  Map<String, dynamic> toMap() => toJson();
}