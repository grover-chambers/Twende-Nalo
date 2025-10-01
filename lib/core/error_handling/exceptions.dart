/// Base class for all application-specific exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, [this.code, this.details]);

  @override
  String toString() => message;
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code, super.details]);
}

/// Authentication-related exceptions
class AuthException extends AppException {
  const AuthException(super.message, [super.code, super.details]);
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, List<String>> fieldErrors;

  const ValidationException(super.message, this.fieldErrors, [super.code, super.details]);
}

/// Server exceptions
class ServerException extends AppException {
  final int statusCode;

  const ServerException(super.message, this.statusCode, [super.code, super.details]);
}

/// Database exceptions
class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.code, super.details]);
}

/// Permission exceptions
class PermissionException extends AppException {
  const PermissionException(super.message, [super.code, super.details]);
}

/// Not found exceptions
class NotFoundException extends AppException {
  const NotFoundException(super.message, [super.code, super.details]);
}

/// Timeout exceptions
class TimeoutException extends AppException {
  const TimeoutException(super.message, [super.code, super.details]);
}

/// Unknown exceptions
class UnknownException extends AppException {
  const UnknownException(super.message, [super.code, super.details]);
}

/// Exception mapper utility
class ExceptionMapper {
  static AppException fromError(dynamic error) {
    if (error is AppException) {
      return error;
    }
    
    if (error is Exception) {
      return UnknownException(error.toString());
    }
    
    return UnknownException(error?.toString() ?? 'An unknown error occurred');
  }
}
