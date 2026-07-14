import 'package:logging/logging.dart';

/* 
  Shared utility functions and definitions to be used for dbaas classes.
  */

// Trace Logging //

/// Flow markers to easily trace execution lifecycles or visualize sequences.
enum TraceTag {
  /// Entry point of a function or method.
  entry,
  /// Exit point of a function or method.
  exit,
  /// Significant step of a function or method.
  step,
  /// Error point of a function or method.
  error,
}

/// Maps logging levels to Google Cloud Logging severity levels.
String mapLevelToCloudSeverity(Level level) {
  if (level >= Level.SEVERE) return 'SEVERE';
  if (level >= Level.WARNING) return 'WARNING';
  if (level >= Level.INFO) return 'INFO';
  return 'DEBUG';
}

/// Maps logging levels to console color codes for development environment.
String getConsoleColor(Level level) {
  if (level >= Level.SEVERE) return '\x1B[31m'; // Red
  if (level >= Level.WARNING) return '\x1B[33m'; // Yellow
  if (level >= Level.INFO) return '\x1B[32m'; // Green
  return '\x1B[36m'; // Cyan
}

/// UUID wrapper class
class RequestInfo {
  /// Constructor
  RequestInfo(this.id);

  /// The uuid string
  String id;
}

// Exception and Error Handling //

/// Fields defined for validation expception.
enum ValExpField {
  /// For Invalid Username Exception
  username,

  /// For Invalid Password Exception
  password,
}

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
