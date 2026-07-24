import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/api/service_remote_datasource.dart';
import '../../domain/model/service.dart';

class ServicesAdminState {
  final List<Service> services;
  final bool isLoading;
  final String? error;
  final String search;
  final ServiceFormState formState;

  const ServicesAdminState({
    this.services = const [],
    this.isLoading = false,
    this.error,
    this.search = '',
    this.formState = const ServiceFormIdle(),
  });

  List<Service> get filtered => search.isEmpty
      ? services
      : services
          .where((s) => s.name.toLowerCase().contains(search.toLowerCase()))
          .toList();

  ServicesAdminState copyWith({
    List<Service>? services,
    bool? isLoading,
    String? error,
    String? search,
    ServiceFormState? formState,
  }) =>
      ServicesAdminState(
        services: services ?? this.services,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        search: search ?? this.search,
        formState: formState ?? this.formState,
      );
}

sealed class ServiceFormState {
  const ServiceFormState();
}

class ServiceFormIdle extends ServiceFormState {
  const ServiceFormIdle();
}

class ServiceFormSaving extends ServiceFormState {
  const ServiceFormSaving();
}

class ServiceFormSuccess extends ServiceFormState {
  final String message;
  const ServiceFormSuccess(this.message);
}

class ServiceFormError extends ServiceFormState {
  final String message;
  const ServiceFormError(this.message);
}

class ServicesAdminNotifier extends StateNotifier<ServicesAdminState> {
  final ServiceRemoteDatasource _datasource;

  ServicesAdminNotifier(this._datasource) : super(const ServicesAdminState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _datasource.getServices(pageSize: 100);
      state = state.copyWith(services: response.results, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void setSearch(String q) => state = state.copyWith(search: q);

  Future<void> toggleActive(int id, bool isActive) async {
    state = state.copyWith(
      services: state.services
          .map((s) => s.id == id ? s.copyWith(isActive: isActive) : s)
          .toList(),
    );
    try {
      await _datasource.updateService(id, {'is_active': isActive});
    } catch (_) {
      state = state.copyWith(
        services: state.services
            .map((s) => s.id == id ? s.copyWith(isActive: !isActive) : s)
            .toList(),
      );
    }
  }

  Future<void> createService(Map<String, dynamic> payload) async {
    state = state.copyWith(formState: const ServiceFormSaving());
    try {
      final created = await _datasource.createService(payload);
      state = state.copyWith(
        services: [created, ...state.services],
        formState: const ServiceFormSuccess('Servicio creado con éxito'),
      );
    } catch (e) {
      state = state.copyWith(
        formState: ServiceFormError(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> updateService(int id, Map<String, dynamic> payload) async {
    state = state.copyWith(formState: const ServiceFormSaving());
    try {
      final updated = await _datasource.updateService(id, payload);
      state = state.copyWith(
        services: state.services.map((s) => s.id == id ? updated : s).toList(),
        formState: const ServiceFormSuccess('Servicio actualizado'),
      );
    } catch (e) {
      state = state.copyWith(
        formState: ServiceFormError(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> deleteService(int id) async {
    try {
      await _datasource.deleteService(id);
      state = state.copyWith(
        services: state.services.where((s) => s.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  void resetFormState() =>
      state = state.copyWith(formState: const ServiceFormIdle());
}

final servicesAdminProvider =
    StateNotifierProvider<ServicesAdminNotifier, ServicesAdminState>((ref) {
  return ServicesAdminNotifier(ref.watch(serviceDatasourceProvider));
});