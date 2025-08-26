import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/providers.dart';
import '../widgets/car_list_item.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/sort_dialog.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_snackbar.dart';
import '../widgets/empty_state.dart';
import 'add_edit_car_screen.dart';
import '../../data/models/car_model.dart';
import '../../data/models/filter_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      ref.read(carNotifierProvider.notifier).loadMoreCars();
    }
  }

  Future<void> _showSortDialog() async {
    final carState = ref.read(carNotifierProvider);
    final result = await showDialog<({SortOption sortBy, bool ascending})>(
      context: context,
      builder: (context) => SortDialog(
        currentSortBy: carState.filter.sortBy,
        currentAscending: carState.filter.sortAscending,
      ),
    );

    if (result != null) {
      ref.read(carNotifierProvider.notifier).setSortOption(
        result.sortBy,
        result.ascending,
      );
    }
  }

  Future<void> _confirmDelete(CarModel car) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la voiture'),
        content: Text('Voulez-vous vraiment supprimer "${car.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(carNotifierProvider.notifier).deleteCar(car.id!);
    }
  }

  Future<void> _exportCollection() async {
    await ref.read(exportNotifierProvider.notifier).exportCollection();
  }

  @override
  Widget build(BuildContext context) {
    final carState = ref.watch(carNotifierProvider);
    final exportState = ref.watch(exportNotifierProvider);

    // Gérer les messages d'erreur et de succès
    ref.listen<CarState>(carNotifierProvider, (previous, next) {
      if (next.error != null) {
        ErrorSnackbar.show(context, next.error!);
        ref.read(carNotifierProvider.notifier).clearError();
      }
    });

    ref.listen<ExportState>(exportNotifierProvider, (previous, next) {
      if (next.error != null) {
        ErrorSnackbar.show(context, next.error!);
        ref.read(exportNotifierProvider.notifier).clearMessages();
      } else if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(exportNotifierProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: _showSortDialog,
            icon: const Icon(Icons.sort),
            tooltip: 'Trier',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _exportCollection();
              } else if (value == 'refresh') {
                ref.read(carNotifierProvider.notifier).refreshCars();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export',
                enabled: !exportState.isExporting,
                child: Row(
                  children: [
                    if (exportState.isExporting)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      const Icon(Icons.share),
                    const SizedBox(width: 8),
                    Text(exportState.isExporting ? 'Export...' : 'Exporter'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Actualiser'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SearchFilterBar(
            brands: carState.brands,
            shapes: carState.shapes,
            filter: carState.filter,
            onFilterChanged: (filter) {
              ref.read(carNotifierProvider.notifier).setFilter(filter);
            },
            onClearFilters: () {
              ref.read(carNotifierProvider.notifier).clearFilters();
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(carNotifierProvider.notifier).refreshCars();
              },
              child: _buildCarList(carState),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddEditCarScreen(),
            ),
          );
        },
        label: const Text('Ajouter'),
        icon: const Icon(Icons.add),
        tooltip: 'Ajouter une nouvelle voiture',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCarList(CarState carState) {
    if (carState.isLoading && carState.cars.isEmpty) {
      return const LoadingIndicator(message: 'Chargement des voitures...');
    }

    if (carState.cars.isEmpty && !carState.isLoading) {
      return EmptyState(
        icon: Icons.directions_car,
        title: 'Aucune voiture',
        subtitle: carState.filter.hasActiveFilters
            ? 'Aucune voiture ne correspond aux filtres'
            : 'Commencez par ajouter votre première voiture',
        actionText: carState.filter.hasActiveFilters ? 'Effacer les filtres' : 'Ajouter une voiture',
        onAction: carState.filter.hasActiveFilters
            ? () => ref.read(carNotifierProvider.notifier).clearFilters()
            : () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddEditCarScreen(),
            ),
          );
        },
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: carState.cars.length + (carState.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == carState.cars.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final car = carState.cars[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: CarListItem(
                  car: car,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddEditCarScreen(existingCar: car),
                      ),
                    );
                  },
                  onDelete: () => _confirmDelete(car),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}