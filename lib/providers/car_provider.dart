import 'package:flutter/foundation.dart';
import '../data/car_database.dart';
import '../models/car.dart';

class CarProvider extends ChangeNotifier {
  final CarDatabase _db = CarDatabase();

  List<Car> _cars = [];
  List<Car> get cars => List.unmodifiable(_cars);

  // filter/search state
  String? _brandFilter;
  String? get brandFilter => _brandFilter;

  String? _shapeFilter;
  String? get shapeFilter => _shapeFilter;

  String _nameQuery = '';
  String get nameQuery => _nameQuery;

  List<String> _availableBrands = [];
  List<String> get availableBrands => List.unmodifiable(_availableBrands);

  List<String> _availableShapes = [];
  List<String> get availableShapes => List.unmodifiable(_availableShapes);

  CarProvider() {
    _init();
  }

  Future<void> _init() async {
    await loadFilters();
    await loadCars();
  }

  Future<void> loadFilters() async {
    _availableBrands = await _db.getDistinctBrands();
    _availableShapes = await _db.getDistinctShapes();
    notifyListeners();
  }

  Future<void> loadCars() async {
    final list = await _db.getAllCars(
      brand: _brandFilter,
      shape: _shapeFilter,
      nameQuery: _nameQuery.isNotEmpty ? _nameQuery : null,
    );
    _cars = list;
    notifyListeners();
  }

  Future<void> addCar({
    required String brand,
    required String shape,
    required String name,
    required bool isPiggyBank,
    required bool playsMusic,
    Uint8List? photo,
  }) async {
    final car = Car(
      brand: brand,
      shape: shape,
      name: name,
      isPiggyBank: isPiggyBank,
      playsMusic: playsMusic,
      photo: photo,
    );
    await _db.insertCar(car);
    await loadFilters();
    await loadCars();
  }

  Future<void> updateCar(Car car) async {
    await _db.updateCar(car);
    await loadFilters();
    await loadCars();
  }

  Future<void> deleteCar(int id) async {
    await _db.deleteCar(id);
    await loadFilters();
    await loadCars();
  }

  void setBrandFilter(String? brand) {
    _brandFilter = (brand == null || brand.isEmpty) ? null : brand;
    loadCars();
  }

  void setShapeFilter(String? shape) {
    _shapeFilter = (shape == null || shape.isEmpty) ? null : shape;
    loadCars();
  }

  void setNameQuery(String query) {
    _nameQuery = query;
    loadCars();
  }

  Future<Car?> getCarById(int id) async {
    return await _db.getCarById(id);
  }
}
