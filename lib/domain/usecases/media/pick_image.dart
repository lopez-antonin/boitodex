import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../features/car_form/data/services/image_service.dart';

class PickImage {
  final ImageService imageService;

  PickImage(this.imageService);

  Future<Either<Failure, Uint8List?>> fromGallery() async {
    try {
      final result = await imageService.pickFromGallery();
      return Right(result);
    } catch (e) {
      return Left(ImageProcessingFailure('Failed to pick image from gallery: $e'));
    }
  }

  Future<Either<Failure, Uint8List?>> fromCamera() async {
    try {
      final result = await imageService.takePhoto();
      return Right(result);
    } catch (e) {
      return Left(ImageProcessingFailure('Failed to take photo: $e'));
    }
  }
}