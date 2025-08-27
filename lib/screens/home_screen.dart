import 'dart:async';
import 'package:flutter/material.dart';
import '../services/car_service.dart';
import '../services/export_service.dart';
import '../models/car.dart';
import '../models/filter.dart';
import '../core/constants.dart';
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

  /// Show sort dialog
  Future<void> _showSortDialog() async {
    final result = await showDialog<({SortOption sortBy, bool ascending})>(
      context: context,
      builder: (context) => _SortDialog(
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Collection exportée!' : 'Erreur lors de l\'export'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// Delete car with confirmation
  Future<void> _deleteCar(Car car) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la voiture'),
        content: Text('Voulez-vous vraiment supprimer "${car.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _carService.deleteCar(car.id!);
      if (success) {
        _refreshCars();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voiture supprimée')),
          );
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
          _buildSearchAndFilter(),

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

  /// Build search and filter widgets
  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Rechercher',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _filter.nameQuery.isNotEmpty
                  ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  _updateFilter(_filter.copyWith(nameQuery: ''));
                },
                icon: const Icon(Icons.clear),
              )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 16),

          // Filter dropdowns
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _filter.brand,
                  decoration: const InputDecoration(
                    labelText: 'Marque',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Toutes'),
                    ),
                    ..._brands.map((brand) => DropdownMenuItem<String>(
                      value: brand,
                      child: Text(brand),
                    )),
                  ],
                  onChanged: (value) {
                    _updateFilter(_filter.copyWith(brand: value));
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _filter.shape,
                  decoration: const InputDecoration(
                    labelText: 'Forme',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Toutes'),
                    ),
                    ..._shapes.map((shape) => DropdownMenuItem<String>(
                      value: shape,
                      child: Text(shape),
                    )),
                  ],
                  onChanged: (value) {
                    _updateFilter(_filter.copyWith(shape: value));
                  },
                ),
              ),
            ],
          ),

          // Clear filters button
          if (_filter.hasActiveFilters) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _updateFilter(const CarFilter());
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Effacer les filtres'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build the car list
  Widget _buildCarList() {
    if (_isLoading && _cars.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cars.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _filter.hasActiveFilters
                  ? 'Aucune voiture ne correspond aux filtres'
                  : 'Aucune voiture dans la collection',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
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
        return _CarListItem(
          car: car,
          onTap: () => _navigateToCarForm(car),
          onDelete: () => _deleteCar(car),
        );
      },
    );
  }
}

/// Sort dialog widget
class _SortDialog extends StatefulWidget {
  final SortOption currentSortBy;
  final bool currentAscending;

  const _SortDialog({
    required this.currentSortBy,
    required this.currentAscending,
  });

  @override
  State<_SortDialog> createState() => _SortDialogState();
}

class _SortDialogState extends State<_SortDialog> {
  late SortOption _selectedSortBy;
  late bool _ascending;

  @override
  void initState() {
    super.initState();
    _selectedSortBy = widget.currentSortBy;
    _ascending = widget.currentAscending;
  }

  String getSortSubtitle(SortOption option, bool ascending) {
    switch (option) {
      case SortOption.name:
      case SortOption.brand:
      case SortOption.shape:
        return ascending ? 'A → Z' : 'Z → A';
      case SortOption.createdAt:
      case SortOption.updatedAt:
        return ascending ? 'Ancien → Récent' : 'Récent → Ancien';
      }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Trier par'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sort options
          ...SortOption.values.map((option) => RadioListTile<SortOption>(
            title: Text(option.displayName),
            value: option,
            groupValue: _selectedSortBy,
            onChanged: (value) {
              setState(() => _selectedSortBy = value!);
            },
          )),
          const Divider(),

          // Ascending/Descending toggle
          SwitchListTile(
            title: const Text('Ordre croissant'),
            subtitle: Text(getSortSubtitle(_selectedSortBy, _ascending)),
            value: _ascending,
            onChanged: (value) {
              setState(() => _ascending = value);
            },
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, (
            sortBy: _selectedSortBy,
            ascending: _ascending,
            ));
          },
          child: const Text('Appliquer'),
        ),
      ],
    );
  }
}

/// Individual car list item widget
class _CarListItem extends StatelessWidget {
  final Car car;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CarListItem({
    required this.car,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildCarImage(),
        title: Text(
          car.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${car.brand} • ${car.shape}'),
            if (car.informations?.isNotEmpty ?? false)
              Text(
                car.informations!,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (car.isPiggyBank || car.playsMusic) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (car.isPiggyBank) ...[
                    const Icon(Icons.savings, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    const Text('Tirelire', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 12),
                  ],
                  if (car.playsMusic) ...[
                    const Icon(Icons.music_note, size: 16, color: Colors.purple),
                    const SizedBox(width: 4),
                    const Text('Musique', style: TextStyle(fontSize: 12)),
                  ],
                ],
              ),
            ],
          ],
        ),
        trailing: IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          color: Colors.red,
        ),
        onTap: onTap,
      ),
    );
  }

  /// Build car image or placeholder
  Widget _buildCarImage() {
    if (car.photo != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          car.photo!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    }
    return _buildPlaceholder();
  }

  /// Build placeholder when no image
  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.directions_car, color: Colors.grey),
    );
  }
}