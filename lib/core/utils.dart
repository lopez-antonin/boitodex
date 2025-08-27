import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'constants/app_constants.dart';

/// Utility functions for the application
class Utils {

  /// Process and resize an image to fit within max dimensions
  static Future<Uint8List?> processImage(Uint8List imageBytes) async {
    try {
      // Check file size
      if (imageBytes.lengthInBytes > AppConstants.maxImageSizeBytes) {
        return null; // Image too large
      }

      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;

      // Resize if necessary
      final resized = _resizeImage(image);

      // Encode as JPEG with compression
      final processed = img.encodeJpg(resized, quality: AppConstants.imageQuality);
      return Uint8List.fromList(processed);
    } catch (e) {
      return null;
    }
  }

  /// Resize image maintaining aspect ratio
  static img.Image _resizeImage(img.Image image) {
    final maxWidth = AppConstants.maxImageWidth;
    final maxHeight = AppConstants.maxImageHeight;

    if (image.width <= maxWidth && image.height <= maxHeight) {
      return image;
    }

    final aspectRatio = image.width / image.height;
    int newWidth, newHeight;

    if (aspectRatio > 1) {
      // Landscape orientation
      newWidth = maxWidth.clamp(0, image.width);
      newHeight = (newWidth / aspectRatio).round();
    } else {
      // Portrait orientation
      newHeight = maxHeight.clamp(0, image.height);
      newWidth = (newHeight * aspectRatio).round();
    }

    return img.copyResize(image, width: newWidth, height: newHeight);
  }

  /// Get human-readable file size
  static String getImageSizeText(Uint8List? imageBytes) {
    if (imageBytes == null) return 'Aucune image';

    final sizeInMB = imageBytes.lengthInBytes / (1024 * 1024);
    if (sizeInMB < 1) {
      final sizeInKB = imageBytes.lengthInBytes / 1024;
      return '${sizeInKB.toStringAsFixed(0)} KB';
    }
    return '${sizeInMB.toStringAsFixed(1)} MB';
  }

  /// Validate required text field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est obligatoire';
    }
    return null;
  }

  /// Validate text field with max length
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.trim().length > maxLength) {
      return '$fieldName ne peut pas dépasser $maxLength caractères';
    }
    return null;
  }
}