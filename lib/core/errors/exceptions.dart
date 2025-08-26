abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message';
}

class DatabaseException extends AppException {
  const DatabaseException(String message, [String? code]) : super(message, code);
}

class FileException extends AppException {
  const FileException(String message, [String? code]) : super(message, code);
}

class ValidationException extends AppException {
  const ValidationException(String message, [String? code]) : super(message, code);
}

class PermissionException extends AppException {
  const PermissionException(String message, [String? code]) : super(message, code);
}