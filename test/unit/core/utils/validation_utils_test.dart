import 'package:flutter_test/flutter_test.dart';
import 'package:boitodex/core/utils/validation_utils.dart';

void main() {
  group('ValidationUtils', () {
    group('validateRequired', () {
      test('should return null when value is valid', () {
        final result = ValidationUtils.validateRequired('Valid value', 'Test Field');
        expect(result, isNull);
      });

      test('should return null when value has only spaces but is not empty after trim', () {
        final result = ValidationUtils.validateRequired('  Valid  ', 'Test Field');
        expect(result, isNull);
      });

      test('should return error message when value is null', () {
        final result = ValidationUtils.validateRequired(null, 'Test Field');
        expect(result, equals('Test Field Ce champ est obligatoire'));
      });

      test('should return error message when value is empty', () {
        final result = ValidationUtils.validateRequired('', 'Test Field');
        expect(result, equals('Test Field Ce champ est obligatoire'));
      });

      test('should return error message when value contains only spaces', () {
        final result = ValidationUtils.validateRequired('   ', 'Test Field');
        expect(result, equals('Test Field Ce champ est obligatoire'));
      });
    });

    group('validateMaxLength', () {
      test('should return null when value is null', () {
        final result = ValidationUtils.validateMaxLength(null, 10, 'Test Field');
        expect(result, isNull);
      });

      test('should return null when value is within limit', () {
        final result = ValidationUtils.validateMaxLength('Short', 10, 'Test Field');
        expect(result, isNull);
      });

      test('should return null when value equals limit', () {
        final result = ValidationUtils.validateMaxLength('1234567890', 10, 'Test Field');
        expect(result, isNull);
      });

      test('should return error when value exceeds limit', () {
        final result = ValidationUtils.validateMaxLength('This is too long', 10, 'Test Field');
        expect(result, equals('Test Field Limite de caractères dépassée (10)'));
      });

      test('should consider trimmed length', () {
        final result = ValidationUtils.validateMaxLength('  12345678901  ', 10, 'Test Field');
        expect(result, equals('Test Field Limite de caractères dépassée (10)'));
      });

      test('should return null for empty string', () {
        final result = ValidationUtils.validateMaxLength('', 10, 'Test Field');
        expect(result, isNull);
      });
    });
  });
}