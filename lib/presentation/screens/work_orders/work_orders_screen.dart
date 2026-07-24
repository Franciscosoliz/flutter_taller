// lib/presentation/screens/work_orders/work_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/model/work_order.dart';
import '../../../theme/app_colors.dart';
import '../../providers/work_order_provider.dart';
import '../../widgets/status_badge.dart';

const _statusFilters = [
  ('', 'Todos'),
  ('pending', 'Recepción'),
  ('in_process', 'Reparación'),
  ('ready', 'Listos'),
  ('delivered', 'Entregados'),
  ('cancelled', 'Cancelados'),
];

class WorkOrdersScreen extends ConsumerStatefulWidget {
  const WorkOrdersScreen({super.key});

  @override
  ConsumerState<WorkOrdersScreen> createState() => _WorkOrdersScreenState();
}

class _WorkOrdersScreenState extends ConsumerState<WorkOrdersScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 150) {
        ref.read(workOrdersProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workOrdersProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Órdenes de Trabajo', style: tt.headlineMedium),
                          Text(
                            '${state.total} orden${state.total != 1 ? "es" : ""}',
                            style: tt.bodySmall,
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: ref.read(workOrdersProvider.notifier).refresh,
                        icon: const Icon(Icons.refresh_rounded,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Filtros por estado
                  SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _statusFilters.map((filter) {
                        final isSelected = state.statusFilter == filter.$1;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter.$2),
                            selected: isSelected,
                            onSelected: (_) => ref
                                .read(workOrdersProvider.notifier)
                                .setStatusFilter(filter.$1),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // ── Contenido ─────────────────────────────────────
            Expanded(
              child: Builder(builder: (_) {
                if (state.isLoading && state.orders.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  );
                }
                if (state.error != null && state.orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('❌', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 12),
                        Text(state.error!,
                            style: const TextStyle(color: AppColors.error)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: ref.read(workOrdersProvider.notifier).refresh,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }
                if (state.orders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🛠️', style: TextStyle(fontSize: 52)),
                        SizedBox(height: 16),
                        Text('Sin órdenes registradas',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )),
                        Text('Las órdenes de trabajo aparecerán aquí',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.orders.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    if (i >= state.orders.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            color: AppColors.accent,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }
                    final order = state.orders[i];
                    return _WorkOrderCard(
                      order: order,
                      onTap: () => context.push('/orders/${order.id}'),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkOrderCard extends StatelessWidget {
  final WorkOrder order;
  final VoidCallback onTap;
  const _WorkOrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Órden #${order.id}', style: tt.titleMedium),
                    if (order.vehiclePlate != null && order.vehiclePlate!.isNotEmpty)
                      Text('Placa: ${order.vehiclePlate}',
                          style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                  ],
                ),
                StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                ...order.items.take(3).map((item) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Text(
                        '${item.quantity}× ${item.serviceName}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
                if (order.items.length > 3)
                  Text(
                    '+${order.items.length - 3} más',
                    style: const TextStyle(
                        color: AppColors.textFaint, fontSize: 11),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.items.length} servicio${order.items.length != 1 ? "s" : ""}',
                  style: tt.bodySmall,
                ),
                Row(
                  children: [
                    Text(
                      formatPrice(order.total),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textFaint, size: 18),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}