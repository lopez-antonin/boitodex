import 'package:flutter/material.dart';
import '../../data/models/filter_model.dart';
import 'dart:async';

class SearchFilterBar extends StatefulWidget {
  final List<String> brands;
  final List<String> shapes;
  final FilterModel filter;
  final ValueChanged<FilterModel> onFilterChanged;
  final VoidCallback onClearFilters;

  const SearchFilterBar({
    super.key,
    required this.brands,
    required this.shapes,
    required this.filter,
    required this.onFilterChanged,
    required this.onClearFilters,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  late TextEditingController _searchController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.filter.nameQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        widget.onFilterChanged(widget.filter.copyWith(nameQuery: query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Rechercher par nom',
              hintText: 'Tapez le nom d\'une voiture...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: widget.filter.nameQuery.isNotEmpty
                  ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  widget.onFilterChanged(
                    widget.filter.copyWith(nameQuery: ''),
                  );
                },
                icon: const Icon(Icons.clear),
              )
                  : null,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 16),
          // Filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: widget.filter.brand,
                  decoration: const InputDecoration(
                    labelText: 'Marque',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Toutes les marques'),
                    ),
                    ...widget.brands.map((brand) => DropdownMenuItem<String>(
                      value: brand,
                      child: Text(brand),
                    )),
                  ],
                  onChanged: (value) {
                    widget.onFilterChanged(widget.filter.copyWith(brand: value));
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: widget.filter.shape,
                  decoration: const InputDecoration(
                    labelText: 'Forme',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Toutes les formes'),
                    ),
                    ...widget.shapes.map((shape) => DropdownMenuItem<String>(
                      value: shape,
                      child: Text(shape),
                    )),
                  ],
                  onChanged: (value) {
                    widget.onFilterChanged(widget.filter.copyWith(shape: value));
                  },
                ),
              ),
            ],
          ),
          // Clear filters button
          if (widget.filter.hasActiveFilters) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  widget.onClearFilters();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Effacer tous les filtres'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}