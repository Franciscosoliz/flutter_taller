// lib/presentation/providers/work_order_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/api/dio_client.dart';
import '../../data/repository/work_order_repository_impl.dart';
import '../../domain/model/work_order.dart';
import '../../domain/repository/work_order_repository.dart';

// 1. Instanciamos la implementación conectando con Dio
final workOrderRepositoryProvider = Provider<WorkOrderRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return WorkOrderRepositoryImpl(dio);
});

// 2. Provider para el detalle de una orden individual
final orderDetailProvider = FutureProvider.family<WorkOrder, int>((ref, id) async {
  final repository = ref.watch(workOrderRepositoryProvider);
  return repository.getWorkOrderById(id);
});

// 3. Estado para la lista de órdenes
class WorkOrdersState {
  final List<WorkOrder> orders;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String statusFilter;
  final int total;

  WorkOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.statusFilter = '',
    this.total = 0,
  });

  WorkOrdersState copyWith({
    List<WorkOrder>? orders,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? statusFilter,
    int? total,
  }) {
    return WorkOrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      statusFilter: statusFilter ?? this.statusFilter,
      total: total ?? this.total,
    );
  }
}

// 4. Notifier para gestionar la lista de órdenes
class WorkOrdersNotifier extends StateNotifier<WorkOrdersState> {
  final Ref ref;

  WorkOrdersNotifier(this.ref) : super(WorkOrdersState()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(workOrderRepositoryProvider);
      final result = await repository.getWorkOrders(
        status: state.statusFilter,
        offset: 0,
      );
      state = state.copyWith(
        orders: result.items,
        total: result.total,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.orders.length >= state.total) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final repository = ref.read(workOrderRepositoryProvider);
      final result = await repository.getWorkOrders(
        status: state.statusFilter,
        offset: state.orders.length,
      );
      state = state.copyWith(
        orders: [...state.orders, ...result.items],
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void setStatusFilter(String status) {
    if (state.statusFilter == status) return;
    state = state.copyWith(statusFilter: status);
    loadOrders();
  }

  void refresh() {
    loadOrders();
  }
}

// 5. Provider principal consumido por WorkOrdersScreen
final workOrdersProvider =
    StateNotifierProvider<WorkOrdersNotifier, WorkOrdersState>((ref) {
  return WorkOrdersNotifier(ref);
});