import 'dart:async';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:tutor_server/src/trace/trc_comp.dart';

/// Manages the application's connection to the MongoDB database instance.
class DbConnectionManager {
  /// Private static variable to hold the active database connection instance.
  static Db? _db;

  /// MongoDB Atlas connection username.
  static late String uname;

  /// MongoDB Atlas connection password
  static late String pword;

  /// MongoDB Atlas cluster name.
  static late String clstr;

  /// MongoDB database name.
  static late String dname;

  /// MongoDB application name (for connection metadata).
  static late String aname;

  /// Timeout duration for database connection attempts.
  static const Duration _conTO = Duration(seconds: 10);

  /// Timeout exception error messsage.
  static const String _conTOMsg = 'MongoDB authentication handshake timed out';

  /// Component logger for logging database connection related events.
  static final ComponentTrace trace = ComponentTrace();

  /// Returns an active instance of the database connection.
  /// Automatically initializes and opens the connection if it doesn't exist.
  static Future<Db> get dbConnection async {
    // Initialize the database connection if it hasn't been established yet.
    if (_db != null && _db!.isConnected) {
      return _db!;
    }
    return _initDbConnection();
  }

  /// Initializes and opens the database connection.
  static Future<Db> _initDbConnection() async {
    try {
      /// MongoDB connection URI.
      final mongoUri =
          'mongodb+srv://$uname:$pword@$clstr.gfoh4ue.mongodb.net/$dname?appName=$aname';

      _db = await Db.create(mongoUri).timeout(
        _conTO,
        onTimeout: () {
          trace.severe(
            'Time-out error in establishing database connection.',
            name: '0x01',
          );
          throw TimeoutException(_conTOMsg);
        },
      );

      await _db!.open().timeout(
        _conTO,
        onTimeout: () {
          trace.severe(
            'Time-out error in opening database connection.',
            name: '0x02',
          );
          _db!.close();
          throw TimeoutException(_conTOMsg);
        },
      );
      trace.info(
        'Database connection is established successfully.',
        name: '0x03',
      );
      return _db!;
    } catch (e) {
      trace.severe(
        'Attempt in establishing database connection failed.',
        name: '0x04',
      );
      rethrow;
    }
  }

  /// Closes the active database connection if it exists.
  static Future<void> closeConnection() async {
    if (_db != null && _db!.state == State.open) {
      try {
        await _db!.close();
        _db = null;
        trace.info('Database connection closed successfully.', name: '0x05');
      } catch (e) {
        trace.error('Error closing database connection: $e', name: '0x06');
      }
    }
  }
}
