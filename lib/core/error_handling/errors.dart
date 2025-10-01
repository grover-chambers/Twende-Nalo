/// Base class for all application-specific errors
abstract class AppError {
  final String message;
  final String? code;

  const AppError(this.message, [this.code]);

  @override
  String toString() => message;
}

/// Network-related errors
class NetworkError extends AppError {
  const NetworkError(super.message, [super.code]);
}

/// Authentication-related errors
class AuthError extends AppError {
  const AuthError(super.message, [super.code]);
}

/// Validation errors
class ValidationError extends AppError {
  final Map<String, List<String>> fieldErrors;

  const ValidationError(super.message, this.fieldErrors, [super.code]);
}

/// Server errors
class ServerError extends AppError {
  final int statusCode;

  const ServerError(super.message, this.statusCode, [super.code]);
}

/// Database errors
class DatabaseError extends AppError {
  const DatabaseError(super.message, [super.code]);
}

/// Permission errors
class PermissionError extends AppError {
  const PermissionError(super.message, [super.code]);
}

/// Not found errors
class NotFoundError extends AppError {
  const NotFoundError(super.message, [super.code]);
}

/// Timeout errors
class TimeoutError extends AppError {
  const TimeoutError(super.message, [super.code]);
}

/// Unknown errors
class UnknownError extends AppError {
  const UnknownError(super.message, [super.code]);
}
