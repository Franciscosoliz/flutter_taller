// lib/presentation/providers/catalog_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/api/category_remote_datasource.dart';
import '../../data/remote/api/service_remote_datasource.dart';
import '../../domain/model/service.dart';

// ── Estado del catálogo de servicios ──────────────────────────
class CatalogState {
  final List<Service> services;
  final List<ServiceCategory> categories;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int total;
  final bool hasMore;
  final int page;
  final String? search;
  final int? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final String? ordering;

  const CatalogState({
    this.services = const [],
    this.categories = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.total = 0,
    this.hasMore = false,
    this.page = 1,
    this.search,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.ordering,
  });

  CatalogState copyWith({
    List<Service>? services,
    List<ServiceCategory>? categories,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? total,
    bool? hasMore,
    int? page,
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String? ordering,
  }) =>
      CatalogState(
        services: services ?? this.services,
        categories: categories ?? this.categories,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        error: error,
        total: total ?? this.total,
        hasMore: hasMore ?? this.hasMore,
        page: page ?? this.page,
        search: search,
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        ordering: ordering,
      );
}

class CatalogNotifier extends StateNotifier<CatalogState> {
  final ServiceRemoteDatasource _serviceDs;
  final CategoryRemoteDatasource _categoryDs;

  CatalogNotifier(this._serviceDs, this._categoryDs)
      : super(const CatalogState()) {
    loadCategories();
    load();
  }

  Future<void> loadCategories() async {
    try {
      final cats = await _categoryDs.getCategories();
      
      // Conversión explícita de Category a ServiceCategory
      final serviceCategories = cats
          .map((c) => ServiceCategory(id: c.id, name: c.name))
          .toList();

      state = state.copyWith(categories: serviceCategories);
    } catch (_) {
      // Ignorar errores silenciosos en la carga de categorías
    }
  }

  Future<void> load({bool reset = true}) async {
    final s = state;
    final page = reset ? 1 : s.page;

    if (reset) {
      state = s.copyWith(isLoading: true, error: null, page: 1);
    } else {
      if (s.isLoadingMore || !s.hasMore) return;
      state = s.copyWith(isLoadingMore: true);
    }

    try {
      final result = await _serviceDs.getServices(
        page: page,
        search: s.search,
        category: s.categoryId,
        ordering: s.ordering,
      );
      state = state.copyWith(
        services: reset ? result.results : [...state.services, ...result.results],
        total: result.count,
        hasMore: result.next != null,
        isLoading: false,
        isLoadingMore: false,
        page: page + 1,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void setSearch(String? value) {
    state = state.copyWith(search: value?.isEmpty == true ? null : value);
    load();
  }

  void setCategory(int? id) {
    state = state.copyWith(categoryId: id);
    load();
  }

  void setPriceRange(double? min, double? max) {
    state = state.copyWith(minPrice: min, maxPrice: max);
    load();
  }

  void setOrdering(String? value) {
    state = state.copyWith(ordering: value);
    load();
  }

  void clearFilters() {
    state = state.copyWith(
      search: null,
      categoryId: null,
      minPrice: null,
      maxPrice: null,
      ordering: null,
    );
    load();
  }

  void loadMore() => load(reset: false);
  Future<void> refresh() => load();
}

final catalogProvider =
    StateNotifierProvider<CatalogNotifier, CatalogState>((ref) {
  return CatalogNotifier(
    ref.watch(serviceDatasourceProvider),
    ref.watch(categoryDatasourceProvider),
  );
});

final categoriesProvider =
    Provider<AsyncValue<List<ServiceCategory>>>((ref) {
  final state = ref.watch(catalogProvider);
  return AsyncValue.data(state.categories);
});