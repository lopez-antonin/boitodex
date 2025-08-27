import 'dart:async';
import 'package:flutter/material.dart';
import '../services/car_service.dart';
import '../services/export_service.dart';
import '../models/car.dart';
import '../models/filter.dart';
import '../core/constants/app_constants.dart';
import '../core/dialogs.dart';
import '../widgets/car_list_item.dart';
import '../widgets/sort_dialog.dart';
import '../widgets/search_filter_widget.dart';
import '../widgets/empty_state_widget.dart';
import 'car_form_screen.dart';

/// Main screen displaying the car collection
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CarService _carService = CarService();
  final ExportService _exportService = ExportService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // State variables
  List<Car> _cars = [];
  List<String> _brands = [];
  List<String> _shapes = [];
  CarFilter _filter = const CarFilter();
  bool _isLoading = false;
  bool _hasMoreData = true;
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  /// Handle scroll events for pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _loadMoreCars();
    }
  }

  /// Load initial data (brands, shapes, and first page of cars)
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load filter options
    final brands = await _carService.getBrands();
    final shapes = await _carService.getShapes();

    // Load first page of cars
    final cars = await _carService.getCars(
      filter: _filter,
      limit: AppConstants.itemsPerPage,
    );

    setState(() {
      _brands = brands;
      _shapes = shapes;
      _cars = cars;
      _hasMoreData = cars.length == AppConstants.itemsPerPage;
      _isLoading = false;
    });
  }

  /// Load more cars for pagination
  Future<void> _loadMoreCars() async {
    if (!_hasMoreData || _isLoading) return;

    setState(() => _isLoading = true);

    final moreCars = await _carService.getCars(
      filter: _filter,
      limit: AppConstants.itemsPerPage,
      offset: _cars.length,
    );

    setState(() {
      _cars.addAll(moreCars);
      _hasMoreData = moreCars.length == AppConstants.itemsPerPage;
      _isLoading = false;
    });
  }

  /// Refresh the entire list
  Future<void> _refreshCars() async {
    setState(() {
      _cars = [];
      _hasMoreData = true;
    });
    await _loadData();
  }

  /// Update filter and reload cars
  void _updateFilter(CarFilter newFilter) {
    _filter = newFilter;
    _refreshCars();
  }

  /// Handle search input with debouncing
  void _onSearchChanged(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      _updateFilter(_filter.copyWith(nameQuery: query));
    });
  }

  /// Clear all filters
  void _clearFilters() {
    _searchController.clear();
    _updateFilter(const CarFilter());
  }

  /// Show sort dialog
  Future<void> _showSortDialog() async {
    final result = await showDialog<({SortOption sortBy, bool ascending})>(
      context: context,
      builder: (context) => SortDialog(
        currentSortBy: _filter.sortBy,
        currentAscending: _filter.sortAscending,
      ),
    );

    if (result != null) {
      _updateFilter(_filter.copyWith(
        sortBy: result.sortBy,
        sortAscending: result.ascending,
      ));
    }
  }

  /// Export collection
  Future<void> _exportCollection() async {
    final cars = await _carService.getAllCarsForExport();
    final success = await _exportService.exportCars(cars);

    if (mounted) {
      if (success) {
        Dialogs.showSuccessSnackBar(context, 'Collection exportée!');
      } else {
        Dialogs.showErrorSnackBar(context, 'Erreur lors de l\'export');
      }
    }
  }

  /// Delete car with confirmation
  Future<void> _deleteCar(Car car) async {
    final confirm = await Dialogs.showDeleteCarDialog(context, car.name);

    if (confirm) {
      final success = await _carService.deleteCar(car.id!);
      if (success) {
        _refreshCars();
        if (mounted) {
          Dialogs.showSuccessSnackBar(context, 'Voiture supprimée');
        }
      }
    }
  }

  /// Navigate to add/edit car screen
  Future<void> _navigateToCarForm([Car? car]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarFormScreen(car: car),
      ),
    );

    // Refresh list if a car was added/updated
    if (result == true) {
      _refreshCars();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection'),
        actions: [
          IconButton(
            onPressed: _showSortDialog,
            icon: const Icon(Icons.sort),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _exportCollection();
              } else if (value == 'refresh') {
                _refreshCars();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Exporter'),
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
          // Search and filter section
          SearchFilterWidget(
            searchController: _searchController,
            filter: _filter,
            brands: _brands,
            shapes: _shapes,
            onSearchChanged: _onSearchChanged,
            onFilterChanged: _updateFilter,
            onClearFilters: _clearFilters,
          ),

          // Car list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshCars,
              child: _buildCarList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCarForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Build the car list
  Widget _buildCarList() {
    if (_isLoading && _cars.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cars.isEmpty && !_isLoading) {
      return EmptyStateWidget(hasActiveFilters: _filter.hasActiveFilters);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 80), // Space for FAB
      itemCount: _cars.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the end
        if (index == _cars.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final car = _cars[index];
        return CarListItem(
          car: car,
          onTap: () => _navigateToCarForm(car),
          onDelete: () => _deleteCar(car),
        );
      },
    );
  }
}