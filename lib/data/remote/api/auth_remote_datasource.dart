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
      // 🔄 Cambiado de '/auth/login/' a '/token/'
      final res  = await _dio.post(
        '/token/',
        data: {'username': username, 'password': password},
      );
      final data = res.data as Map<String, dynamic>;
      
      // Guardar Tokens (SimpleJWT devuelve 'access' y 'refresh')
      await _storage.saveTokens(
        data['access'] as String,
        data['refresh'] as String,
      );
      
      // Guardar datos básicos del usuario de forma segura
      await _storage.saveUser(
        id:       data['user_id'] as int? ?? data['id'] as int? ?? 0,
        username: data['username'] as String? ?? username, // Fallback al username ingresado
        email:    data['email']    as String? ?? '',
        isStaff:  data['is_staff'] as bool? ?? false,
      );
      
      return LoggedUser.fromJson(data);
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

      await _storage.saveTokens(
        data['access'] as String,
        data['refresh'] as String,
      );

      await _storage.saveUser(
        id:       data['user_id'] as int? ?? data['id'] as int? ?? 0,
        username: data['username'] as String? ?? username,
        email:    data['email']    as String? ?? email,
        isStaff:  data['is_staff'] as bool? ?? false,
      );

      return LoggedUser.fromJson(data);
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
      // Limpieza local en caso de fallo remoto
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