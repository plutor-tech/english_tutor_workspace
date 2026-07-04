import 'dart:async';
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';

/// Manages the application's connection to the MongoDB database instance.
class DbConnectionManager {
  /// Private static variable to hold the active database connection instance.
  static Db? _db;
  
  /* NOTE: In a production environment, this should be loaded from 
     environment variables. For security reasons, avoid hardcoding sensitive 
     information like database credentials in your source code.
     */
  /// MongoDB Atlas connection username.
  static const String _uname = 'plutoraritra';
  /// MongoDB Atlas connection password
  static const String _pword = 'uf36hSGyukBRjLWT'; //TO-DO: Compromised, change!
  /// MongoDB Atlas cluster name.
  static const String _clustr = 'plutorcluster0';
  /// MongoDB database name.
  static const String _dbName = 'english_tutor_db';
  /// MongoDB application name (for connection metadata).
  static const String _appName = 'EnglishTutorServer';
  /// MongoDB connection URI.
  static const String _mongoUri = 'mongodb+srv://$_uname:$_pword@$_clustr.gfoh4ue.mongodb.net/$_dbName?appName=$_appName';
  /// Timeout duration for database connection attempts.
  static const Duration _connectionTimeout = const Duration(seconds: 10);
  /// Timeout exception error messsage.
  static const _toExcepErrMsg = 'MongoDB authentication handshake timed out';

  /// Returns an active instance of the database connection.
  /// Automatically initializes and opens the connection if it doesn't exist.
  static Future<Db> get dbConnection async {
    // Initialize the database connection if it hasn't been established yet.
    if (_db != null && _db!.isConnected) {
      return _db!;
    }
    return await _initializeDbConnection();
  }

  /// Initializes and opens the database connection.
  static Future<Db> _initializeDbConnection() async {
    try {
      _db = await Db.create(_mongoUri).timeout(
        _connectionTimeout,
        onTimeout: () => throw TimeoutException(_toExcepErrMsg)
      );
      await _db!.open().timeout(
        _connectionTimeout,
        onTimeout: () {
          _db!.close();
          throw TimeoutException(_toExcepErrMsg);
        },
      );
      // ⚠️ TO-DO: Implement proper logging.
      stdout.writeln('SUCCESS Connecting to the database.');
      return _db!;
    } catch (e) {
      // ⚠️ TO-DO: Implement proper logging.
      stderr.writeln('ERROR Connecting to the database: $e.');
      rethrow;
    }
  }

  /// Closes the active database connection if it exists.
  static Future<void> closeConnection() async {
    if (_db != null && _db!.state == State.open) {
      try {
        await _db!.close();
        _db = null;
        // ⚠️ TO-DO: Implement proper logging.
        stdout.writeln('Database connection closed successfully.');
      } catch (e) {
        // ⚠️ TO-DO: Implement proper logging.
        stderr.writeln('Error closing database connection: $e');
      }
    }
  }
}
