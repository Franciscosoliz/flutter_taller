// lib/data/remote/api/auth_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/api_exception.dart';
import '../../../domain/model/auth_models.dart';
import '../../local/secure_storage.dart';
import 'dio_client.dart';

abstract class AuthRemoteDatasource {
  Future<LoggedUser> login(String username, String password);
  Future<LoggedUser> register(String username, String email, String password, String password2);
  Future<void>       logout();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio           _dio;
  final SecureStorage _storage;

  AuthRemoteDatasourceImpl(this._dio, this._storage);

  @override
  Future<LoggedUser> login(String username, String password) async {
    try {
      final res = await _dio.post(
        '/token/',
        data: {'username': username, 'password': password},
      );
      final data = res.data as Map<String, dynamic>;

      // 1. Guardar Tokens recibidos desde SimpleJWT
      final access = data['access'] as String? ?? '';
      final refresh = data['refresh'] as String? ?? '';
      await _storage.saveTokens(access, refresh);

      // 2. Determinar si es usuario administrador por el username ingresado
      final String cleanUsername = (data['username'] as String? ?? username).trim();
      final bool esAdmin = cleanUsername.toLowerCase() == 'taller' || 
                           cleanUsername.toLowerCase() == 'admin';

      // Parseo flexible por si en algún momento el backend llega a mandar el campo
      final rawStaff = data['is_staff'] ?? data['isStaff'];
      final bool isStaffVal = esAdmin ||
          rawStaff == true ||
          rawStaff.toString().toLowerCase() == 'true' ||
          rawStaff.toString() == '1';

      final userId = data['user_id'] is int
          ? data['user_id'] as int
          : int.tryParse(data['user_id']?.toString() ?? '') ?? 1;

      final String rolDetectado = (data['rol'] ?? data['role'] ?? '').toString();
      final String rolFinal = rolDetectado.isNotEmpty 
          ? rolDetectado 
          : (esAdmin ? 'Administrador' : 'CLIENTE');

      // 3. Guardar en almacenamiento seguro
      await _storage.saveUser(
        id: userId,
        username: cleanUsername,
        email: data['email'] as String? ?? '',
        isStaff: isStaffVal,
        rol: rolFinal,
      );

      // 4. Mapear objeto LoggedUser para el AuthNotifier
      final Map<String, dynamic> userPayload = {
        'id': userId,
        'user_id': userId,
        'username': cleanUsername,
        'email': data['email'] as String? ?? '',
        'is_staff': isStaffVal,
        'rol': rolFinal,
        'access': access,
        'refresh': refresh,
      };

      final user = LoggedUser.fromJson(userPayload);

      print('==================================================');
      print('=== LOGIN EXITOSO CON REGLA DE USUARIO ===');
      print('=== Username: ${user.username}');
      print('=== IsStaff: ${user.isStaff}');
      print('=== Rol: ${user.rol}');
      print('=== IsAdminOrStaff: ${user.isAdminOrStaff}');
      print('==================================================');

      return user;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<LoggedUser> register(
    String username,
    String email,
    String password,
    String password2,
  ) async {
    try {
      final res = await _dio.post(
        '/auth/register/',
        data: {
          'username':  username,
          'email':     email,
          'password':  password,
          'password2': password2,
        },
      );
      final data = res.data as Map<String, dynamic>;

      final access = data['access'] as String? ?? '';
      final refresh = data['refresh'] as String? ?? '';
      await _storage.saveTokens(access, refresh);

      final String cleanUsername = (data['username'] as String? ?? username).trim();

      await _storage.saveUser(
        id: 0,
        username: cleanUsername,
        email: email,
        isStaff: false,
        rol: 'CLIENTE',
      );

      final Map<String, dynamic> userPayload = {
        'id': 0,
        'username': cleanUsername,
        'email': email,
        'is_staff': false,
        'rol': 'CLIENTE',
        'access': access,
        'refresh': refresh,
      };

      return LoggedUser.fromJson(userPayload);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      final refresh = await _storage.getRefresh();
      if (refresh != null && refresh.isNotEmpty) {
        await _dio.post('/token/verify/', data: {'token': refresh});
      }
    } catch (_) {
      // Limpieza local en caso de fallo de red
    } finally {
      await _storage.clearSession();
    }
  }
}

final authDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasourceImpl(
    ref.watch(dioProvider),
    ref.watch(secureStorageProvider),
  );
});