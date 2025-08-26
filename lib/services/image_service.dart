import 'dart:typed_data';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/utils/result.dart';
import '../core/utils/image_utils.dart';
import '../core/errors/exceptions.dart';

abstract class ImageService {
  Future<Result<Uint8List>> pickFromGallery();
  Future<Result<Uint8List>> takePhoto();
  Future<Result<bool>> requestPermissions();
}

class ImageServiceImpl implements ImageService {
  final ImagePicker _picker;

  ImageServiceImpl(this._picker);

  @override
  Future<Result<Uint8List>> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (image == null) {
        return const Failure('Aucune image sélectionnée');
      }

      final bytes = await image.readAsBytes();
      final processedBytes = await ImageUtils.processImage(bytes);

      return Success(processedBytes);
    } on FileException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure('Erreur lors de la sélection de l\'image: ${e.toString()}');
    }
  }

  @override
  Future<Result<Uint8List>> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (image == null) {
        return const Failure('Aucune photo prise');
      }

      final bytes = await image.readAsBytes();
      final processedBytes = await ImageUtils.processImage(bytes);

      return Success(processedBytes);
    } on FileException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure('Erreur lors de la prise de photo: ${e.toString()}');
    }
  }

  @override
  Future<Result<bool>> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        // Pour Android 13+, utiliser photos au lieu de storage
        final cameraStatus = await Permission.camera.status;
        final photosStatus = await Permission.photos.status;

        if (!cameraStatus.isGranted) {
          final newCameraStatus = await Permission.camera.request();
          if (!newCameraStatus.isGranted) {
            return const Failure('Permission caméra requise');
          }
        }

        if (!photosStatus.isGranted) {
          final newPhotosStatus = await Permission.photos.request();
          if (!newPhotosStatus.isGranted) {
            return const Failure('Permission photos requise');
          }
        }

        return const Success(true);
      } else if (Platform.isIOS) {
        final cameraStatus = await Permission.camera.status;
        final photosStatus = await Permission.photos.status;

        if (!cameraStatus.isGranted) {
          final newCameraStatus = await Permission.camera.request();
          if (!newCameraStatus.isGranted) {
            return const Failure('Permission caméra requise');
          }
        }

        if (!photosStatus.isGranted) {
          final newPhotosStatus = await Permission.photos.request();
          if (!newPhotosStatus.isGranted) {
            return const Failure('Permission photos requise');
          }
        }

        return const Success(true);
      }

      return const Success(true);
    } catch (e) {
      return const Success(true); // Continuer sans permissions si erreur
    }
  }
}
