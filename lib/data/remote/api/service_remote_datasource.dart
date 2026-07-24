import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/model/service.dart';
import 'dio_client.dart';

// Modelo helper para manejar las respuestas paginadas del backend
class PaginatedServicesResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Service> results;

  const PaginatedServicesResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedServicesResponse.fromJson(Map<String, dynamic> json) {
    final list = json['results'] as List<dynamic>? ?? [];
    return PaginatedServicesResponse(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: list.map((item) => Service.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }
}

class ServiceRemoteDatasource {
  final Dio _dio;

  ServiceRemoteDatasource(this._dio);

  /// Obtiene el catálogo de servicios mecánicos con filtros opcionales
  Future<PaginatedServicesResponse> getServices({
    String? search,
    int? category,
    String? ordering,
    bool? isActive,
    int page = 1,
    int pageSize = 100, // Tamaño grande para vista de administración
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };

    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null) queryParams['category'] = category;
    if (ordering != null && ordering.isNotEmpty) queryParams['ordering'] = ordering;
    if (isActive != null) queryParams['is_active'] = isActive;

    final response = await _dio.get(
      '/servicios/',
      queryParameters: queryParams,
    );

    return PaginatedServicesResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Obtiene la información detallada de un servicio mecánico por su ID
  Future<Service> getService(int id) async {
    final response = await _dio.get('/servicios/$id/');
    return Service.fromJson(response.data as Map<String, dynamic>);
  }

  /// Crea un nuevo servicio mecánico
  Future<Service> createService(Map<String, dynamic> payload) async {
    final response = await _dio.post('/servicios/', data: payload);
    return Service.fromJson(response.data as Map<String, dynamic>);
  }

  /// Actualiza un servicio mecánico existente (PATCH parcial)
  Future<Service> updateService(int id, Map<String, dynamic> payload) async {
    final response = await _dio.patch('/servicios/$id/', data: payload);
    return Service.fromJson(response.data as Map<String, dynamic>);
  }

  /// Elimina un servicio por su ID
  Future<void> deleteService(int id) async {
    await _dio.delete('/servicios/$id/');
  }

  /// Obtiene el listado de categorías / especialidades del taller
  Future<List<ServiceCategory>> getCategories() async {
    final response = await _dio.get('/categories/');
    final List<dynamic> data = response.data is List
        ? response.data as List
        : (response.data['results'] as List<dynamic>? ?? []);

    return data
        .map((item) => ServiceCategory.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

// Provider de Riverpod para inyectar la fuente de datos remota
final serviceDatasourceProvider = Provider<ServiceRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return ServiceRemoteDatasource(dio);
});