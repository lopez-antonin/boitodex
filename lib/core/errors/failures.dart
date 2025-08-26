abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(String message, [String? code]) : super(message, code);
}

class FileFailure extends Failure {
  const FileFailure(String message, [String? code]) : super(message, code);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message, [String? code]) : super(message, code);
}

class PermissionFailure extends Failure {
  const PermissionFailure(String message, [String? code]) : super(message, code);
}