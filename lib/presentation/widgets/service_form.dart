import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../domain/model/service.dart';
import '../providers/services_admin_provider.dart';
import '../../data/remote/api/service_remote_datasource.dart';

Future<void> showServiceForm(
  BuildContext context,
  WidgetRef ref, {
  Service? initial,
}) {
  ref.read(servicesAdminProvider.notifier).resetFormState();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: ServiceFormSheet(initial: initial),
    ),
  );
}

class ServiceFormSheet extends ConsumerStatefulWidget {
  final Service? initial;
  const ServiceFormSheet({super.key, this.initial});

  @override
  ConsumerState<ServiceFormSheet> createState() => _ServiceFormSheetState();
}

class _ServiceFormSheetState extends ConsumerState<ServiceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  
  int? _selectedCategoryId;
  bool _isActive = true;
  List<ServiceCategory> _categories = [];
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      final s = widget.initial!;
      _nameCtrl.text = s.name;
      _descCtrl.text = s.description;
      _priceCtrl.text = s.price > 0 ? s.price.toStringAsFixed(2) : '';
      _imageCtrl.text = s.imageUrl ?? '';
      _selectedCategoryId = s.category?.id;
      _isActive = s.isActive;
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await ref.read(serviceDatasourceProvider).getCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _loadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': double.parse(_priceCtrl.text.trim()),
      'is_active': _isActive,
      if (_selectedCategoryId != null) 'category_id': _selectedCategoryId,
      if (_imageCtrl.text.trim().isNotEmpty) 'image_url': _imageCtrl.text.trim(),
    };

    if (widget.initial != null) {
      await ref
          .read(servicesAdminProvider.notifier)
          .updateService(widget.initial!.id, payload);
    } else {
      await ref.read(servicesAdminProvider.notifier).createService(payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formSt = ref.watch(servicesAdminProvider.select((s) => s.formState));
    final isSaving = formSt is ServiceFormSaving;
    final isEdit = widget.initial != null;

    if (formSt is ServiceFormSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              isEdit ? 'Editar Servicio' : 'Nuevo Servicio de Taller',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (formSt is ServiceFormError) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  formSt.message,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
              const SizedBox(height: 14),
            ],
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    enabled: !isSaving,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Servicio *',
                      hintText: 'Ej. Cambio de Aceite y Filtro',
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (v) => validateRequired(v, 'Nombre'),
                  ),
                  const SizedBox(height: 14),
                  _loadingCategories
                      ? const LinearProgressIndicator(color: AppColors.accent)
                      : DropdownButtonFormField<int>(
                          value: _selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Categoría / Especialidad',
                            hintText: 'Seleccionar categoría',
                          ),
                          dropdownColor: AppColors.surface,
                          style: const TextStyle(color: AppColors.textPrimary),
                          items: _categories.map((cat) {
                            return DropdownMenuItem<int>(
                              value: cat.id,
                              child: Text(cat.name),
                            );
                          }).toList(),
                          onChanged: isSaving
                              ? null
                              : (val) => setState(() => _selectedCategoryId = val),
                        ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _priceCtrl,
                    enabled: !isSaving,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Precio Base (\$) *',
                      prefixText: '\$ ',
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'El precio es requerido';
                      if (double.tryParse(v.trim()) == null) return 'Ingrese un precio válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _imageCtrl,
                    enabled: !isSaving,
                    decoration: const InputDecoration(
                      labelText: 'URL de la Imagen (Opcional)',
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descCtrl,
                    enabled: !isSaving,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción / Trabajo a realizar',
                      alignLabelWithHint: true,
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Servicio Activo',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Disponible en cotizaciones',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _isActive,
                          onChanged: isSaving ? null : (v) => setState(() => _isActive = v),
                          activeThumbColor: AppColors.accent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSaving ? null : () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _submit,
                          child: isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.onAccent,
                                  ),
                                )
                              : Text(isEdit ? 'Guardar' : 'Crear'),
                        ),
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