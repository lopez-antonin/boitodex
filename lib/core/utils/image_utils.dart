import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../app/constants/dimens.dart';

class ImageUtils {
  static Future<Uint8List?> processImage(Uint8List imageBytes) async {
    try {
      if (imageBytes.lengthInBytes > AppDimens.maxImageSizeBytes) {
        return null;
      }

      final image = img.decodeImage(imageBytes);
      if (image == null) return null;

      final resized = _resizeImage(image);
      final processed = img.encodeJpg(resized, quality: AppDimens.imageQuality);
      return Uint8List.fromList(processed);
    } catch (e) {
      return null;
    }
  }

  static img.Image _resizeImage(img.Image image) {
    const maxWidth = AppDimens.maxImageWidth;
    const maxHeight = AppDimens.maxImageHeight;

    if (image.width <= maxWidth && image.height <= maxHeight) {
      return image;
    }

    final aspectRatio = image.width / image.height;
    int newWidth, newHeight;

    if (aspectRatio > 1) {
      newWidth = maxWidth.clamp(0, image.width);
      newHeight = (newWidth / aspectRatio).round();
    } else {
      newHeight = maxHeight.clamp(0, image.height);
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