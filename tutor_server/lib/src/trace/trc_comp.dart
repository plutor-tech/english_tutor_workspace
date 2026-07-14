import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:tutor_server/src/common.dart';

/*
 * The Component Trace
 * Uses child logger instances for a component to log it's own trace
 */

/// Manages logging for database connection events and errors.
class ComponentTrace {
  /// Component Logger instance.
  late Logger logger;

  /// Method to log events.
  void log(
    String note, {
    required Level level,
    required String name,
    String? assoc,
    Map<String, dynamic>? pld,
  }) {
    final message = {
      'name': name,
      'note': note,
      'assoc': assoc ?? 'none',
      if (pld != null) 'payload': pld,
    };

    // Keeping it try block safe as the logger can be null due to code error.
    try {
      logger.log(level, message);
    } catch (e) {
      rethrow;
    }
  }


  /// Convenience helper for DEBUG level logs.
  void debug(
    String note, {
    required String name,
    String? assoc,
    Map<String, dynamic>? pld,
  }) {
    info(note, name: name, assoc: assoc, pld: pld);
  }

  /// Convenience helper for INFO level logs.
  void info(
    String note, {
    required String name,
    String? assoc,
    Map<String, dynamic>? pld,
  }) {
    log(note, level: Level.INFO, name: name, assoc: assoc, pld: pld);
  }

  /// Convenience helper for SEVERE level logs.
  void error(
    String note, {
    required String name,
    String? assoc,
    Map<String, dynamic>? pld,
  }) {
    log(note, level: Level.WARNING, name: name, assoc: assoc, pld: pld);
  }

  /// Convenience helper for SEVERE level logs.
  void severe(
    String note, {
    required String name,
    String? assoc,
    Map<String, dynamic>? pld,
  }) {
    log(note, level: Level.SEVERE, name: name, assoc: assoc, pld: pld);
  }

  /// Initializes the logger listener.
  void initLogger({bool isProductionEnv = false}) {
    logger.level = isProductionEnv ? Level.WARNING : Level.INFO;

    logger.onLevelChanged.listen((level) {
      stdout.write('[${logger.name}] CHANGE: The new log level is $level\n');
    });

    logger.onRecord.listen((record) {
      final metadata = record.object as Map<String, dynamic>? ?? {};
      final name = metadata['name'] ?? 'UnknownName';
      final note = metadata['note'] ?? record.message;
      final assoc = metadata['assoc'] ?? 'none';
      final pld = metadata['pld'] as Map<String, dynamic>? ?? {};

      if (isProductionEnv) {
        final cloudLog = {
          'logger': logger.name,
          'timestamp': record.time.toUtc().toIso8601String(),
          'severity': mapLevelToCloudSeverity(record.level),
          'name': name,
          'note': note,
          'assoc': assoc,
          if (pld.isNotEmpty) 'payload': pld,
        };
        
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
          'message: $name $note | '
          'assoc: $assoc'
          '${pld.isNotEmpty ? '\n  └─> Data: ${jsonEncode(pld)}' : ''}',
        );
      }
    });

    /// Log initialization message.
    info('Logger initialized', name: '0x00');
  }
}
