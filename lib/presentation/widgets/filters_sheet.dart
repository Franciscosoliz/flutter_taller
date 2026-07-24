// lib/presentation/widgets/filters_sheet.dart
import 'package:flutter/material.dart';
import 'package:taller_mecanico_app/domain/model/service.dart';
import '../../domain/model/category.dart';
import '../../theme/app_colors.dart';

const _orderOptions = [
  ('Nombre A→Z', 'name'),
  ('Nombre Z→A', '-name'),
  ('Menor Precio', 'price'),
  ('Mayor Precio', '-price'),
  ('Recientes', '-created_at'),
];

Future<ServiceFilters?> showFiltersSheet({
  required BuildContext context,
  required ServiceFilters activeFilters,
  required List<ServiceCategory> categories, // <-- Cambiar Category por ServiceCategory
}) {
  return showModalBottomSheet<ServiceFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _FiltersSheet(
      activeFilters: activeFilters,
      categories: categories,
    ),
  );
}

// 2. Actualizar el StatefulWidget interno
class _FiltersSheet extends StatefulWidget {
  final ServiceFilters activeFilters;
  final List<ServiceCategory> categories; // <-- Cambiar Category por ServiceCategory

  const _FiltersSheet({
    required this.activeFilters,
    required this.categories,
  });

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late int? _categoryId;
  late String? _ordering;
  final _ctrlMin = TextEditingController();
  final _ctrlMax = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categoryId = widget.activeFilters.categoryId;
    _ordering = widget.activeFilters.ordering;
    _ctrlMin.text = widget.activeFilters.minPrice?.toStringAsFixed(0) ?? '';
    _ctrlMax.text = widget.activeFilters.maxPrice?.toStringAsFixed(0) ?? '';
  }

  @override
  void dispose() {
    _ctrlMin.dispose();
    _ctrlMax.dispose();
    super.dispose();
  }

  void _apply() {
    Navigator.pop(
      context,
      ServiceFilters(
        categoryId: _categoryId,
        ordering: _ordering,
        minPrice: double.tryParse(_ctrlMin.text),
        maxPrice: double.tryParse(_ctrlMax.text),
      ),
    );
  }

  void _clear() {
    Navigator.pop(context, const ServiceFilters());
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Filtros de Servicio',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clear,
                  child: const Text('Limpiar', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(20),
              children: [
                const _SectionTitle('Especialidad / Categoría'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChip(
                      label: 'Todas',
                      active: _categoryId == null,
                      onTap: () => setState(() => _categoryId = null),
                    ),
                    ...widget.categories.map((cat) => _FilterChip(
                          label: cat.name,
                          active: _categoryId == cat.id,
                          onTap: () => setState(() => _categoryId = cat.id),
                        )),
                  ],
                ),
                const SizedBox(height: 20),
                const _SectionTitle('Rango de Precio Estimado'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrlMin,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Mínimo',
                          prefixText: '\$ ',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('—', style: TextStyle(color: AppColors.textSecondary, fontSize: 18)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _ctrlMax,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Máximo',
                          prefixText: '\$ ',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const _SectionTitle('Ordenar por'),
                const SizedBox(height: 8),
                ..._orderOptions.map((o) => RadioListTile<String>(
                      title: Text(o.$1),
                      value: o.$2,
                      groupValue: _ordering,
                      onChanged: (v) => setState(() => _ordering = v),
                      activeColor: AppColors.accent,
                      contentPadding: EdgeInsets.zero,
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.onAccent,
                ),
                child: const Text('Aplicar Filtros'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.accent : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? AppColors.accent : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.normal,
              color: active ? AppColors.onAccent : AppColors.textSecondary,
            ),
          ),
        ),
      );
}

class ServiceFilters {
  final int? categoryId;
  final String? ordering;
  final double? minPrice;
  final double? maxPrice;

  const ServiceFilters({
    this.categoryId,
    this.ordering,
    this.minPrice,
    this.maxPrice,
  });
}