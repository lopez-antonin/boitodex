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
      // Vérifier les permissions
      final permissionResult = await requestPermissions();
      if (!permissionResult.data!) {
        return const Failure('Permissions requises pour accéder à la galerie');
      }

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
    } on PermissionException catch (e) {
      return Failure(e.message);
    } on FileException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure('Erreur lors de la sélection de l\'image: ${e.toString()}');
    }
  }

  @override
  Future<Result<Uint8List>> takePhoto() async {
    try {
      // Vérifier les permissions
      final permissionResult = await requestPermissions();
      if (!permissionResult.data!) {
        return const Failure('Permissions requises pour utiliser la caméra');
      }

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
    } on PermissionException catch (e) {
      return Failure(e.message);
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
        final cameraStatus = await Permission.camera.request();
        final storageStatus = await Permission.photos.request();

        if (cameraStatus.isGranted && storageStatus.isGranted) {
          return const Success(true);
        } else {
          throw const PermissionException('Permissions caméra et stockage requises');
        }
      } else if (Platform.isIOS) {
        final cameraStatus = await Permission.camera.request();
        final photosStatus = await Permission.photos.request();

        if (cameraStatus.isGranted && photosStatus.isGranted) {
          return const Success(true);
        } else {
          throw const PermissionException('Permissions caméra et photos requises');
        }
      }

      return const Success(true);
    } on PermissionException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure('Erreur lors de la vérification des permissions: ${e.toString()}');
    }
  }
}