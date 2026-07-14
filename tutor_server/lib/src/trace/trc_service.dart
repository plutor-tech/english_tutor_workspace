import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:tutor_server/src/common.dart';

/// Flow markers to easily trace execution lifecycles or visualize sequences.
enum ServiceTraceTag {
  /// Entry point of a function or method.
  entry,

  /// Exit point of a function or method.
  exit,

  /// Significant step of a function or method.
  step,

  /// Error point of a function or method.
  error,
}

/// A centralized wrapper for tracking system execution and runtime metrics.
class ServiceTrace {
  /// The service trace Logger instance.
  static late Logger logger;

  /// Emits a structured log entry containing explicit request tracking.
  static void log({
    required String id,
    required Level lvl,
    required String src,
    required ServiceTraceTag tag,
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

    // Keeping it try block safe as the logger can be null due to code error.
    try {
      logger.log(lvl, message);
    } catch (e) {
      rethrow;
    }
  }

  /// Convenience helper for DEBUG level logs.
  static void debug(
    String note, {
    required String id,
    required String src,
    required ServiceTraceTag tag,
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
    required ServiceTraceTag tag,
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
    required ServiceTraceTag tag,
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
    required ServiceTraceTag tag,
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

  /// Initializes application log interceptors.
  static void initLogger({
    bool isProduction = false,
    String operationalMode = 'standard',
  }) {
    // Set log level
    switch (operationalMode) {
      case 'quiet':
        logger.level = Level.SEVERE;
      case 'standard':
        logger.level = isProduction ? Level.WARNING : Level.INFO;
      case 'verbose':
        logger.level = Level.INFO;
      case 'diagnostic':
        logger.level = Level.ALL;
      default:
        logger.level = isProduction ? Level.WARNING : Level.INFO;
    }

    logger.onLevelChanged.listen((level) {
      stdout.write('[${logger.name}] CHANGE: The new log level is $level\n');
    });

    logger.onRecord.listen((LogRecord record) {
      // Extract metadata injected from our Trace wrapper class
      final metadata = record.object as Map<String, dynamic>? ?? {};

      final id = metadata['id'] ?? 'SYSTEM_LOG';
      final src = metadata['src'] ?? 'UnknownSource';
      final tag = metadata['tag'] != null ? '[${metadata['tag']}] ' : '';
      final name = metadata['name'] != null ? '[${metadata['name']}]' : '';
      final pld = metadata['pld'] as Map<String, dynamic>?;
      final message = metadata['note'] ?? record.message;

      if (isProduction) {
        // Production Layout: Structured JSON printed directly to stdout
        final cloudLog = {
          'logger': logger.name,
          'timestamp': record.time.toUtc().toIso8601String(),
          'severity': mapLevelToCloudSeverity(record.level),
          'id': id,
          'src': src,
          'message': '$name:$tag:$message',
          if (pld != null) 'payload': pld,
        };

        /// NOTE: In production, we are writing logs to stdout. In a real-world
        /// scenario, these logs would be captured by a logging agent and sent
        /// to a centralized logging system (like Google Cloud Logging, AWS
        /// CloudWatch, etc.) for further analysis and monitoring.
        if (record.level > Level.INFO) {
          stderr.write(jsonEncode(cloudLog));
        } else {
          stdout.write(jsonEncode(cloudLog));
        }
      } else {
        // Development Layout: Human-scannable colorized console blocks
        final color = getConsoleColor(record.level);
        const reset = '\x1B[0m';

        stdout.writeln(
          '[$color${record.level.name}$reset][${logger.name.toUpperCase()}] '
          '${record.time.toLocal().toString().split(' ').last} | '
          'id: $id | '
          'src: $src\n'
          '  └─> $name$tag$message'
          '${pld != null ? '\n  └─> Data: ${jsonEncode(pld)}' : ''}',
        );
      }
    });
  }
}
