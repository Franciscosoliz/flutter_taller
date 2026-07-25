// presentation/widgets/employee_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../domain/model/employee.dart';
import '../providers/employees_admin_provider.dart';

void showEmployeeForm(BuildContext context, WidgetRef ref,
    {Employee? initial}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _EmployeeFormDialog(initial: initial),
  );
}

class _EmployeeFormDialog extends ConsumerStatefulWidget {
  final Employee? initial;
  const _EmployeeFormDialog({this.initial});

  @override
  ConsumerState<_EmployeeFormDialog> createState() =>
      _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends ConsumerState<_EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedUserId;
  String _selectedRole = 'MECANICO';
  final _phoneController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isActive = true;

  final Map<String, String> _availableRoles = {
    'ADMINISTRADOR': 'Administrador',
    'RECEPCIONISTA': 'Recepcionista',
    'MECANICO': 'Mecánico',
    'SUPERVISOR': 'Supervisor',
  };

  final List<String> _allSpecialties = [
    'Motor',
    'Frenos',
    'Suspensión',
    'Transmisión',
    'Electricidad',
    'Inyección Electrónica',
    'Alineación y Balanceo'
  ];

  List<dynamic> _selectedSpecialties = [];

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _selectedUserId = widget.initial!.userId;
      _selectedRole = widget.initial!.role;
      _phoneController.text = widget.initial!.phone;

      // Parsear la fecha de texto a DateTime si viene como String
      try {
        _selectedDate = DateTime.parse(widget.initial!.hireDate);
      } catch (_) {
        _selectedDate = DateTime.now();
      }

      _selectedSpecialties = List.from(widget.initial!.specialties);
      _isActive = widget.initial!.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(employeesAdminProvider).availableUsers;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.initial == null ? 'Añadir Empleado' : 'Editar Empleado',
        style: const TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 450,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selector de Usuario
                DropdownButtonFormField<int>(
                  value: _selectedUserId,
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Usuario *'),
                  items: users.map((u) {
                    return DropdownMenuItem<int>(
                      value: u.id,
                      child: Text(u.username),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedUserId = val),
                  validator: (val) =>
                      val == null ? 'Seleccione un usuario' : null,
                ),
                const SizedBox(height: 12),

                // Selector de Cargo (Valores backend en mayúsculas)
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Cargo *'),
                  items: _availableRoles.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRole = val);
                  },
                ),
                const SizedBox(height: 12),

                // Teléfono
                TextFormField(
                  controller: _phoneController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon:
                        Icon(Icons.phone, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 12),

                // Fecha de Ingreso
                Row(
                  children: [
                    const Text('Fecha de ingreso: ',
                        style: TextStyle(color: AppColors.textSecondary)),
                    Text(
                      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_month,
                          color: AppColors.accent),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Selección de Especialidades
                const Text('Especialidades:',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _allSpecialties.map((spec) {
                    final isSelected = _selectedSpecialties.contains(spec);
                    return FilterChip(
                      label: Text(spec,
                          style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.black
                                  : AppColors.textPrimary)),
                      selected: isSelected,
                      selectedColor: AppColors.accent,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSpecialties.add(spec);
                          } else {
                            _selectedSpecialties.remove(spec);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Checkbox Activo
                CheckboxListTile(
                  title: const Text('Activo',
                      style: TextStyle(color: AppColors.textPrimary)),
                  value: _isActive,
                  activeColor: AppColors.accent,
                  onChanged: (val) => setState(() => _isActive = val ?? true),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final users = ref.read(employeesAdminProvider).availableUsers;
      final selectedUser = users.firstWhere(
        (u) => u.id == _selectedUserId,
        orElse: () => UserOption(
            id: _selectedUserId!, username: 'Usuario', email: '', rol: ''),
      );

      final formattedDate =
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

      final employee = Employee(
        id: widget.initial?.id ?? 0,
        userId: _selectedUserId!,
        userName: selectedUser.username,
        role: _selectedRole,
        phone: _phoneController.text,
        hireDate: formattedDate,
        specialties: _selectedSpecialties,
        isActive: _isActive,
      );

      ref.read(employeesAdminProvider.notifier).saveEmployee(employee);
      Navigator.pop(context);
    }
  }
}
