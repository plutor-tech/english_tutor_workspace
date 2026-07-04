import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:tutor_server/src/common.dart';
import 'package:tutor_server/src/dbaas/db_connection_manager.dart';
import 'package:tutor_shared/tutor_shared.dart';

/// Manages the user registry in the database.
class DbUserRegistryManager {
  /// User registry collection name.
  static const String _collName = 'users_register';

  /// Checks for existing user by username. Returns true if found, else false.
  Future<bool> checkRecordByUsername({
    required String username
  }) async {    
    late final Db db;
    late final DbCollection coll;

    try {
      db = await DbConnectionManager.dbConnection;
      coll = db.collection(_collName);
    } catch (e) {
      // ⚠️ TO-DO: Implement proper logging.
      stdout.writeln('Error initializing database connection: $e');
      throw NetworkException('$e');
    }

    try {
      final record = await coll.findOne({'username': username});
      if (record != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // ⚠️ TO-DO: Implement proper logging.
      stdout.writeln('Database error: $e');
      throw DatabaseException('$e');
    }
  }

  /// Validates a user record by their username and password. Returns the user 
  /// ID if it validates, otherwise returns null.
  Future<String?> validateUsernameAndPassword({
    required String username,
    required String password,
  }) async {
    late final Db db;
    late final DbCollection coll;

    try {
      db = await DbConnectionManager.dbConnection;
      coll = db.collection(_collName);
    } catch (e) {
      // ⚠️ TO-DO: Implement proper logging.
      stdout.writeln('Error initializing database connection: $e');
      throw NetworkException('$e');
    }

    try {
      final user = await coll.findOne({
        'username': username,
        'password': password, // ⚠️ TO-DO: Compare hashed passwords
      });

      if (user != null) {
        return user['userid'] as String;
      } else {
        return null;
      }
    } catch (e) {
      // ⚠️ TO-DO: Implement proper logging.
      stdout.writeln('Database error: $e');
      throw DatabaseException('$e');
    }
  }

  /// Adds a new user record with the given username and password. Returns 
  /// the username of the created user if registration is successful, or null.
  Future<String?> addNewRecord({
    required String username,
    required String password,
  }) async {
    late final Db db;
    late final DbCollection coll;

    try {
      db = await DbConnectionManager.dbConnection;
      coll = db.collection(_collName);
    } catch (e) {
      // ⚠️ TO-DO: Implement proper logging.
      stdout.writeln('Error initializing database connection: $e');
      throw NetworkException('$e');
    }

    try {      
      if (await checkRecordByUsername(username: username)) {
        // Username already exists, registration fails
        return null;
      } else {
        // Create a new user and add it to the in-memory store
        final user = UserLogin(
          userid: DateTime.now().millisecondsSinceEpoch.toString(),
          username: username,
          password: password,
        );
        
        await coll.insertOne({
          'userid': user.userid,
          'username': user.username,
          'password': user.password, // ⚠️ TO-DO: Hash before storing
        });

        stdout.writeln('New user registered: $user'); // DEBUG
        return user.userid;
      }
    } catch (e) {
      // ⚠️ TO-DO: Implement proper logging.
      stdout.writeln('Database error: $e');
      throw DatabaseException('$e');
    }
  }  
}
