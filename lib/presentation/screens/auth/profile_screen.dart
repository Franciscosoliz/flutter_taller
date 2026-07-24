// lib/presentation/screens/auth/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final tt   = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Avatar
              Container(
                width:  80, 
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accent, AppColors.accentLight],
                    begin:  Alignment.topLeft,
                    end:    Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (user?.username.isNotEmpty == true)
                        ? user!.username[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color:      AppColors.onAccent,
                      fontSize:   34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(user?.username ?? '—', style: tt.headlineMedium),
              Text(user?.email    ?? '—', style: tt.bodyMedium),
              const SizedBox(height: 8),
              if (user?.isStaff == true)
                Container(
                  padding:    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color:        AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Staff',
                    style: TextStyle(
                      color:         AppColors.accent,
                      fontSize:      12,
                      fontWeight:    FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // Info de la cuenta
              Container(
                width:   double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:        AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'INFORMACIÓN DE LA CUENTA',
                      style: TextStyle(
                        color:         AppColors.textSecondary,
                        fontSize:      11,
                        fontWeight:    FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...[
                      ('ID de usuario', user?.id.toString() ?? '—'),
                      ('Usuario',       user?.username      ?? '—'),
                      ('Email',         user?.email         ?? '—'),
                      ('Rol',           user?.isStaff == true ? 'Administrador' : 'Cliente'),
                    ].map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.$1, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          Text(item.$2, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ⚡ Botón Panel Admin — solo visible para Staff
              if (user?.isStaff == true) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/admin'),
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: const Text(
                      'Panel de Administración',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.onAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Botón Cerrar Sesión
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Cerrar sesión'),
                        content: const Text('¿Estás seguro de que deseas salir?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(foregroundColor: AppColors.error),
                            child: const Text('Salir'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                  label: const Text('Cerrar sesión', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}