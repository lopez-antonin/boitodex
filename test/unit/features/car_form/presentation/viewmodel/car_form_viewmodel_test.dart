import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:boitodex/core/error/failures.dart';
import 'package:boitodex/domain/entities/car.dart';
import 'package:boitodex/domain/usecases/cars/add_car.dart';
import 'package:boitodex/domain/usecases/cars/update_car.dart';
import 'package:boitodex/domain/usecases/cars/delete_car.dart';
import 'package:boitodex/domain/usecases/media/pick_image.dart';
import 'package:boitodex/features/car_form/presentation/viewmodel/car_form_viewmodel.dart';

import 'car_form_viewmodel_test.mocks.dart';

@GenerateMocks([AddCar, UpdateCar, DeleteCar, PickImage])
void main() {
  group('CarFormViewModel', () {
    late CarFormViewModel viewModel;
    late MockAddCar mockAddCar;
    late MockUpdateCar mockUpdateCar;
    late MockDeleteCar mockDeleteCar;
    late MockPickImage mockPickImage;

    setUp(() {
      mockAddCar = MockAddCar();
      mockUpdateCar = MockUpdateCar();
      mockDeleteCar = MockDeleteCar();
      mockPickImage = MockPickImage();

      viewModel = CarFormViewModel(
        addCar: mockAddCar,
        updateCar: mockUpdateCar,
        deleteCar: mockDeleteCar,
        pickImage: mockPickImage,
      );
    });

    tearDown(() {
      viewModel.dispose();
    });

    final testCar = Car(
      id: 1,
      brand: 'BMW',
      shape: 'Berline',
      name: 'Serie 3',
      informations: 'Belle voiture',
      isPiggyBank: true,
      playsMusic: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('initial state should be correct', () {
      expect(viewModel.isPiggyBank, isFalse);
      expect(viewModel.playsMusic, isFalse);
      expect(viewModel.photoBytes, isNull);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isEditing, isFalse);
    });

    group('initializeWithCar', () {
      test('should initialize with car data for editing', () {
        // act
        viewModel.initializeWithCar(testCar);

        // assert
        expect(viewModel.brandController.text, equals('BMW'));
        expect(viewModel.shapeController.text, equals('Berline'));
        expect(viewModel.nameController.text, equals('Serie 3'));
        expect(viewModel.informationsController.text, equals('Belle voiture'));
        expect(viewModel.isPiggyBank, isTrue);
        expect(viewModel.playsMusic, isFalse);
        expect(viewModel.isEditing, isTrue);
      });

      test('should initialize with empty data for new car', () {
        // act
        viewModel.initializeWithCar(null);

        // assert
        expect(viewModel.brandController.text, isEmpty);
        expect(viewModel.shapeController.text, isEmpty);
        expect(viewModel.nameController.text, isEmpty);
        expect(viewModel.informationsController.text, isEmpty);
        expect(viewModel.isPiggyBank, isFalse);
        expect(viewModel.playsMusic, isFalse);
        expect(viewModel.isEditing, isFalse);
      });
    });

    group('saveCar', () {
      setUp(() {
        viewModel.brandController.text = 'BMW';
        viewModel.shapeController.text = 'Berline';
        viewModel.nameController.text = 'Serie 3';
      });

      test('should add new car successfully', () async {
        // arrange
        when(mockAddCar(any)).thenAnswer((_) async => const Right(1));

        // act
        final result = await viewModel.saveCar();

        // assert
        expect(result, isTrue);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.errorMessage, isNull);
        verify(mockAddCar(any)).called(1);
        verifyNever(mockUpdateCar(any));
      });

      test('should update existing car successfully', () async {
        // arrange
        viewModel.initializeWithCar(testCar);
        when(mockUpdateCar(any)).thenAnswer((_) async => const Right(null));

        // act
        final result = await viewModel.saveCar();

        // assert
        expect(result, isTrue);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.errorMessage, isNull);
        verify(mockUpdateCar(any)).called(1);
        verifyNever(mockAddCar(any));
      });

      test('should return false and set error when add car fails', () async {
        // arrange
        when(mockAddCar(any)).thenAnswer((_) async => const Left(CacheFailure('Save error')));

        // act
        final result = await viewModel.saveCar();

        // assert
        expect(result, isFalse);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.errorMessage, equals('Save error'));
      });

      test('should return false and set error when update car fails', () async {
        // arrange
        viewModel.initializeWithCar(testCar);
        when(mockUpdateCar(any)).thenAnswer((_) async => const Left(CacheFailure('Update error')));

        // act
        final result = await viewModel.saveCar();

        // assert
        expect(result, isFalse);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.errorMessage, equals('Update error'));
      });
    });

    group('deleteCurrentCar', () {
      test('should return false when not editing', () async {
        // act
        final result = await viewModel.deleteCurrentCar();

        // assert
        expect(result, isFalse);
        verifyNever(mockDeleteCar(any));
      });

      test('should delete car successfully when editing', () async {
        // arrange
        viewModel.initializeWithCar(testCar);
        when(mockDeleteCar(1)).thenAnswer((_) async => const Right(null));

        // act
        final result = await viewModel.deleteCurrentCar();

        // assert
        expect(result, isTrue);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.errorMessage, isNull);
        verify(mockDeleteCar(1)).called(1);
      });

      test('should return false and set error when delete fails', () async {
        // arrange
        viewModel.initializeWithCar(testCar);
        when(mockDeleteCar(1)).thenAnswer((_) async => const Left(CacheFailure('Delete error')));

        // act
        final result = await viewModel.deleteCurrentCar();

        // assert
        expect(result, isFalse);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.errorMessage, equals('Delete error'));
      });
    });

    group('pickImageFromGallery', () {
      test('should set photo when pick image succeeds', () async {
        // arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        when(mockPickImage.fromGallery()).thenAnswer((_) async => Right(imageBytes));

        // act
        await viewModel.pickImageFromGallery();

        // assert
        expect(viewModel.photoBytes, equals(imageBytes));
        expect(viewModel.errorMessage, isNull);
        verify(mockPickImage.fromGallery()).called(1);
      });

      test('should set error when pick image fails', () async {
        // arrange
        when(mockPickImage.fromGallery()).thenAnswer((_) async => const Left(ImageProcessingFailure('Pick error')));

        // act
        await viewModel.pickImageFromGallery();

        // assert
        expect(viewModel.photoBytes, isNull);
        expect(viewModel.errorMessage, equals('Pick error'));
      });
    });

    group('pickImageFromCamera', () {
      test('should set photo when take photo succeeds', () async {
        // arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        when(mockPickImage.fromCamera()).thenAnswer((_) async => Right(imageBytes));

        // act
        await viewModel.pickImageFromCamera();

        // assert
        expect(viewModel.photoBytes, equals(imageBytes));
        expect(viewModel.errorMessage, isNull);
        verify(mockPickImage.fromCamera()).called(1);
      });

      test('should set error when take photo fails', () async {
        // arrange
        when(mockPickImage.fromCamera()).thenAnswer((_) async => const Left(ImageProcessingFailure('Camera error')));

        // act
        await viewModel.pickImageFromCamera();

        // assert
        expect(viewModel.photoBytes, isNull);
        expect(viewModel.errorMessage, equals('Camera error'));
      });
    });

    group('setters', () {
      test('should set piggy bank value and notify listeners', () {
        // act
        viewModel.setPiggyBank(true);

        // assert
        expect(viewModel.isPiggyBank, isTrue);
      });

      test('should set plays music value and notify listeners', () {
        // act
        viewModel.setPlaysMusic(true);

        // assert
        expect(viewModel.playsMusic, isTrue);
      });

      test('should set photo bytes and notify listeners', () {
        // arrange
        final photoBytes = Uint8List.fromList([1, 2, 3, 4]);

        // act
        viewModel.setPhoto(photoBytes);

        // assert
        expect(viewModel.photoBytes, equals(photoBytes));
      });

      test('should clear error message', () {
        // act
        viewModel.clearError();

        // assert
        expect(viewModel.errorMessage, isNull);
      });
    });
  });
}