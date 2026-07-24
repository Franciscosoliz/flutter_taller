// lib/presentation/widgets/service_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/service.dart';
import '../../theme/app_colors.dart';
import '../providers/cart_provider.dart';

class ServiceCard extends ConsumerWidget {
  final Service service;
  final VoidCallback? onTap;

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Imagen o Placeholder ─────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                color: AppColors.surface,
                child: service.imageUrl != null && service.imageUrl!.isNotEmpty
                    ? Image.network(
                        service.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.build_rounded,
                          size: 40,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : const Icon(
                        Icons.build_rounded,
                        size: 40,
                        color: AppColors.textSecondary,
                      ),
              ),
            ),

            // ── Contenido / Información ───────────────────────
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría
                  if (service.category != null)
                    Text(
                      service.category!.name.toUpperCase(),
                      style: tt.labelSmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 2),

                  // Nombre del servicio
                  Text(
                    service.name,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Precios
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${service.priceWithTax.toStringAsFixed(2)}',
                            style: tt.titleSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Inc. IVA',
                            style: tt.bodySmall?.copyWith(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      // Botón para agregar al carrito/cotización
                      IconButton.filledTonal(
                        iconSize: 20,
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.add_shopping_cart_rounded),
                        onPressed: () {
                          ref.read(cartProvider.notifier).addItem(service);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${service.name} agregado'),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}