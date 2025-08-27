import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../core/utils.dart';

/// Service for handling image selection and processing
class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  Future<Uint8List?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (image == null) return null;

      final bytes = await image.readAsBytes();
      return await Utils.processImage(bytes);
    } catch (e) {
      return null;
    }
  }

  /// Take photo with camera
  Future<Uint8List?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (image == null) return null;

      final bytes = await image.readAsBytes();
      return await Utils.processImage(bytes);
    } catch (e) {
      return null;
    }
  }
}