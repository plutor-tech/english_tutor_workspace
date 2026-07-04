import 'package:logging/logging.dart';

/// Flow markers to easily trace execution lifecycles or visualize sequences.
enum TraceTag {
  entry,
  exit,
  step,
  error,
}

/// A centralized wrapper for tracking system execution and runtime metrics.
class Trace {
  static final Logger _logger = Logger('EnglishTutorServer');

  /// Emits a structured log entry containing explicit request tracking.
  static void log({
    required String id,
    required Level lvl,
    required String src,
    required TraceTag tag,
    required String name,
    String? note,
    Map<String, dynamic>? pld,
  }) {
    // Pack tracking data directly into the message or map structures
    final message = {
      'id': id,
      'src': src,
      'tag': tag.name.toUpperCase(),
      'name': name,
      'note': note ?? '',
      'pld': pld ?? {},
    };

    /// Forward to package:logging framework via the standard Object field
    /// TO-DO: "as Zone" pasr was introduced by me, but do I need to have a 
    /// Zone created for logger? How does logger expect to work with Zone?
    _logger.log(lvl, message);
  }

    /// Convenience helper for DEBUG level logs.
  static void debug (
    String note, {
    required String id,
    required String src,
    required TraceTag tag,
    required String name,
    Map<String, dynamic>? pld,
  }) {
    info(note, id: id, src: src, tag: tag, name: name, pld: pld);
  }

  /// Convenience helper for INFO level logs.
  static void info(
    String note, {
    required String id,
    required String src,
    required TraceTag tag,
    required String name,
    Map<String, dynamic>? pld,
  }) {
    log(
      id: id,
      lvl: Level.INFO,
      src: src,
      tag: tag,
      name: name,
      note: note,
      pld: pld,
    );
  }

    /// Convenience helper for SEVERE level logs.
  static void severe(
    String note, {
    required String id,
    required String src,
    required TraceTag tag,
    required String name,
    Map<String, dynamic>? pld,
  }) {
    log(
      id: id,
      lvl: Level.SEVERE,
      src: src,
      tag: tag,
      name: name,
      note: note,
      pld: pld,
    );
  }

  /// Convenience helper for ERROR level logs.
  static void error(
    String note, {
    required String id,
    required String src,
    required TraceTag tag,
    required String name,
    Map<String, dynamic>? pld,
  }) {
    log(
      id: id,
      lvl: Level.WARNING,
      src: src,
      tag: tag,
      name: name,
      note: note,
      pld: pld,
    );
  }
}
