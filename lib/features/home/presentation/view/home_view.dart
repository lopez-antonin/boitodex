import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/constants/strings.dart';
import '../../../../app/di/injection.dart';
import '../../../../core/shared/widgets/loading_widget.dart';
import '../../../../core/shared/widgets/error_widget.dart';
import '../../../../domain/entities/car.dart';
import '../../../../domain/entities/filter.dart';
import '../../../car_form/presentation/view/car_form_view.dart';
import '../viewmodel/home_viewmodel.dart';
import '../widgets/car_list_item.dart';
import '../widgets/empty_state.dart';
import '../widgets/search_filter.dart';
import '../widgets/sort_dialog.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = locator<HomeViewModel>();
    _scrollController.addListener(_onScroll);
    _viewModel.loadData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _viewModel.loadMoreCars();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.collection),
          actions: [
            IconButton(
              onPressed: _showSortDialog,
              icon: const Icon(Icons.sort),
            ),
            PopupMenuButton<String>(
              onSelected: _onMenuSelected,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text(AppStrings.export),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text(AppStrings.refresh),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.errorMessage != null) {
              return CustomErrorWidget(
                message: viewModel.errorMessage!,
                onRetry: () {
                  viewModel.clearError();
                  viewModel.loadData();
                },
              );
            }

            return Column(
              children: [
                SearchFilterWidget(
                  searchController: _searchController,
                  filter: viewModel.filter,
                  brands: viewModel.brands,
                  shapes: viewModel.shapes,
                  onSearchChanged: viewModel.onSearchChanged,
                  onFilterChanged: viewModel.updateFilter,
                  onClearFilters: () {
                    _searchController.clear();
                    viewModel.clearFilters();
                  },
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: viewModel.refreshCars,
                    child: _buildCarList(viewModel),
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToCarForm(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildCarList(HomeViewModel viewModel) {
    if (viewModel.isLoading && viewModel.cars.isEmpty) {
      return const LoadingWidget();
    }

    if (viewModel.cars.isEmpty && !viewModel.isLoading) {
      return EmptyStateWidget(hasActiveFilters: viewModel.filter.hasActiveFilters);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: viewModel.cars.length + (viewModel.hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == viewModel.cars.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final car = viewModel.cars[index];
        return CarListItem(
          car: car,
          onTap: () => _navigateToCarForm(car),
          onDelete: () => _deleteCar(car),
        );
      },
    );
  }

  Future<void> _showSortDialog() async {
    final result = await showDialog<({SortOption sortBy, bool ascending})>(
      context: context,
      builder: (context) => SortDialog(
        currentSortBy: _viewModel.filter.sortBy,
        currentAscending: _viewModel.filter.sortAscending,
      ),
    );

    if (result != null) {
      _viewModel.updateFilter(_viewModel.filter.copyWith(
        sortBy: result.sortBy,
        sortAscending: result.ascending,
      ));
    }
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'export':
        _exportCollection();
        break;
      case 'refresh':
        _viewModel.refreshCars();
        break;
    }
  }

  Future<void> _exportCollection() async {
    final success = await _viewModel.exportCollection();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? AppStrings.exportSuccess : 'Erreur lors de l\'export'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteCar(Car car) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la voiture'),
        content: Text('Voulez-vous vraiment supprimer "${car.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _viewModel.deleteCarById(car.id!);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voiture supprimée'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _navigateToCarForm([Car? car]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarFormView(car: car),
      ),
    );

    if (result == true) {
      _viewModel.refreshCars();
    }
  }
}