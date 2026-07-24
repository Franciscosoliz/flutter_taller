// lib/domain/model/work_order.dart

enum WorkOrderStatus {
  pending('RECIBIDO', 'En Recepción / Diagnóstico'),
  inProcess('EN_PROCESO', 'En Reparación'),
  ready('LISTO', 'Listo para Entrega'),
  delivered('ENTREGADO', 'Entregado al Cliente'),
  cancelled('CANCELADO', 'Cancelado');

  const WorkOrderStatus(this.value, this.label);
  final String value;
  final String label;

  static WorkOrderStatus fromValue(String? v) => WorkOrderStatus.values.firstWhere(
        (s) => s.value == v || s.name == v,
        orElse: () => WorkOrderStatus.pending,
      );
}

class WorkOrderItem {
  final int id;
  final int serviceId;
  final String serviceName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const WorkOrderItem({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory WorkOrderItem.fromJson(Map<String, dynamic> j) => WorkOrderItem(
        id: j['id'] as int? ?? 0,
        serviceId: ((j['product'] ?? j['service'] ?? {})['id'] ?? 0) as int,
        serviceName: ((j['product'] ?? j['service'] ?? {})['name'] ?? j['nombre'] ?? 'Servicio').toString(),
        quantity: (j['quantity'] ?? j['cantidad'] ?? 1) as int,
        unitPrice: double.tryParse((j['unit_price'] ?? j['precio_unitario'] ?? 0).toString()) ?? 0.0,
        subtotal: double.tryParse((j['subtotal'] ?? 0).toString()) ?? 0.0,
      );
}

class WorkOrder {
  final int id;
  final String orderNumber;
  final String vehicle;
  final String vehiclePlate;
  final WorkOrderStatus status;
  final String? employee;
  final DateTime createdAt;
  final DateTime? estimatedDate;
  final double total;
  final List<WorkOrderItem> items;

  WorkOrder({
    required this.id,
    required this.orderNumber,
    required this.vehicle,
    required this.vehiclePlate,
    required this.status,
    this.employee,
    required this.createdAt,
    this.estimatedDate,
    required this.total,
    required this.items,
  });

  int get numItems => items.length;

  factory WorkOrder.fromJson(Map<String, dynamic> json) {
    // 1. Manejo seguro del vehículo si llega int o String desde Django
    final rawVehicle = json['vehiculo'];
    final String vehicleString = rawVehicle != null ? rawVehicle.toString() : '';
    final String plate = json['vehiculo_placa']?.toString() ?? '';

    // 2. Parseo seguro de la fecha
    final rawFechaIngreso = json['fecha_ingreso'];
    final DateTime parsedCreatedAt = rawFechaIngreso != null 
        ? (DateTime.tryParse(rawFechaIngreso.toString()) ?? DateTime.now())
        : DateTime.now();

    final rawFechaEstimada = json['fecha_estimada_entrega'];
    final DateTime? parsedEstimatedDate = rawFechaEstimada != null 
        ? DateTime.tryParse(rawFechaEstimada.toString()) 
        : null;

    // 3. Empleado encargado
    final String? empNombre = json['empleado_recepciona_nombre']?.toString() ?? 
                              json['empleado_responsable_nombre']?.toString();

    return WorkOrder(
      id: json['id'] as int? ?? 0,
      orderNumber: json['numero_orden']?.toString() ?? '',
      vehicle: vehicleString,
      vehiclePlate: plate,
      status: WorkOrderStatus.fromValue(json['estado']?.toString()),
      employee: empNombre,
      createdAt: parsedCreatedAt,
      estimatedDate: parsedEstimatedDate,
      total: double.tryParse(json['total']?.toString() ?? '0.0') ?? 0.0,
      items: (json['detalles'] as List? ?? [])
          .map((e) => WorkOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── Paginación para Órdenes de Trabajo ────────────────────────
class PaginatedWorkOrders {
  final int count;
  final String? next;
  final String? previous;
  final List<WorkOrder> results;

  const PaginatedWorkOrders({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedWorkOrders.fromJson(Map<String, dynamic> json) {
    return PaginatedWorkOrders(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List? ?? [])
          .map((e) => WorkOrder.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}