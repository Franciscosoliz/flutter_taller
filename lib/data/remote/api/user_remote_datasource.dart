// lib/data/remote/api/user_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/api_exception.dart';
import '../../../domain/model/user.dart';
import 'dio_client.dart';

/// Modelo auxiliar para la paginación de usuarios del Taller
class PaginatedUsers {
  final int count;
  final String? next;
  final List<User> results;

  const PaginatedUsers({
    required this.count,
    required this.next,
    required this.results,
  });

  factory PaginatedUsers.fromJson(Map<String, dynamic> j) => PaginatedUsers(
        count: j['count'] as int,
        next: j['next'] as String?,
        results: (j['results'] as List)
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Interfaz para la gestión remota de Usuarios/Personal del Taller
abstract class UserRemoteDatasource {
  Future<PaginatedUsers> getUsers({String? search, bool? isStaff, bool? isActive});
  Future<User> createUser(Map<String, dynamic> payload);
  Future<User> updateUser(int id, Map<String, dynamic> payload);
  Future<void> deleteUser(int id);
  Future<bool> toggleActive(int id);
  Future<Map<String, dynamic>> getStats();
}

class UserRemoteDatasourceImpl implements UserRemoteDatasource {
  final Dio _dio;
  UserRemoteDatasourceImpl(this._dio);

  @override
  Future<PaginatedUsers> getUsers({String? search, bool? isStaff, bool? isActive}) async {
    try {
      final params = <String, dynamic>{
        if (search != null) 'search': search,
        if (isStaff != null) 'is_staff': isStaff,
        if (isActive != null) 'is_active': isActive,
      };
      // Apunta al endpoint de usuarios configurado en el router de Django
      final res = await _dio.get('/usuarios/', queryParameters: params);
      return PaginatedUsers.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<User> createUser(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post('/usuarios/', data: payload);
      return User.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<User> updateUser(int id, Map<String, dynamic> payload) async {
    try {
      final res = await _dio.patch('/usuarios/$id/', data: payload);
      return User.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteUser(int id) async {
    try {
      await _dio.delete('/usuarios/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<bool> toggleActive(int id) async {
    try {
      final res = await _dio.post('/usuarios/$id/toggle-active/');
      return res.data['is_active'] as bool;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    try {
      final res = await _dio.get('/usuarios/stats/');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

// ── Provider Global de Usuarios ───────────────────────────────
final userDatasourceProvider = Provider<UserRemoteDatasource>((ref) {
  return UserRemoteDatasourceImpl(ref.watch(dioProvider));
});