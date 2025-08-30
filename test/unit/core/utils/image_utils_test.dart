import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:boitodex/core/utils/image_utils.dart';
import 'package:boitodex/app/constants/dimens.dart';

void main() {
  group('ImageUtils', () {
    group('getImageSizeText', () {
      test('should return "Aucune image" when imageBytes is null', () {
        // act
        final result = ImageUtils.getImageSizeText(null);

        // assert
        expect(result, 'Aucune image');
      });

      test('should return size in KB when image is less than 1MB', () {
        // arrange
        final imageBytes = Uint8List.fromList(List.filled(500 * 1024, 0)); // 500 KB

        // act
        final result = ImageUtils.getImageSizeText(imageBytes);

        // assert
        expect(result, '500 KB');
      });

      test('should return size in MB when image is 1MB or larger', () {
        // arrange
        final imageBytes = Uint8List.fromList(List.filled(2 * 1024 * 1024, 0)); // 2 MB

        // act
        final result = ImageUtils.getImageSizeText(imageBytes);

        // assert
        expect(result, '2.0 MB');
      });

      test('should return size in MB with decimal when image is 1.5MB', () {
        // arrange
        final imageBytes = Uint8List.fromList(List.filled((1.5 * 1024 * 1024).toInt(), 0)); // 1.5 MB

        // act
        final result = ImageUtils.getImageSizeText(imageBytes);

        // assert
        expect(result, '1.5 MB');
      });
    });

    group('processImage', () {
      test('should return null when image is too large', () async {
        // arrange
        final largeImageBytes = Uint8List.fromList(List.filled(AppDimens.maxImageSizeBytes + 1, 0));

        // act
        final result = await ImageUtils.processImage(largeImageBytes);

        // assert
        expect(result, null);
      });

      test('should return null when image bytes is empty', () async {
        // arrange
        final emptyImageBytes = Uint8List.fromList([]);

        // act
        final result = await ImageUtils.processImage(emptyImageBytes);

        // assert
        expect(result, null);
      });

      // Note: Testing actual image processing would require creating valid image data,
      // which is complex for unit tests. Integration tests would be more appropriate
      // for testing the actual image processing functionality.
    });
  });
}