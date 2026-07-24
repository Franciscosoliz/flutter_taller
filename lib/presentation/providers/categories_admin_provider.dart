import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/api/service_remote_datasource.dart';
import '../../domain/model/service.dart';

class CategoriesAdminState {
  final List<ServiceCategory> categories;
  final bool isLoading;
  final String? error;

  const CategoriesAdminState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoriesAdminState copyWith({
    List<ServiceCategory>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoriesAdminState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CategoriesAdminNotifier extends StateNotifier<CategoriesAdminState> {
  final ServiceRemoteDatasource _datasource;

  CategoriesAdminNotifier(this._datasource) : super(const CategoriesAdminState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _datasource.getCategories();
      state = state.copyWith(categories: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}

final categoriesAdminProvider =
    StateNotifierProvider<CategoriesAdminNotifier, CategoriesAdminState>((ref) {
  return CategoriesAdminNotifier(ref.watch(serviceDatasourceProvider));
});