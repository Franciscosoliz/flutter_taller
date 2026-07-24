// lib/presentation/widgets/search_bar.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ServiceSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String? initialValue;

  const ServiceSearchBar({
    super.key,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<ServiceSearchBar> createState() => _ServiceSearchBarState();
}

class _ServiceSearchBarState extends State<ServiceSearchBar> {
  late final TextEditingController _ctrl;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), () {
      widget.onChanged(value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Buscar servicio o mantenimiento...',
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
        suffixIcon: _ctrl.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                onPressed: () {
                  _ctrl.clear();
                  widget.onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
    );
  }
}