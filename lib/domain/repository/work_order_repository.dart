// lib/domain/repositories/work_order_repository.dart
import '../model/work_order.dart';


/// Respuesta paginada para el listado de órdenes de trabajo
class PaginatedWorkOrders {
  final List<WorkOrder> items;
  final int total;

  PaginatedWorkOrders({
    required this.items,
    required this.total,
  });
}

/// Contrato abstracto para el repositorio de órdenes de trabajo
abstract class WorkOrderRepository {
  /// Obtiene la lista de órdenes de trabajo con soporte de paginación y filtros
  Future<PaginatedWorkOrders> getWorkOrders({
    String? status,
    int limit = 20,
    int offset = 0,
  });

  /// Obtiene el detalle de una orden de trabajo específica por su ID
  Future<WorkOrder> getWorkOrderById(int id);

  /// Actualiza el estado de una orden de trabajo
  Future<WorkOrder> updateOrderStatus(int id, WorkOrderStatus newStatus);
}