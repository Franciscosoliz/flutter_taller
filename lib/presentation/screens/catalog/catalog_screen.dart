// lib/presentation/screens/catalog/catalog_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_colors.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/filters_sheet.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/service_card.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(catalogProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final state = ref.read(catalogProvider);
    final activeFilters = ServiceFilters(
      categoryId: state.categoryId,
      ordering: state.ordering,
      minPrice: state.minPrice,
      maxPrice: state.maxPrice,
    );
    final result = await showFiltersSheet(
      context: context,
      activeFilters: activeFilters,
      categories: state.categories,
    );
    if (result != null && mounted) {
      ref.read(catalogProvider.notifier).setCategory(result.categoryId);
      ref.read(catalogProvider.notifier).setOrdering(result.ordering);
      ref.read(catalogProvider.notifier).setPriceRange(result.minPrice, result.maxPrice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogProvider);
    final numFilters = _countActiveFilters(state);

    if (state.isLoading && state.services.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }
    if (state.error != null && state.services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('❌', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(state.error!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(catalogProvider.notifier).refresh(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: ref.read(catalogProvider.notifier).refresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Búsqueda y Botón de Filtros
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: ServiceSearchBar(
                      initialValue: state.search,
                      onChanged: (q) =>
                          ref.read(catalogProvider.notifier).setSearch(q),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Stack(
                    children: [
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: numFilters > 0
                              ? AppColors.accent
                              : AppColors.surface,
                          foregroundColor: numFilters > 0
                              ? AppColors.onAccent
                              : AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.border),
                          ),
                        ),
                        icon: const Icon(Icons.tune_rounded),
                        onPressed: _openFilters,
                      ),
                      if (numFilters > 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$numFilters',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Total de resultados
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${state.total} servicio${state.total != 1 ? 's' : ''} encontrado${state.total != 1 ? 's' : ''}',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ),

          // Grid de Servicios
          if (state.services.isEmpty && !state.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🔧', style: TextStyle(fontSize: 52)),
                    SizedBox(height: 16),
                    Text(
                      'No hay servicios disponibles',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final service = state.services[i];
                    return ServiceCard(
                      service: service,
                      onTap: () => context.push('/catalog/${service.id}'),
                    );
                  },
                  childCount: state.services.length,
                ),
              ),
            ),

          if (state.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  int _countActiveFilters(CatalogState state) {
    int count = 0;
    if (state.categoryId != null) count++;
    if (state.ordering != null) count++;
    if (state.minPrice != null) count++;
    if (state.maxPrice != null) count++;
    return count;
  }
}