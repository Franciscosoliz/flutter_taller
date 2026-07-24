// lib/data/repositories/work_order_repository_impl.dart
import 'package:dio/dio.dart';

// 1. Ocultamos 'PaginatedWorkOrders' de work_order.dart para evitar el conflicto
import '../../domain/model/work_order.dart' hide PaginatedWorkOrders; 

// 2. Importamos el repositorio (donde ya está definida PaginatedWorkOrders)
import '../../domain/repository/work_order_repository.dart';

class WorkOrderRepositoryImpl implements WorkOrderRepository {
  final Dio _dio;

  WorkOrderRepositoryImpl(this._dio);

  @override
  Future<PaginatedWorkOrders> getWorkOrders({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final int page = (offset / limit).floor() + 1;

      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': limit,
      };

      if (status != null && status.isNotEmpty) {
        queryParameters['estado'] = status;
      }

      final response = await _dio.get(
        '/ordenes-trabajo/',
        queryParameters: queryParameters,
      );

      final data = response.data as Map<String, dynamic>;

      final List rawResults = data['results'] as List? ?? [];
      final List<WorkOrder> items = rawResults
          .map((json) => WorkOrder.fromJson(json as Map<String, dynamic>))
          .toList();

      return PaginatedWorkOrders(
        items: items,
        total: data['count'] as int? ?? items.length,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Error al obtener la lista de órdenes: $e');
    }
  }

  @override
  Future<WorkOrder> getWorkOrderById(int id) async {
    try {
      final response = await _dio.get('/ordenes-trabajo/$id/');

      return WorkOrder.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Error al cargar el detalle de la orden #$id: $e');
    }
  }

  @override
  Future<WorkOrder> updateOrderStatus(int id, WorkOrderStatus newStatus) async {
    try {
      final response = await _dio.patch(
        '/ordenes-trabajo/$id/',
        data: {'estado': newStatus.name},
      );

      return WorkOrder.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Error al actualizar el estado de la orden #$id: $e');
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('detail')) {
        return Exception(data['detail']);
      }
      return Exception('Error en el servidor (${e.response?.statusCode})');
    }
    return Exception('Error de conexión. Revisa tu red.');
  }
}