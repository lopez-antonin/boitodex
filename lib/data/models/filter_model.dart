import '../../domain/entities/filter.dart';

class FilterModel extends CarFilter {
  const FilterModel({
    super.brand,
    super.shape,
    super.nameQuery = '',
    super.sortBy = SortOption.name,
    super.sortAscending = true,
  });

  factory FilterModel.fromEntity(CarFilter filter) {
    return FilterModel(
      brand: filter.brand,
      shape: filter.shape,
      nameQuery: filter.nameQuery,
      sortBy: filter.sortBy,
      sortAscending: filter.sortAscending,
    );
  }
}