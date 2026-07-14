import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:tutor_server/src/common.dart';

/// A centralized wrapper for tracking system execution and runtime metrics.
class GlobalTrace {
  /// The name of the Global trace's root Logger
  static const loggerName = 'ETS_GLOBAL';

  /// Emits a structured log entry containing explicit request tracking.
  static void log({
    required String id,
    required Level lvl,
    required String src,
    required String name,
    String? note,
    Map<String, dynamic>? pld,
  }) {
    // Pack tracking data directly into the message or map structures
    final message = {
      'id': id,
      'src': src,
      'name': name,
      'note': note ?? '',
      'pld': pld ?? {},
    };

    // Keeping it try block safe as the logger can be null due to code error.
    try {
      Logger.root.log(lvl, message);
    } catch (e) {
      rethrow;
    }
  }

  /// Convenience helper for DEBUG level logs.
  static void debug(
    String note, {
    required String id,
    required String src,
    required String name,
    Map<String, dynamic>? pld,
  }) {
    info(note, id: id, src: src, name: name, pld: pld);
  }

  /// Convenience helper for INFO level logs.
  static void info(
    String note, {
    required String id,
    required String src,
    required String name,
    Map<String, dynamic>? pld,
  }) {
    log(
      id: id,
      lvl: Level.INFO,
      src: src,
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
    required String name,
    Map<String, dynamic>? pld,
  }) {
    log(
      id: id,
      lvl: Level.SEVERE,
      src: src,
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
    required String name,
    Map<String, dynamic>? pld,
  }) {
    log(
      id: id,
      lvl: Level.WARNING,
      src: src,
      name: name,
      note: note,
      pld: pld,
    );
  }

  /// Initializes application log interceptors.
  static void initRootLogger({
    bool isProduction = false,
    String operationalMode = 'standard',
  }) {
    // Set root logger's log level
    switch (operationalMode) {
      case 'quiet':
        Logger.root.level = Level.SEVERE;
      case 'standard':
        Logger.root.level = Level.SEVERE;
      case 'verbose':
        Logger.root.level = Level.WARNING;
      case 'diagnostic':
        Logger.root.level = Level.ALL;
      default:
        Logger.root.level = Level.SEVERE;
    }

    Logger.root.onLevelChanged.listen((level) {
      stdout.write(
        '[${Logger.root.name}] '
        'CHANGE: The new log level is $level\n'
      );
    });

    Logger.root.onRecord.listen((LogRecord record) {
      // Extract metadata injected from our Trace wrapper class
      final metadata = record.object as Map<String, dynamic>? ?? {};

      final id = metadata['id'] ?? 'SYSTEM_LOG';
      final src = metadata['src'] ?? 'UnknownSource';
      final name = metadata['name'] != null ? '[${metadata['name']}]' : '';
      final pld = metadata['pld'] as Map<String, dynamic>?;
      final message = metadata['note'] ?? record.message;

      if (isProduction) {
        // Production Layout: Structured JSON printed directly to stdout
        final cloudLog = {
          'logger': loggerName,
          'timestamp': record.time.toUtc().toIso8601String(),
          'severity': mapLevelToCloudSeverity(record.level),
          'id': id,
          'src': src,
          'message': '$name:$message',
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
          '[$color${record.level.name}$reset]'
          '[${loggerName.toUpperCase()}] '
          '${record.time.toLocal().toString().split(' ').last} | '
          'id: $id | '
          'src: $src\n'
          '  └─> $name$message'
          '${pld != null ? '\n  └─> Data: ${jsonEncode(pld)}' : ''}',
        );
      }
    });
  }
}
