import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/model/service.dart';
import 'dio_client.dart';

// Helper para parsear la respuesta paginada del backend
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
      results: list
          .map((item) => Service.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ServiceRemoteDatasource {
  final Dio _dio;

  ServiceRemoteDatasource(this._dio);

  /// Obtiene el catálogo de servicios mecánicos
  Future<PaginatedServicesResponse> getServices({
    String? search,
    int? category,
    String? ordering,
    bool? isActive,
    int page = 1,
    int pageSize = 100,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };

    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null) queryParams['category'] = category;
    if (ordering != null && ordering.isNotEmpty) queryParams['ordering'] = ordering;
    if (isActive != null) queryParams['activo'] = isActive;

    final response = await _dio.get(
      '/servicios/',
      queryParameters: queryParams,
    );

    return PaginatedServicesResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Obtiene un servicio individual
  Future<Service> getService(int id) async {
    final response = await _dio.get('/servicios/$id/');
    return Service.fromJson(response.data as Map<String, dynamic>);
  }

  /// Crea un nuevo servicio (Requiere permisos staff)
  /// El payload debe mapear los campos en español que exige la API de Django
  Future<Service> createService(Map<String, dynamic> payload) async {
    final response = await _dio.post('/servicios/', data: payload);
    return Service.fromJson(response.data as Map<String, dynamic>);
  }

  /// Actualiza un servicio existente (Requiere permisos staff)
  Future<Service> updateService(int id, Map<String, dynamic> payload) async {
    final response = await _dio.patch('/servicios/$id/', data: payload);
    return Service.fromJson(response.data as Map<String, dynamic>);
  }

  /// Elimina un servicio (Requiere permisos staff)
  Future<void> deleteService(int id) async {
    await _dio.delete('/servicios/$id/');
  }

  /// Obtiene las categorías
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

final serviceDatasourceProvider = Provider<ServiceRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return ServiceRemoteDatasource(dio);
});