class FilterModel {
  final String? brand;
  final String? shape;
  final String nameQuery;
  final SortOption sortBy;
  final bool sortAscending;

  const FilterModel({
    this.brand,
    this.shape,
    this.nameQuery = '',
    this.sortBy = SortOption.name,
    this.sortAscending = true,
  });

  FilterModel copyWith({
    String? brand,
    String? shape,
    String? nameQuery,
    SortOption? sortBy,
    bool? sortAscending,
  }) {
    return FilterModel(
      brand: brand ?? this.brand,
      shape: shape ?? this.shape,
      nameQuery: nameQuery ?? this.nameQuery,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  bool get hasActiveFilters =>
      brand != null ||
          shape != null ||
          nameQuery.isNotEmpty;
}

enum SortOption {
  name('Nom'),
  brand('Marque'),
  shape('Forme'),
  createdAt('Date de création'),
  updatedAt('Date de modification');

  const SortOption(this.displayName);
  final String displayName;
}