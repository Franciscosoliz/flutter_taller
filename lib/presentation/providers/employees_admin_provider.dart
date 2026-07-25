// presentation/providers/employees_admin_provider.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../domain/model/employee.dart';
import 'auth_provider.dart';

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

  // Base URL obtenida del entorno real expuesto en los logs
  static const String baseUrl = 'http://165.227.99.251/api';

  EmployeesAdminNotifier(this._ref) : super(EmployeesAdminState()) {
    load();
  }

  // Obtención segura del Token desde AuthState
  Map<String, String> _getHeaders() {
    final authState = _ref.read(authProvider);
    
    // Si en AuthState el getter se llama diferente, ajusta esta línea (ej. authState.accessToken o authState.user?.token)
    final dynamic rawToken = (authState as dynamic).token ?? 
                             (authState as dynamic).accessToken ?? 
                             (authState as dynamic).user?.token;

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (rawToken != null) 'Authorization': 'Bearer $rawToken',
    };
  }

  // 1. CARGAR EMPLEADOS Y USUARIOS (GET)
  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final headers = _getHeaders();

      // Petición a la API de Empleados con tamaño de página ampliado
      final empRes = await http.get(
        Uri.parse('$baseUrl/empleados/?page_size=100'),
        headers: headers,
      );

      // Petición a la API de Usuarios para selección en formulario
      final usersRes = await http.get(
        Uri.parse('$baseUrl/usuarios/?page_size=100'),
        headers: headers,
      );

      if (empRes.statusCode == 200) {
        final decodedBody = jsonDecode(empRes.body);
        
        // Manejo flexible: Si el backend retorna {"results": [...]} o una List directa [...]
        final List dynamicEmployees = decodedBody is Map && decodedBody.containsKey('results')
            ? decodedBody['results']
            : decodedBody;

        final employees = dynamicEmployees.map((e) => Employee.fromJson(e)).toList();

        List<UserOption> users = [];
        if (usersRes.statusCode == 200) {
          final decodedUsers = jsonDecode(usersRes.body);
          final List dynamicUsers = decodedUsers is Map && decodedUsers.containsKey('results')
              ? decodedUsers['results']
              : decodedUsers;

          users = dynamicUsers.map((u) => UserOption.fromJson(u)).toList();
        }

        state = state.copyWith(
          employees: employees,
          availableUsers: users,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Error al obtener empleados (${empRes.statusCode})',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error de conexión con el servidor',
      );
    }
  }

  void setSearch(String query) {
    state = state.copyWith(search: query);
  }

  // 2. CREAR O ACTUALIZAR EMPLEADO (POST / PUT)
  Future<bool> saveEmployee(Employee employee) async {
    try {
      final headers = _getHeaders();
      final isEditing = state.employees.any((e) => e.id == employee.id && employee.id > 0);

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
        state = state.copyWith(error: 'No se pudo guardar el empleado');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Error de red al guardar');
      return false;
    }
  }

  // 3. CAMBIAR ESTADO ACTIVO/INACTIVO (PATCH)
  Future<void> toggleActive(int id, bool value) async {
    try {
      final headers = _getHeaders();
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

  // 4. ELIMINAR EMPLEADO (DELETE)
  Future<void> deleteEmployee(int id) async {
    try {
      final headers = _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/empleados/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final list = state.employees.where((e) => e.id != id).toList();
        state = state.copyWith(employees: list);
      } else {
        state = state.copyWith(error: 'Error al eliminar el empleado');
      }
    } catch (e) {
      state = state.copyWith(error: 'Error de red al eliminar');
    }
  }
}

final employeesAdminProvider =
    StateNotifierProvider<EmployeesAdminNotifier, EmployeesAdminState>((ref) {
  return EmployeesAdminNotifier(ref);
});