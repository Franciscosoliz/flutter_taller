// lib/data/remote/api/order_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/api_exception.dart';
import '../../../domain/model/work_order.dart';
import 'dio_client.dart';

/// Interfaz para la gestión remota de las Órdenes de Trabajo del Taller Mecánico
abstract class OrderRemoteDatasource {
  Future<PaginatedWorkOrders>      getOrders({int? page, String? status});
  Future<WorkOrder>            getWorkOrder(int id);
  Future<WorkOrder>            createWorkOrder();
  Future<WorkOrder>            addItem(int workOrderId, int serviceId, int quantity);
  Future<WorkOrder>            confirmWorkOrder(int workOrderId);
  Future<WorkOrder>            updateStatus(int workOrderId, String status);
  Future<Map<String, dynamic>> getStats();
}

class OrderRemoteDatasourceImpl implements OrderRemoteDatasource {
  final Dio _dio;
  OrderRemoteDatasourceImpl(this._dio);

  @override
  Future<PaginatedWorkOrders> getOrders({int? page, String? status}) async {
    try {
      final params = <String, dynamic>{
        if (page   != null) 'page':   page,
        if (status != null) 'status': status,
      };
      // Endpoint que mapea a "Órdenes de trabajo" en tu backend
      final res = await _dio.get('/ordenes-trabajo/', queryParameters: params);
      return PaginatedWorkOrders.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<WorkOrder> getWorkOrder(int id) async {
    try {
      final res = await _dio.get('/ordenes-trabajo/$id/');
      return WorkOrder.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<WorkOrder> createWorkOrder() async {
    try {
      final res = await _dio.post('/ordenes-trabajo/', data: {});
      return WorkOrder.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<WorkOrder> addItem(int workOrderId, int serviceId, int quantity) async {
    try {
      // Agrega un servicio/detalle a la orden de trabajo seleccionada
      final res = await _dio.post(
        '/ordenes-trabajo/$workOrderId/add-item/',
        data: {'service_id': serviceId, 'quantity': quantity},
      );
      return WorkOrder.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<WorkOrder> confirmWorkOrder(int workOrderId) async {
    try {
      final res = await _dio.post('/ordenes-trabajo/$workOrderId/confirm/');
      return WorkOrder.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<WorkOrder> updateStatus(int workOrderId, String status) async {
    try {
      // Cambia el estado de la orden (ej. 'Pendiente', 'En Diagnóstico', 'Completado')
      final res = await _dio.post(
        '/ordenes-trabajo/$workOrderId/update-status/',
        data: {'status': status},
      );
      return WorkOrder.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    try {
      final res = await _dio.get('/ordenes-trabajo/stats/');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

// ── Provider Global de Órdenes de Trabajo ─────────────────────
final orderDatasourceProvider = Provider<OrderRemoteDatasource>((ref) {
  return OrderRemoteDatasourceImpl(ref.watch(dioProvider));
});