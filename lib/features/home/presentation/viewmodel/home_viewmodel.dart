import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/constants/dimens.dart';
import '../../../../domain/entities/car.dart';
import '../../../../domain/entities/filter.dart';
import '../../../../domain/usecases/cars/get_cars.dart';
import '../../../../domain/usecases/cars/delete_car.dart';
import '../../../../domain/usecases/export/export_cars.dart';

class HomeViewModel extends ChangeNotifier {
  final GetCars getCars;
  final DeleteCar deleteCar;
  final ExportCars exportCars;

  HomeViewModel({
    required this.getCars,
    required this.deleteCar,
    required this.exportCars,
  });

  // State variables
  List<Car> _cars = [];
  List<String> _brands = [];
  List<String> _shapes = [];
  CarFilter _filter = const CarFilter();
  bool _isLoading = false;
  bool _hasMoreData = true;
  String? _errorMessage;
  Timer? _searchTimer;

  // Getters
  List<Car> get cars => _cars;
  List<String> get brands => _brands;
  List<String> get shapes => _shapes;
  CarFilter get filter => _filter;
  bool get isLoading => _isLoading;
  bool get hasMoreData => _hasMoreData;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Load filter options
    final brandsResult = await getCars.repository.getBrands();
    final shapesResult = await getCars.repository.getShapes();

    brandsResult.fold(
          (failure) => _errorMessage = failure.message,
          (brandsList) => _brands = brandsList,
    );

    shapesResult.fold(
          (failure) => _errorMessage = failure.message,
          (shapesList) => _shapes = shapesList,
    );

    // Load first page of cars
    final carsResult = await getCars(
      filter: _filter,
      limit: AppDimens.itemsPerPage,
    );

    _isLoading = false;

    carsResult.fold(
          (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
          (carsList) {
        _cars = carsList;
        _hasMoreData = carsList.length == AppDimens.itemsPerPage;
        notifyListeners();
      },
    );
  }

  Future<void> loadMoreCars() async {
    if (!_hasMoreData || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    final result = await getCars(
      filter: _filter,
      limit: AppDimens.itemsPerPage,
      offset: _cars.length,
    );

    _isLoading = false;

    result.fold(
          (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
          (moreCars) {
        _cars.addAll(moreCars);
        _hasMoreData = moreCars.length == AppDimens.itemsPerPage;
        notifyListeners();
      },
    );
  }

  Future<void> refreshCars() async {
    _cars = [];
    _hasMoreData = true;
    await loadData();
  }

  void updateFilter(CarFilter newFilter) {
    _filter = newFilter;
    refreshCars();
  }

  void onSearchChanged(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      updateFilter(_filter.copyWith(nameQuery: query));
    });
  }

  void clearFilters() {
    updateFilter(const CarFilter());
  }

  Future<bool> deleteCarById(int id) async {
    final result = await deleteCar(id);

    return result.fold(
          (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
          (_) {
        refreshCars();
        return true;
      },
    );
  }

  Future<bool> exportCollection() async {
    final result = await exportCars();

    return result.fold(
          (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
          (success) => success,
    );
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }
}