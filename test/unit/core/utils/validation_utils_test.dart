import 'package:flutter_test/flutter_test.dart';
import 'package:boitodex/core/utils/validation_utils.dart';
import 'package:boitodex/app/constants/strings.dart';

void main() {
  group('ValidationUtils', () {
    group('validateRequired', () {
      test('should return null when value is valid', () {
        // arrange
        const value = 'Valid text';
        const fieldName = 'Test Field';

        // act
        final result = ValidationUtils.validateRequired(value, fieldName);

        // assert
        expect(result, null);
      });

      test('should return error message when value is null', () {
        // arrange
        const String? value = null;
        const fieldName = 'Test Field';

        // act
        final result = ValidationUtils.validateRequired(value, fieldName);

        // assert
        expect(result, '$fieldName ${AppStrings.fieldRequired}');
      });

      test('should return error message when value is empty', () {
        // arrange
        const value = '';
        const fieldName = 'Test Field';

        // act
        final result = ValidationUtils.validateRequired(value, fieldName);

        // assert
        expect(result, '$fieldName ${AppStrings.fieldRequired}');
      });

      test('should return error message when value is only whitespace', () {
        // arrange
        const value = '   ';
        const fieldName = 'Test Field';

        // act
        final result = ValidationUtils.validateRequired(value, fieldName);

        // assert
        expect(result, '$fieldName ${AppStrings.fieldRequired}');
      });
    });

    group('validateMaxLength', () {
      test('should return null when value is within max length', () {
        // arrange
        const value = 'Short text';
        const maxLength = 50;
        const fieldName = 'Test Field';

        // act
        final result = ValidationUtils.validateMaxLength(value, maxLength, fieldName);

        // assert
        expect(result, null);
      });

      test('should return null when value is null', () {
        // arrange
        const String? value = null;
        const maxLength = 50;
        const fieldName = 'Test Field';

        // act
        final result = ValidationUtils.validateMaxLength(value, maxLength, fieldName);

        // assert
        expect(result, null);
      });

      test('should return error message when value exceeds max length', () {
        // arrange
        const value = 'This is a very long text that exceeds the maximum allowed length';
        const maxLength = 20;
        const fieldName = 'Test Field';

        // act
        final result = ValidationUtils.validateMaxLength(value, maxLength, fieldName);

        // assert
        expect(result, '$fieldName ${AppStrings.maxLengthExceeded} ($maxLength)');
      });

      test('should return null when value equals max length after trimming', () {
        // arrange
        const value = '12345678901234567890'; // exactly 20 chars
        const maxLength = 20;
        const fieldName = 'Test Field';

        // act
        final result = ValidationUtils.validateMaxLength(value, maxLength, fieldName);

        // assert
        expect(result, null);
      });
    });
  });
}