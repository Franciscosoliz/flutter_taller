import 'package:flutter/material.dart';
import 'package:taller_mecanico_app/theme/app_colors.dart';

class AdminShell extends StatelessWidget {
  final String title;
  final String currentRoute;
  final Widget child;

  const AdminShell({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: child,
      ),
    );
  }
}