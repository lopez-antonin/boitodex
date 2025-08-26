import 'dart:typed_data';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

class ImageUtils {
  static Future<Uint8List> processImage(Uint8List imageBytes) async {
    try {
      // Vérifier la taille du fichier
      if (imageBytes.lengthInBytes > AppConstants.maxImageSizeBytes) {
        throw const FileException('Image trop volumineuse. Taille maximale: 5MB');
      }

      // Décoder l'image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const FileException('Format d\'image non supporté');
      }

      // Redimensionner si nécessaire
      final resized = _resizeImage(image);

      // Encoder en JPEG avec compression
      final processed = img.encodeJpg(resized, quality: AppConstants.imageQuality);

      return Uint8List.fromList(processed);
    } catch (e) {
      if (e is FileException) rethrow;
      throw FileException('Erreur lors du traitement de l\'image: ${e.toString()}');
    }
  }

  static img.Image _resizeImage(img.Image image) {
    final maxWidth = AppConstants.maxImageWidth;
    final maxHeight = AppConstants.maxImageHeight;

    if (image.width <= maxWidth && image.height <= maxHeight) {
      return image;
    }

    final aspectRatio = image.width / image.height;
    int newWidth, newHeight;

    if (aspectRatio > 1) {
      // Landscape
      newWidth = math.min(maxWidth, image.width);
      newHeight = (newWidth / aspectRatio).round();
    } else {
      // Portrait
      newHeight = math.min(maxHeight, image.height);
      newWidth = (newHeight * aspectRatio).round();
    }

    return img.copyResize(image, width: newWidth, height: newHeight);
  }

  static String getImageSizeText(Uint8List? imageBytes) {
    if (imageBytes == null) return 'Aucune image';

    final sizeInMB = imageBytes.lengthInBytes / (1024 * 1024);
    if (sizeInMB < 1) {
      final sizeInKB = imageBytes.lengthInBytes / 1024;
      return '${sizeInKB.toStringAsFixed(0)} KB';
    }
    return '${sizeInMB.toStringAsFixed(1)} MB';
  }
}