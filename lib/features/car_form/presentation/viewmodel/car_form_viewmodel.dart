import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../domain/entities/car.dart';
import '../../../../domain/usecases/cars/add_car.dart';
import '../../../../domain/usecases/cars/update_car.dart';
import '../../../../domain/usecases/cars/delete_car.dart';
import '../../../../domain/usecases/media/pick_image.dart';

class CarFormViewModel extends ChangeNotifier {
  final AddCar addCar;
  final UpdateCar updateCar;
  final DeleteCar deleteCar;
  final PickImage pickImage;

  CarFormViewModel({
    required this.addCar,
    required this.updateCar,
    required this.deleteCar,
    required this.pickImage,
  });

  // Form controllers
  final brandController = TextEditingController();
  final shapeController = TextEditingController();
  final nameController = TextEditingController();
  final informationsController = TextEditingController();

  // Form state
  bool _isPiggyBank = false;
  bool _playsMusic = false;
  Uint8List? _photoBytes;
  bool _isLoading = false;
  String? _errorMessage;
  Car? _currentCar;

  // Getters
  bool get isPiggyBank => _isPiggyBank;
  bool get playsMusic => _playsMusic;
  Uint8List? get photoBytes => _photoBytes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEditing => _currentCar != null;

  // Setters
  void setPiggyBank(bool value) {
    _isPiggyBank = value;
    notifyListeners();
  }

  void setPlaysMusic(bool value) {
    _playsMusic = value;
    notifyListeners();
  }

  void setPhoto(Uint8List? bytes) {
    _photoBytes = bytes;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void initializeWithCar(Car? car) {
    _currentCar = car;
    if (car != null) {
      brandController.text = car.brand;
      shapeController.text = car.shape;
      nameController.text = car.name;
      informationsController.text = car.informations ?? '';
      _isPiggyBank = car.isPiggyBank;
      _playsMusic = car.playsMusic;
      _photoBytes = car.photo;
    }
    notifyListeners();
  }

  Future<bool> saveCar() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final car = Car(
      id: isEditing ? _currentCar!.id : null,
      brand: brandController.text.trim(),
      shape: shapeController.text.trim(),
      name: nameController.text.trim(),
      informations: informationsController.text.trim().isEmpty
          ? null
          : informationsController.text.trim(),
      isPiggyBank: _isPiggyBank,
      playsMusic: _playsMusic,
      photo: _photoBytes,
      createdAt: isEditing ? _currentCar!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = isEditing
        ? await updateCar(car)
        : await addCar(car);

    _isLoading = false;

    return result.fold(
          (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
          (_) {
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> deleteCurrentCar() async {
    if (!isEditing) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await deleteCar(_currentCar!.id!);

    _isLoading = false;

    return result.fold(
          (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
          (_) {
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> pickImageFromGallery() async {
    final result = await pickImage.fromGallery();
    result.fold(
          (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
          (imageBytes) {
        _photoBytes = imageBytes;
        notifyListeners();
      },
    );
  }

  Future<void> pickImageFromCamera() async {
    final result = await pickImage.fromCamera();
    result.fold(
          (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
          (imageBytes) {
        _photoBytes = imageBytes;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    brandController.dispose();
    shapeController.dispose();
    nameController.dispose();
    informationsController.dispose();
    super.dispose();
  }
}