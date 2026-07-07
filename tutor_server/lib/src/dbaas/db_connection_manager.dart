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
  static late String _uname;

  /// MongoDB Atlas connection password
  static late String _pword; // 'uf36hSGyukBRjLWT' Compromised, change!
  /// MongoDB Atlas cluster name.
  static late String _clstr;

  /// MongoDB database name.
  static late String _dname;

  /// MongoDB application name (for connection metadata).
  static late String _aname;

  /// Timeout duration for database connection attempts.
  static const Duration _conTO = Duration(seconds: 10);

  /// Timeout exception error messsage.
  static const _toExcpErrMsg = 'MongoDB authentication handshake timed out';

  static set dbUname(String uname) => _uname = uname;
  static set dbPword(String pword) => _pword = pword;
  static set dbClstr(String clstr) => _clstr = clstr;
  static set dbDName(String dname) => _dname = dname;
  static set dbAName(String aname) => _aname = aname;

  /// Returns an active instance of the database connection.
  /// Automatically initializes and opens the connection if it doesn't exist.
  static Future<Db> get dbConnection async {
    // Initialize the database connection if it hasn't been established yet.
    if (_db != null && _db!.isConnected) {
      return _db!;
    }
    return _initializeDbConnection();
  }

  /// Initializes and opens the database connection.
  static Future<Db> _initializeDbConnection() async {
    try {
      /// MongoDB connection URI.
      final mongoUri =
          'mongodb+srv://$_uname:$_pword@$_clstr.gfoh4ue.mongodb.net/$_dname?appName=$_aname';

      _db = await Db.create(mongoUri).timeout(
        _conTO,
        onTimeout: () => throw TimeoutException(_toExcpErrMsg),
      );

      await _db!.open().timeout(
        _conTO,
        onTimeout: () {
          _db!.close();
          throw TimeoutException(_toExcpErrMsg);
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
