import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:boitodex/core/utils/image_utils.dart';

void main() {
  group('ImageUtils', () {
    group('getImageSizeText', () {
      test('should return "Aucune image" when imageBytes is null', () {
        final result = ImageUtils.getImageSizeText(null);
        expect(result, equals('Aucune image'));
      });

      test('should return size in KB when less than 1MB', () {
        final imageBytes = Uint8List(500 * 1024); // 500KB
        final result = ImageUtils.getImageSizeText(imageBytes);
        expect(result, equals('500 KB'));
      });

      test('should return size in MB when 1MB or more', () {
        final imageBytes = Uint8List(2 * 1024 * 1024); // 2MB
        final result = ImageUtils.getImageSizeText(imageBytes);
        expect(result, equals('2.0 MB'));
      });

      test('should return size in MB with one decimal place', () {
        final imageBytes = Uint8List((1.5 * 1024 * 1024).round()); // 1.5MB
        final result = ImageUtils.getImageSizeText(imageBytes);
        expect(result, equals('1.5 MB'));
      });

      test('should handle small sizes correctly', () {
        final imageBytes = Uint8List(100); // 100 bytes
        final result = ImageUtils.getImageSizeText(imageBytes);
        expect(result, equals('0 KB'));
      });
    });

    group('processImage', () {
      test('should return null when image is too large', () async {
        // Create an image larger than maxImageSizeBytes (5MB)
        final largeImageBytes = Uint8List(6 * 1024 * 1024);

        final result = await ImageUtils.processImage(largeImageBytes);
        expect(result, isNull);
      });

      test('should return null when image data is invalid', () async {
        // Create invalid image data
        final invalidImageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        final result = await ImageUtils.processImage(invalidImageBytes);
        expect(result, isNull);
      });

      test('should handle empty image data', () async {
        final emptyImageBytes = Uint8List(0);

        final result = await ImageUtils.processImage(emptyImageBytes);
        expect(result, isNull);
      });
    });
  });
}