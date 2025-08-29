import 'package:equatable/equatable.dart';

class CarFilter extends Equatable {
  final String? brand;
  final String? shape;
  final String nameQuery;
  final SortOption sortBy;
  final bool sortAscending;

  const CarFilter({
    this.brand,
    this.shape,
    this.nameQuery = '',
    this.sortBy = SortOption.name,
    this.sortAscending = true,
  });

  CarFilter copyWith({
    String? brand,
    String? shape,
    String? nameQuery,
    SortOption? sortBy,
    bool? sortAscending,
  }) {
    return CarFilter(
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

  @override
  List<Object?> get props => [brand, shape, nameQuery, sortBy, sortAscending];
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