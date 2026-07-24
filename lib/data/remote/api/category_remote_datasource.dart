// lib/data/remote/api/category_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/api_exception.dart';
import '../../../domain/model/category.dart';
import 'dio_client.dart';

/// Interfaz para el manejo remoto de los Servicios del Taller
/// (ej. Cambio de Aceite, Sistema de Frenos, Alineación y Balanceo)
abstract class CategoryRemoteDatasource {
  Future<List<Category>> getCategories();
  Future<Category>       getCategory(int id);
  Future<Category>       createCategory(Map<String, dynamic> payload);
  Future<Category>       updateCategory(int id, Map<String, dynamic> payload);
  Future<void>           deleteCategory(int id);
  Future<Map<String, dynamic>> getStats();
}

class CategoryRemoteDatasourceImpl implements CategoryRemoteDatasource {
  final Dio _dio;
  CategoryRemoteDatasourceImpl(this._dio);

  @override
  Future<List<Category>> getCategories() async {
    try {
      final res = await _dio.get('/servicios/');
      
      // Maneja si Django retorna una lista directa o paginada en 'results'
      if (res.data is List) {
        return (res.data as List)
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      final data = res.data as Map<String, dynamic>;
      final results = data['results'] as List;
      return results
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Category> getCategory(int id) async {
    try {
      final res = await _dio.get('/servicios/$id/');
      return Category.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Category> createCategory(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post('/servicios/', data: payload);
      return Category.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Category> updateCategory(int id, Map<String, dynamic> payload) async {
    try {
      final res = await _dio.patch('/servicios/$id/', data: payload);
      return Category.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      await _dio.delete('/servicios/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    try {
      final res = await _dio.get('/servicios/stats/');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

// ── Provider Global para los Servicios del Taller ─────────────
final categoryDatasourceProvider = Provider<CategoryRemoteDatasource>((ref) {
  return CategoryRemoteDatasourceImpl(ref.watch(dioProvider));
});