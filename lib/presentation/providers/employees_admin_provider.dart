// presentation/providers/employees_admin_provider.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../domain/model/employee.dart';
import '../../data/local/secure_storage.dart'; // 👈 Importamos SecureStorage

class EmployeesAdminState {
  final List<Employee> employees;
  final List<UserOption> availableUsers;
  final String search;
  final bool isLoading;
  final String? error;

  EmployeesAdminState({
    this.employees = const [],
    this.availableUsers = const [],
    this.search = '',
    this.isLoading = false,
    this.error,
  });

  List<Employee> get filtered {
    if (search.isEmpty) return employees;
    final query = search.toLowerCase();
    return employees.where((e) {
      return e.userName.toLowerCase().contains(query) ||
          e.role.toLowerCase().contains(query) ||
          e.phone.contains(query);
    }).toList();
  }

  EmployeesAdminState copyWith({
    List<Employee>? employees,
    List<UserOption>? availableUsers,
    String? search,
    bool? isLoading,
    String? error,
  }) {
    return EmployeesAdminState(
      employees: employees ?? this.employees,
      availableUsers: availableUsers ?? this.availableUsers,
      search: search ?? this.search,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EmployeesAdminNotifier extends StateNotifier<EmployeesAdminState> {
  final Ref _ref;
  final SecureStorage _storage; // 👈 Dependencia de SecureStorage

  static const String baseUrl = 'http://165.227.99.251/api';

  EmployeesAdminNotifier(this._ref, this._storage)
      : super(EmployeesAdminState()) {
    Future.microtask(() => load());
  }

  // Obtener headers de manera asíncrona usando SecureStorage
  Future<Map<String, String>> _getHeaders() async {
    final token =
        await _storage.getAccess(); // 👈 Obtenemos el token real y activo

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // 1. CARGAR EMPLEADOS Y USUARIOS
  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final headers = await _getHeaders(); // 👈 Llamada asíncrona de headers

      final empRes = await http.get(
        Uri.parse('$baseUrl/empleados/?page_size=100'),
        headers: headers,
      );

      if (empRes.statusCode != 200) {
        state = state.copyWith(
          isLoading: false,
          error:
              'Error al obtener empleados (${empRes.statusCode}): ${empRes.body}',
        );
        return;
      }

      final decodedBody = jsonDecode(empRes.body);
      final List dynamicEmployees =
          (decodedBody is Map && decodedBody.containsKey('results'))
              ? decodedBody['results']
              : decodedBody;

      final employees = <Employee>[];
      for (var i = 0; i < dynamicEmployees.length; i++) {
        try {
          final emp = Employee.fromJson(dynamicEmployees[i]);
          employees.add(emp);
        } catch (_) {}
      }

      // Cargar usuarios
      List<UserOption> users = [];
      try {
        print(
            '>>> [DEBUG] Solicitando usuarios a: $baseUrl/usuarios/?page_size=100');
        final usersRes = await http.get(
          Uri.parse('$baseUrl/usuarios/?page_size=100'),
          headers: headers,
        );

        print('>>> [DEBUG] Usuarios Status Code: ${usersRes.statusCode}');
        print('>>> [DEBUG] Usuarios Body crudo: ${usersRes.body}');

        if (usersRes.statusCode == 200) {
          final decodedUsers = jsonDecode(usersRes.body);
          final List dynamicUsers =
              (decodedUsers is Map && decodedUsers.containsKey('results'))
                  ? decodedUsers['results']
                  : decodedUsers;

          for (var i = 0; i < dynamicUsers.length; i++) {
            try {
              final userOpt = UserOption.fromJson(dynamicUsers[i]);
              print(
                  '>>> [DEBUG USER $i] Username: ${userOpt.username} | Rol devuelto: "${userOpt.rol}"');

              // Aceptamos cualquier variante en mayúsculas/minúsculas para depurar
              if (userOpt.rol.toUpperCase().contains('EMPLEADO') ||
                  userOpt.rol.toUpperCase() == 'EMPLOYEE') {
                users.add(userOpt);
                print(
                    '>>> [CHECK] Usuario añadido con éxito: ${userOpt.username}');
              } else {
                print(
                    '>>> [WARN] Usuario descartado por rol no coincidente: ${userOpt.username} (Rol: ${userOpt.rol})');
              }
            } catch (eUserItem) {
              print('>>> [ERROR MAPPING USUARIO en índice $i]: $eUserItem');
            }
          }
        }
      } catch (userErr) {
        print('>>> [DEBUG] Error al cargar usuarios: $userErr');
      }

      state = state.copyWith(
        employees: employees,
        availableUsers: users,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al procesar datos: $e',
      );
    }
  }

  void setSearch(String query) {
    state = state.copyWith(search: query);
  }

  Future<bool> saveEmployee(Employee employee) async {
    try {
      final headers = await _getHeaders();
      final isEditing =
          state.employees.any((e) => e.id == employee.id && employee.id > 0);

      http.Response response;
      if (isEditing) {
        response = await http.put(
          Uri.parse('$baseUrl/empleados/${employee.id}/'),
          headers: headers,
          body: jsonEncode(employee.toJson()),
        );
      } else {
        final bodyData = employee.toJson()..remove('id');
        response = await http.post(
          Uri.parse('$baseUrl/empleados/'),
          headers: headers,
          body: jsonEncode(bodyData),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        await load();
        return true;
      } else {
        state = state.copyWith(
            error: 'No se pudo guardar (${response.statusCode})');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Error de red al guardar');
      return false;
    }
  }

  Future<void> toggleActive(int id, bool value) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/empleados/$id/'),
        headers: headers,
        body: jsonEncode({'activo': value}),
      );

      if (response.statusCode == 200) {
        final list = state.employees.map((e) {
          if (e.id == id) {
            return Employee(
              id: e.id,
              userId: e.userId,
              userName: e.userName,
              role: e.role,
              phone: e.phone,
              hireDate: e.hireDate,
              specialties: e.specialties,
              isActive: value,
            );
          }
          return e;
        }).toList();
        state = state.copyWith(employees: list);
      }
    } catch (e) {
      state = state.copyWith(error: 'Error al cambiar estado');
    }
  }

  Future<void> deleteEmployee(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/empleados/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final list = state.employees.where((e) => e.id != id).toList();
        state = state.copyWith(employees: list);
      } else {
        state = state.copyWith(error: 'Error al eliminar');
      }
    } catch (e) {
      state = state.copyWith(error: 'Error de red');
    }
  }
}

final employeesAdminProvider =
    StateNotifierProvider<EmployeesAdminNotifier, EmployeesAdminState>((ref) {
  return EmployeesAdminNotifier(
    ref,
    ref.watch(
        secureStorageProvider), // 👈 Inyectamos el provider de almacenamiento seguro
  );
});
