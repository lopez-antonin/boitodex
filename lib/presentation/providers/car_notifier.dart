import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/car_model.dart';
import '../../data/models/filter_model.dart';
import '../../data/repositories/car_repository.dart';
import '../../core/constants/app_constants.dart';

class CarState {
  final List<CarModel> cars;
  final List<String> brands;
  final List<String> shapes;
  final FilterModel filter;
  final bool isLoading;
  final String? error;
  final int totalCount;
  final bool hasMoreData;

  const CarState({
    this.cars = const [],
    this.brands = const [],
    this.shapes = const [],
    this.filter = const FilterModel(),
    this.isLoading = false,
    this.error,
    this.totalCount = 0,
    this.hasMoreData = true,
  });

  CarState copyWith({
    List<CarModel>? cars,
    List<String>? brands,
    List<String>? shapes,
    FilterModel? filter,
    bool? isLoading,
    String? error,
    int? totalCount,
    bool? hasMoreData,
  }) {
    return CarState(
      cars: cars ?? this.cars,
      brands: brands ?? this.brands,
      shapes: shapes ?? this.shapes,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalCount: totalCount ?? this.totalCount,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}

class CarNotifier extends StateNotifier<CarState> {
  final CarRepository _repository;

  CarNotifier(this._repository) : super(const CarState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    await Future.wait([
      _loadFilters(),
      _loadCars(reset: true),
    ]);

    state = state.copyWith(isLoading: false);
  }

  Future<void> _loadFilters() async {
    final brandsResult = await _repository.getDistinctBrands();
    final shapesResult = await _repository.getDistinctShapes();

    if (brandsResult.isSuccess && shapesResult.isSuccess) {
      state = state.copyWith(
        brands: brandsResult.data!,
        shapes: shapesResult.data!,
      );
    }
  }

  Future<void> _loadCars({bool reset = false}) async {
    if (reset) {
      state = state.copyWith(cars: [], hasMoreData: true);
    }

    if (!state.hasMoreData) return;

    final offset = reset ? 0 : state.cars.length;

    final carsResult = await _repository.getAllCars(
      filter: state.filter,
      limit: AppConstants.itemsPerPage,
      offset: offset,
    );

    final countResult = await _repository.getCarCount(filter: state.filter);

    if (carsResult.isSuccess && countResult.isSuccess) {
      final newCars = carsResult.data!;
      final totalCount = countResult.data!;

      final allCars = reset ? newCars : [...state.cars, ...newCars];
      final hasMoreData = allCars.length < totalCount;

      state = state.copyWith(
        cars: allCars,
        totalCount: totalCount,
        hasMoreData: hasMoreData,
        error: null,
      );
    } else {
      state = state.copyWith(
        error: carsResult.error ?? countResult.error,
      );
    }
  }

  Future<void> addCar(CarModel car) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.insertCar(car);

    if (result.isSuccess) {
      await Future.wait([
        _loadFilters(),
        _loadCars(reset: true),
      ]);
      state = state.copyWith(isLoading: false, error: null);
    } else {
      state = state.copyWith(isLoading: false, error: result.error);
    }
  }

  Future<void> updateCar(CarModel car) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.updateCar(car);

    if (result.isSuccess) {
      await Future.wait([
        _loadFilters(),
        _loadCars(reset: true),
      ]);
      state = state.copyWith(isLoading: false, error: null);
    } else {
      state = state.copyWith(isLoading: false, error: result.error);
    }
  }

  Future<void> deleteCar(int id) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.deleteCar(id);

    if (result.isSuccess) {
      await Future.wait([
        _loadFilters(),
        _loadCars(reset: true),
      ]);
      state = state.copyWith(isLoading: false, error: null);
    } else {
      state = state.copyWith(isLoading: false, error: result.error);
    }
  }

  Future<CarModel?> getCarById(int id) async {
    final result = await _repository.getCarById(id);
    return result.data;
  }

  void setFilter(FilterModel newFilter) {
    if (state.filter != newFilter) {
      state = state.copyWith(filter: newFilter);
      _loadCars(reset: true);
    }
  }

  void setBrandFilter(String? brand) {
    final newFilter = state.filter.copyWith(brand: brand);
    setFilter(newFilter);
  }

  void setShapeFilter(String? shape) {
    final newFilter = state.filter.copyWith(shape: shape);
    setFilter(newFilter);
  }

  void setNameQuery(String query) {
    final newFilter = state.filter.copyWith(nameQuery: query);
    setFilter(newFilter);
  }

  void setSortOption(SortOption sortBy, bool ascending) {
    final newFilter = state.filter.copyWith(
      sortBy: sortBy,
      sortAscending: ascending,
    );
    setFilter(newFilter);
  }

  void clearFilters() {
    setFilter(const FilterModel());
  }

  Future<void> loadMoreCars() async {
    if (!state.hasMoreData || state.isLoading) return;
    await _loadCars();
  }

  Future<void> refreshCars() async {
    await Future.wait([
      _loadFilters(),
      _loadCars(reset: true),
    ]);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}