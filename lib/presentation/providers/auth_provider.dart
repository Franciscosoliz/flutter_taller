// lib/presentation/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/api_exception.dart';
import '../../data/local/secure_storage.dart';
import '../../data/remote/api/auth_remote_datasource.dart';
import '../../domain/model/auth_models.dart';
import '../../domain/model/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRemoteDatasource _datasource;
  final SecureStorage _storage;

  AuthNotifier(this._datasource, this._storage)
      : super(const AuthState.checking()) {
    restoreSession();
  }

  // Restaurar sesión al iniciar la app desde el SecureStorage
  Future<void> restoreSession() async {
    try {
      final token = await _storage.getAccess();
      if (token == null || token.isEmpty) {
        state = const AuthState.unauthenticated();
        return;
      }

      final userData = await _storage.getUser();
      if (userData == null) {
        state = const AuthState.unauthenticated();
        return;
      }

      final isStaffVal =
          userData['is_staff'] == 'true' || userData['is_staff'] == '1';

      final rolGuardado = userData['rol'] ?? '';

      final user = LoggedUser(
        id: userData['user_id'] is int
            ? userData['user_id'] as int
            : int.parse(userData['user_id'].toString()),
        username: userData['username'].toString(),
        email: userData['email'].toString(),
        isStaff: isStaffVal,
        rol: rolGuardado.isNotEmpty
            ? rolGuardado
            : (isStaffVal ? 'Administrador' : 'CLIENTE'),
      );

      state = AuthState.authenticated(user);
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  // Inicio de sesión consumiendo la API
  Future<void> login(String username, String password) async {
    state = const AuthState.checking();
    try {
      final user = await _datasource.login(username.trim(), password);

      // 🔍 DEBUG: Guardado en SecureStorage
      print('=== 3. GUARDANDO EN SECURE STORAGE ===');
      print('=== Rol a guardar: ${user.rol}');

      await _storage.saveUser(
        id: user.id,
        username: user.username,
        email: user.email,
        isStaff: user.isStaff,
        rol: user.rol, // 👈 Aseguramos que pase el rol
      );

      // Verificar lo que quedó en Storage
      final savedData = await _storage.getUser();
      print('=== 4. LEÍDO DIRECTO DE SECURE STORAGE ===');
      print('=== Storage rol: ${savedData?['rol']}');
      print('==================================================');

      state = AuthState.authenticated(user);
    } on ApiException catch (e) {
      state = AuthState.unauthenticated(e.message);
    } catch (e) {
      state = const AuthState.unauthenticated(
        'Error inesperado al iniciar sesión. Intenta de nuevo.',
      );
    }
  }

  // Registro de nuevo usuario
  Future<void> register(
    String username,
    String email,
    String password,
    String password2,
  ) async {
    state = const AuthState.checking();
    try {
      final user = await _datasource.register(
        username.trim(),
        email.trim(),
        password,
        password2,
      );
      state = AuthState.authenticated(user);
    } on ApiException catch (e) {
      state = AuthState.unauthenticated(e.message);
    } catch (e) {
      state = const AuthState.unauthenticated(
        'Error inesperado al registrarte. Intenta de nuevo.',
      );
    }
  }

  // Cierre de sesión y limpieza de tokens
  Future<void> logout() async {
    try {
      await _datasource.logout();
    } catch (_) {
      // Ignoramos errores de red durante el logout
    } finally {
      await _storage.clearSession();
      state = const AuthState.unauthenticated();
    }
  }

  // Limpiar mensajes de error tras ser consumidos por la UI
  void clearError() {
    if (state.isUnauthenticated && state.error != null) {
      state = const AuthState.unauthenticated();
    }
  }
}

// -----------------------------------------------------------------------------
// PROVIDERS DE RIVERPOD
// -----------------------------------------------------------------------------

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authDatasourceProvider),
    ref.watch(secureStorageProvider),
  );
});

/// Retorna true si el usuario autenticado tiene el flag isStaff o rol Administrador
final isStaffProvider = Provider<bool>((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) return false;

  return user.isAdminOrStaff;
});

/// Retorna el rol del usuario ('Administrador', 'CLIENTE', etc.)
final userRoleProvider = Provider<String>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user?.rol ?? 'CLIENTE';
});
