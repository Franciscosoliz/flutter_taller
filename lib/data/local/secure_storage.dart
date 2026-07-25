// lib/data/local/secure_storage.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Claves con prefijo del taller mecánico
  static const _keyAccess   = 'taller_mecanico_app:access';
  static const _keyRefresh  = 'taller_mecanico_app:refresh';
  static const _keyUserId   = 'taller_mecanico_app:user_id';
  static const _keyUsername = 'taller_mecanico_app:username';
  static const _keyEmail    = 'taller_mecanico_app:email';
  static const _keyIsStaff  = 'taller_mecanico_app:is_staff';
  static const _keyRole     = 'taller_mecanico_app:role';

  // ── Tokens ────────────────────────────────────────────────
  Future<String?> getAccess() => _storage.read(key: _keyAccess);
  Future<String?> getRefresh() => _storage.read(key: _keyRefresh);
  Future<String?> getToken() => getAccess();

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _keyAccess, value: access);
    await _storage.write(key: _keyRefresh, value: refresh);
  }

  Future<void> saveAccessToken(String access) =>
      _storage.write(key: _keyAccess, value: access);

  // ── Usuario y Rol ─────────────────────────────────────────
  Future<void> saveUser({
    required int id,
    required String username,
    required String email,
    required bool isStaff,
    String? rol,
  }) async {
    await _storage.write(key: _keyUserId, value: id.toString());
    await _storage.write(key: _keyUsername, value: username);
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyIsStaff, value: isStaff.toString());
    
    final valorRol = (rol != null && rol.isNotEmpty) 
        ? rol 
        : (isStaff ? 'Administrador' : 'CLIENTE');
        
    await _storage.write(key: _keyRole, value: valorRol);
  }

  Future<Map<String, String>?> getUser() async {
    final id = await _storage.read(key: _keyUserId);
    final username = await _storage.read(key: _keyUsername);
    final email = await _storage.read(key: _keyEmail);
    final isStaff = await _storage.read(key: _keyIsStaff);
    final rol = await _storage.read(key: _keyRole);

    if (id == null || username == null) return null;

    return {
      'user_id': id,
      'username': username,
      'email': email ?? '',
      'is_staff': isStaff ?? 'false',
      'rol': (rol != null && rol.isNotEmpty)
          ? rol
          : ((isStaff == 'true') ? 'Administrador' : 'CLIENTE'),
    };
  }

  Future<String?> getRole() => _storage.read(key: _keyRole);

  Future<bool> isLoggedIn() async {
    final access = await getAccess();
    return access != null && access.isNotEmpty;
  }

  // ── Limpieza de sesión ─────────────────────────────────────
  Future<void> clearSession() => _storage.deleteAll();
  Future<void> clearAll() => clearSession();
}

// Provider global de SecureStorage
final secureStorageProvider = Provider<SecureStorage>((_) => SecureStorage());