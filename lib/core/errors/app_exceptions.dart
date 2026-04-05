/// Base class for all application-level exceptions.
///
/// Every custom exception carries a user-friendly [message] that can be
/// displayed directly in error widgets without further transformation.
sealed class AppException implements Exception {
  final String message;
  final String? details;

  const AppException(this.message, {this.details});

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a network request fails (timeout, no connection, etc.).
class NetworkException extends AppException {
  const NetworkException([
    super.message =
        'Network error. Please check your connection and try again.',
  ]);
}

/// Thrown when the server responds with an error status code.
class ServerException extends AppException {
  final int? statusCode;

  const ServerException([
    super.message = 'Something went wrong on our end. Please try again later.',
    this.statusCode,
  ]);
}

/// Thrown when reading from or writing to the local cache fails.
class CacheException extends AppException {
  const CacheException([
    super.message =
        'Could not load cached data. Please connect to the internet.',
  ]);
}
