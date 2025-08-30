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

  final tDateTime = DateTime(2023, 1, 1);
  final tCar = Car(
    id: 1,
    brand: 'BMW',
    shape: 'Sedan',
    name: 'X5',
    informations: 'Test info',
    isPiggyBank: true,
    playsMusic: false,
    createdAt: tDateTime,
    updatedAt: tDateTime,
  );

  final tPhotoBytes = Uint8List.fromList([1, 2, 3, 4]);

  group('CarFormViewModel', () {
    group('initializeWithCar', () {
      test('should initialize form with empty values when car is null', () {
        // act
        viewModel.initializeWithCar(null);

        // assert
        expect(viewModel.brandController.text, '');
        expect(viewModel.shapeController.text, '');
        expect(viewModel.nameController.text, '');
        expect(viewModel.informationsController.text, '');
        expect(viewModel.isPiggyBank, false);
        expect(viewModel.playsMusic, false);
        expect(viewModel.photoBytes, null);
        expect(viewModel.isEditing, false);
      });

      test('should initialize form with car data when car is provided', () {
        // act
        viewModel.initializeWithCar(tCar);

        // assert
        expect(viewModel.brandController.text, 'BMW');
        expect(viewModel.shapeController.text, 'Sedan');
        expect(viewModel.nameController.text, 'X5');
        expect(viewModel.informationsController.text, 'Test info');
        expect(viewModel.isPiggyBank, true);
        expect(viewModel.playsMusic, false);
        expect(viewModel.isEditing, true);
      });
    });

    group('setters', () {
      test('should update isPiggyBank and notify listeners', () {
        // arrange
        var listenerCalled = false;
        viewModel.addListener(() => listenerCalled = true);

        // act
        viewModel.setPiggyBank(true);

        // assert
        expect(viewModel.isPiggyBank, true);
        expect(listenerCalled, true);
      });

      test('should update playsMusic and notify listeners', () {
        // arrange
        var listenerCalled = false;
        viewModel.addListener(() => listenerCalled = true);

        // act
        viewModel.setPlaysMusic(true);

        // assert
        expect(viewModel.playsMusic, true);
        expect(listenerCalled, true);
      });

      test('should update photo and notify listeners', () {
        // arrange
        var listenerCalled = false;
        viewModel.addListener(() => listenerCalled = true);

        // act
        viewModel.setPhoto(tPhotoBytes);

        // assert
        expect(viewModel.photoBytes, tPhotoBytes);
        expect(listenerCalled, true);
      });
    });

    group('saveCar', () {
      setUp(() {
        viewModel.brandController.text = 'BMW';
        viewModel.shapeController.text = 'Sedan';
        viewModel.nameController.text = 'X5';
        viewModel.informationsController.text = 'Test info';
      });

      test('should add car successfully when not editing', () async {
        // arrange
        when(mockAddCar(any))
            .thenAnswer((_) async => const Right(1));

        // act
        final result = await viewModel.saveCar();

        // assert
        expect(result, true);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, null);
        verify(mockAddCar(any));
        verifyNever(mockUpdateCar(any));
      });

      test('should update car successfully when editing', () async {
        // arrange
        viewModel.initializeWithCar(tCar);
        when(mockUpdateCar(any))
            .thenAnswer((_) async => const Right(null));

        // act
        final result = await viewModel.saveCar();

        // assert
        expect(result, true);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, null);
        verify(mockUpdateCar(any));
        verifyNever(mockAddCar(any));
      });

      test('should return false and set error when add car fails', () async {
        // arrange
        when(mockAddCar(any))
            .thenAnswer((_) async => const Left(CacheFailure('Add failed')));

        // act
        final result = await viewModel.saveCar();

        // assert
        expect(result, false);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, 'Add failed');
      });

      test('should return false and set error when update car fails', () async {
        // arrange
        viewModel.initializeWithCar(tCar);
        when(mockUpdateCar(any))
            .thenAnswer((_) async => const Left(CacheFailure('Update failed')));

        // act
        final result = await viewModel.saveCar();

        // assert
        expect(result, false);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, 'Update failed');
      });
    });

    group('deleteCurrentCar', () {
      test('should return false when not editing', () async {
        // act
        final result = await viewModel.deleteCurrentCar();

        // assert
        expect(result, false);
        verifyNever(mockDeleteCar(any));
      });

      test('should delete car successfully when editing', () async {
        // arrange
        viewModel.initializeWithCar(tCar);
        when(mockDeleteCar(any))
            .thenAnswer((_) async => const Right(null));

        // act
        final result = await viewModel.deleteCurrentCar();

        // assert
        expect(result, true);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, null);
        verify(mockDeleteCar(1));
      });

      test('should return false and set error when delete fails', () async {
        // arrange
        viewModel.initializeWithCar(tCar);
        when(mockDeleteCar(any))
            .thenAnswer((_) async => const Left(CacheFailure('Delete failed')));

        // act
        final result = await viewModel.deleteCurrentCar();

        // assert
        expect(result, false);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, 'Delete failed');
      });
    });

    group('pickImage', () {
      test('should pick image from gallery successfully', () async {
        // arrange
        when(mockPickImage.fromGallery())
            .thenAnswer((_) async => Right(tPhotoBytes));

        // act
        await viewModel.pickImageFromGallery();

        // assert
        expect(viewModel.photoBytes, tPhotoBytes);
        expect(viewModel.errorMessage, null);
        verify(mockPickImage.fromGallery());
      });

      test('should set error when pick image from gallery fails', () async {
        // arrange
        when(mockPickImage.fromGallery())
            .thenAnswer((_) async => const Left(ImageProcessingFailure('Pick failed')));

        // act
        await viewModel.pickImageFromGallery();

        // assert
        expect(viewModel.photoBytes, null);
        expect(viewModel.errorMessage, 'Pick failed');
      });

      test('should pick image from camera successfully', () async {
        // arrange
        when(mockPickImage.fromCamera())
            .thenAnswer((_) async => Right(tPhotoBytes));

        // act
        await viewModel.pickImageFromCamera();

        // assert
        expect(viewModel.photoBytes, tPhotoBytes);
        expect(viewModel.errorMessage, null);
        verify(mockPickImage.fromCamera());
      });

      test('should set error when pick image from camera fails', () async {
        // arrange
        when(mockPickImage.fromCamera())
            .thenAnswer((_) async => const Left(ImageProcessingFailure('Camera failed')));

        // act
        await viewModel.pickImageFromCamera();

        // assert
        expect(viewModel.photoBytes, null);
        expect(viewModel.errorMessage, 'Camera failed');
      });
    });

    group('clearError', () {
      test('should clear error message and notify listeners', () {
        // arrange
        viewModel.initializeWithCar(tCar);
        // Set an error first
        viewModel.pickImageFromCamera(); // This will set an error if we mock it to fail

        var listenerCalled = false;
        viewModel.addListener(() => listenerCalled = true);

        // act
        viewModel.clearError();

        // assert
        expect(viewModel.errorMessage, null);
        expect(listenerCalled, true);
      });
    });
  });
}