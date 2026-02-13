class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException({required this.message, this.code, this.originalError});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({required super.message, super.code, super.originalError});
}

class ValidationException extends AppException {
  ValidationException({
    required super.message,
    super.code,
    super.originalError,
  });
}

class UnauthorizedException extends AppException {
  UnauthorizedException({
    required super.message,
    super.code,
    super.originalError,
  });
}

class ServerException extends AppException {
  ServerException({required super.message, super.code, super.originalError});
}
