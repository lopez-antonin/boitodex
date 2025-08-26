class Validators {
  static String? validateRequired(String? value, {String fieldName = 'Ce champ'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est obligatoire';
    }
    return null;
  }

  static String? validateMinLength(String? value, int minLength, {String fieldName = 'Ce champ'}) {
    if (value != null && value.trim().length < minLength) {
      return '$fieldName doit contenir au moins $minLength caractères';
    }
    return null;
  }

  static String? validateMaxLength(String? value, int maxLength, {String fieldName = 'Ce champ'}) {
    if (value != null && value.trim().length > maxLength) {
      return '$fieldName ne peut pas dépasser $maxLength caractères';
    }
    return null;
  }

  static String? validateBrand(String? value) {
    final required = validateRequired(value, fieldName: 'La marque');
    if (required != null) return required;

    return validateMaxLength(value, 50, fieldName: 'La marque');
  }

  static String? validateShape(String? value) {
    final required = validateRequired(value, fieldName: 'La forme');
    if (required != null) return required;

    return validateMaxLength(value, 50, fieldName: 'La forme');
  }

  static String? validateName(String? value) {
    final required = validateRequired(value, fieldName: 'Le nom');
    if (required != null) return required;

    final minLength = validateMinLength(value, 2, fieldName: 'Le nom');
    if (minLength != null) return minLength;

    return validateMaxLength(value, 100, fieldName: 'Le nom');
  }
}