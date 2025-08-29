import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/image_utils.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

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
      return await ImageUtils.processImage(bytes);
    } catch (e) {
      return null;
    }
  }

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
      return await ImageUtils.processImage(bytes);
    } catch (e) {
      return null;
    }
  }
}