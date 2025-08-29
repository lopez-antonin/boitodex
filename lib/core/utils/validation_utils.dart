import '../../app/constants/strings.dart';

class ValidationUtils {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName ${AppStrings.fieldRequired}';
    }
    return null;
  }

  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.trim().length > maxLength) {
      return '$fieldName ${AppStrings.maxLengthExceeded} ($maxLength)';
    }
    return null;
  }
}