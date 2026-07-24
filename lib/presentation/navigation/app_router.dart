// lib/presentation/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/auth_state.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/profile_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/catalog/catalog_screen.dart';
import '../screens/catalog/home_screen.dart';
import '../screens/work_orders/work_order_detail_screen.dart';
import '../screens/work_orders/work_orders_screen.dart';
import '../screens/admin/admin_shell.dart';
import '../screens/admin/admin_services_screen.dart';
import '../screens/admin/categories_admin_screen.dart';
import 'public_shell.dart';

// Pantalla temporal de Splash mientras se valida la sesión activa
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
}

// Pantalla temporal para vistas en desarrollo
class _PlaceholderScreen extends ConsumerWidget {
  final String title;
  const _PlaceholderScreen(this.title);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(color: Color(0xFF8888AA), fontSize: 16),
        ),
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthStateListenable(ref),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isChecking = authState.isChecking;
      final isAuth = authState.isAuthenticated;
      final isStaff = authState.isStaff;
      final location = state.matchedLocation;

      // 1. Mientras se verifica la sesión local, forzar Splash
      if (isChecking) {
        return location == '/splash' ? null : '/splash';
      }

      final isAuthRoute = location == '/login' || location == '/register';
      final isSplash = location == '/splash';

      // 2. Al terminar Splash, redirigir según estado de autenticación y rol
      if (isSplash) return isAuth ? (isStaff ? '/admin/services' : '/') : '/login';

      // 3. Si no está autenticado e intenta ir a una ruta privada -> enviar al Login
      if (!isAuth && !isAuthRoute) return '/login';

      // 4. Si ya está autenticado e intenta entrar a Login/Register -> enviar a su pantalla principal
      if (isAuth && isAuthRoute) return isStaff ? '/admin/services' : '/';

      // 5. Si es cliente e intenta ingresar a cualquier sección de /admin -> enviar a inicio
      if (isAuth && !isStaff && location.startsWith('/admin')) return '/';

      return null;
    },
    routes: [
      // ── Splash ────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        builder: (_, __) => const _SplashScreen(),
      ),

      // ── Auth ──────────────────────────────────────────────
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),

      // ── Zona pública / cliente con BottomNavigationBar ────
      ShellRoute(
        builder: (_, __, child) => PublicShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/catalog',
            builder: (_, __) => const CatalogScreen(),
          ),
          GoRoute(
            path: '/catalog/:id',
            builder: (_, s) => _PlaceholderScreen(
              'Detalle de Servicio #${s.pathParameters['id']} — M5',
            ),
          ),
          GoRoute(
            path: '/cart',
            builder: (_, __) =>
                const _PlaceholderScreen('Cotización / Carrito — M5'),
          ),
          GoRoute(
            path: '/orders',
            builder: (_, __) => const WorkOrdersScreen(),
          ),
          GoRoute(
            path: '/orders/:id',
            builder: (_, s) {
              final id = int.parse(s.pathParameters['id']!);
              return WorkOrderDetailScreen(orderId: id);
            },
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // ── Panel de Administración / Gestión del Taller ───────
      GoRoute(
        path: '/admin',
        builder: (context, state) => AdminShell(
          title: 'Gestión de Servicios',
          currentRoute: state.matchedLocation,
          child: const ServicesAdminScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/services',
        builder: (context, state) => AdminShell(
          title: 'Gestión de Servicios',
          currentRoute: state.matchedLocation,
          child: const ServicesAdminScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/categories',
        builder: (context, state) => AdminShell(
          title: 'Gestión de Categorías',
          currentRoute: state.matchedLocation,
          child: const CategoriesAdminScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/products',
        builder: (_, __) =>
            const _PlaceholderScreen('Gestión de Servicios — M10'),
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (_, __) =>
            const _PlaceholderScreen('Gestión de Órdenes Taller — M11'),
      ),
      GoRoute(
        path: '/admin/orders/:id',
        builder: (_, s) => _PlaceholderScreen(
          'Detalle Órden Admin #${s.pathParameters['id']} — M11',
        ),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (_, __) =>
            const _PlaceholderScreen('Gestión de Usuarios — M12'),
      ),
    ],
  );
});

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
}