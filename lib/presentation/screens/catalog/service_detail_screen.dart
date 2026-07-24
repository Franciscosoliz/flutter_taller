// lib/presentation/screens/catalog/service_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/model/service.dart';
import '../../../theme/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';

class ServiceDetailScreen extends ConsumerWidget {
  final int serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogProvider);
    final service = state.services.firstWhere(
      (s) => s.id == serviceId,
      orElse: () => state.services.isEmpty
          ? Service.empty()
          : state.services.first,
    );

    if (state.isLoading && state.services.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    if (service.id == 0) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text(
            'Servicio no encontrado',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      );
    }

    return _ServiceDetailContent(service: service);
  }
}

class _ServiceDetailContent extends ConsumerWidget {
  final Service service;
  const _ServiceDetailContent({required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(service.name, overflow: TextOverflow.ellipsis)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del Servicio
            Container(
              height: 220,
              width: double.infinity,
              color: AppColors.surface,
              child: service.imageUrl != null && service.imageUrl!.isNotEmpty
                  ? Image.network(
                      service.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.build_rounded, size: 64, color: AppColors.textSecondary),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.build_rounded, size: 64, color: AppColors.textSecondary),
                    ),
            ),

            // Detalles del Trabajo
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (service.category != null)
                    Text(
                      service.category!.name.toUpperCase(),
                      style: tt.labelSmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    service.name,
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Precio base e IVA
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '\$${service.priceWithTax.toStringAsFixed(2)}',
                        style: tt.headlineMedium?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Inc. IVA (\$${service.price.toStringAsFixed(2)} + IVA)',
                        style: tt.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Descripción
                  Text('Detalles del Mantenimiento', style: tt.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    service.description.isNotEmpty
                        ? service.description
                        : 'Mantenimiento mecánico especializado realizado por técnicos certificados.',
                    style: tt.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Botón para agregar a la orden
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_shopping_cart_rounded),
            label: const Text('Agregar a la Cotización'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.onAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              ref.read(cartProvider.notifier).addItem(service);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${service.name} agregado a la cotización'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}