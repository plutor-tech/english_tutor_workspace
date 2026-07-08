import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';

/// Initializes application log interceptors.
void initLogger({
  bool isProduction = false,
  String operationalMode = 'standard',
}) {
  // Set log level
  switch (operationalMode) {
    case 'quiet':
      Logger.root.level = Level.SEVERE;
    case 'standard':
      Logger.root.level = isProduction ? Level.WARNING : Level.INFO;
    case 'verbose':
      Logger.root.level = Level.INFO;
    case 'diagnostic':
      Logger.root.level = Level.ALL;
    default:
      Logger.root.level = isProduction ? Level.WARNING : Level.INFO;
  }

  Logger.root.onLevelChanged.listen((level) {
    stdout.write('LOG LEVEL CHANGE: The new log level is $level\n');
  });

  Logger.root.onRecord.listen((LogRecord record) {
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
        'timestamp': record.time.toUtc().toIso8601String(),
        'severity': _mapLevelToCloudSeverity(record.level),
        'id': id,
        'src': src,
        'message': '$name:$tag:$message',
        if (pld != null) 'payload': pld,
      };
      stdout.write(jsonEncode(cloudLog));
    } else {
      // Development Layout: Human-scannable colorized console blocks
      final color = _getConsoleColor(record.level);
      const reset = '\x1B[0m';

      stdout.write(
        '[$color${record.level.name}$reset] '
        '${record.time.toLocal().toString().split(' ').last} | '
        'id: $id | '
        'src: $src\n'
        '  └─> $name$tag$message'
        '${pld != null ? '\n  └─> Data: ${jsonEncode(pld)}' : ''}',
      );
    }
  });
}

String _mapLevelToCloudSeverity(Level level) {
  if (level >= Level.SEVERE) return 'SEVERE';
  if (level >= Level.WARNING) return 'WARNING';
  if (level >= Level.INFO) return 'INFO';
  return 'DEBUG';
}

String _getConsoleColor(Level level) {
  if (level >= Level.SEVERE) return '\x1B[31m'; // Red
  if (level >= Level.WARNING) return '\x1B[33m'; // Yellow
  if (level >= Level.INFO) return '\x1B[32m'; // Green
  return '\x1B[36m'; // Cyan
}
