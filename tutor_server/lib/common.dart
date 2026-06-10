/* 
  Shared utility functions and definitions to be used for dbaas classes.
  */

// Exception and Error Handling //

/// Fields defined for validation expception.
enum ValExpField {username, password}

/// Validation Exception.
class ValidationException implements Exception {
  /// Exception constructor
  const ValidationException(this.message, this.field);
  /// Exception message
  final String message;
  /// Exception field
  final ValExpField field;

  @override
  String toString() => 'ValidationException: $message';
}

/// Collision Exception.
class CollisionException implements Exception {
  /// Exception constructor
  const CollisionException(this.message);
  /// Exception message
  final String message;

  @override
  String toString() => 'CollisionException: $message';
}

/// Database Exception
class DatabaseException implements Exception {
  /// Exception constructor
  const DatabaseException(this.message);
  /// Exception message
  final String message;

  @override
  String toString() => 'DatabaseException: $message';
}

/// Network Exception
class NetworkException implements Exception {
  /// Exception constructor
  const NetworkException(this.message);
  /// Exception message
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}
