import 'package:flutter/material.dart';
import '../../../../app/constants/strings.dart';
import '../../../../domain/entities/filter.dart';

class SearchFilterWidget extends StatelessWidget {
  final TextEditingController searchController;
  final CarFilter filter;
  final List<String> brands;
  final List<String> shapes;
  final Function(String) onSearchChanged;
  final Function(CarFilter) onFilterChanged;
  final VoidCallback onClearFilters;

  const SearchFilterWidget({
    super.key,
    required this.searchController,
    required this.filter,
    required this.brands,
    required this.shapes,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: AppStrings.search,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: filter.nameQuery.isNotEmpty
                  ? IconButton(
                onPressed: () {
                  searchController.clear();
                  onFilterChanged(filter.copyWith(nameQuery: ''));
                },
                icon: const Icon(Icons.clear),
              )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: filter.brand,
                  decoration: const InputDecoration(
                    labelText: AppStrings.brand,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Toutes'),
                    ),
                    ...brands.map((brand) => DropdownMenuItem<String>(
                      value: brand,
                      child: Text(brand),
                    )),
                  ],
                  onChanged: (value) {
                    onFilterChanged(filter.copyWith(brand: value));
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: filter.shape,
                  decoration: const InputDecoration(
                    labelText: AppStrings.shape,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Toutes'),
                    ),
                    ...shapes.map((shape) => DropdownMenuItem<String>(
                      value: shape,
                      child: Text(shape),
                    )),
                  ],
                  onChanged: (value) {
                    onFilterChanged(filter.copyWith(shape: value));
                  },
                ),
              ),
            ],
          ),
          if (filter.hasActiveFilters) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('Effacer les filtres'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}