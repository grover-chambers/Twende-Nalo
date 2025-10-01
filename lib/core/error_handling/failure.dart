import 'package:equatable/equatable.dart';
import 'exceptions.dart';
import 'errors.dart';

/// Base class for all failures in the application
/// Used in the presentation layer to represent errors in a UI-friendly way
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => message;
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.code]);
}

/// Validation failures
class ValidationFailure extends Failure {
  final Map<String, List<String>> fieldErrors;

  const ValidationFailure(super.message, this.fieldErrors, [super.code]);

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Server failures
class ServerFailure extends Failure {
  final int statusCode;

  const ServerFailure(super.message, this.statusCode, [super.code]);

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Database failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.code]);
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, [super.code]);
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, [super.code]);
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message, [super.code]);
}

/// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, [super.code]);
}

/// Failure mapper utility
class FailureMapper {
  /// Maps exceptions to failures
  static Failure fromException(dynamic exception) {
    if (exception is Exception) {
      return _mapExceptionToFailure(exception);
    }
    return UnknownFailure(exception?.toString() ?? 'An unknown error occurred');
  }

  /// Maps errors to failures
  static Failure fromError(dynamic error) {
    if (error is Error) {
      return _mapErrorToFailure(error);
    }
    return UnknownFailure(error?.toString() ?? 'An unknown error occurred');
  }

  static Failure _mapExceptionToFailure(Exception exception) {
    if (exception is NetworkException) {
      return NetworkFailure(exception.toString());
    } else if (exception is AuthException) {
      return AuthFailure(exception.toString());
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message, exception.fieldErrors);
    } else if (exception is ServerException) {
      return ServerFailure(exception.message, exception.statusCode);
    } else if (exception is DatabaseException) {
      return DatabaseFailure(exception.toString());
    } else if (exception is PermissionException) {
      return PermissionFailure(exception.toString());
    } else if (exception is NotFoundException) {
      return NotFoundFailure(exception.toString());
    } else if (exception is TimeoutException) {
      return TimeoutFailure(exception.toString());
    } else {
      return UnknownFailure(exception.toString());
    }
  }

  static Failure _mapErrorToFailure(Error error) {
    if (error is NetworkError) {
      return NetworkFailure(error.toString());
    } else if (error is AuthError) {
      return AuthFailure(error.toString());
    } else if (error is ValidationError) {
      return ValidationFailure(error.toString(), {});
    } else if (error is ServerError) {
      return ServerFailure(error.toString(), 500);
    } else if (error is DatabaseError) {
      return DatabaseFailure(error.toString());
    } else if (error is PermissionError) {
      return PermissionFailure(error.toString());
    } else if (error is NotFoundError) {
      return NotFoundFailure(error.toString());
    } else if (error is TimeoutError) {
      return TimeoutFailure(error.toString());
    } else {
      return UnknownFailure(error.toString());
    }
  }

  /// Creates a user-friendly message for the failure
  static String getUserFriendlyMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Network connection error. Please check your internet connection and try again.';
    } else if (failure is AuthFailure) {
      return 'Authentication failed. Please check your credentials and try again.';
    } else if (failure is ValidationFailure) {
      return 'Please check the provided information and try again.';
    } else if (failure is ServerFailure) {
      final statusCode = failure.statusCode;
      if (statusCode >= 500) {
        return 'Server error. Please try again later.';
      } else if (statusCode >= 400) {
        return 'Invalid request. Please check your input and try again.';
      }
      return 'Server error occurred. Please try again.';
    } else if (failure is DatabaseFailure) {
      return 'Data storage error. Please try again.';
    } else if (failure is PermissionFailure) {
      return 'Permission denied. Please check app permissions.';
    } else if (failure is NotFoundFailure) {
      return 'Requested resource not found.';
    } else if (failure is TimeoutFailure) {
      return 'Request timed out. Please try again.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}
