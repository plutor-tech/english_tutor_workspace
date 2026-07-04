import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:tutor_server/src/dbaas/db_connection_manager.dart';
import 'package:tutor_shared/tutor_shared.dart';

/// Manages user profiles in the database.
class DbUserProfileManager {
  static const String _collName = 'users_profiles';

  /// Checks for existing user record in the database by userid. Returns a 
  /// UserProfile instance if found, otherwise returns null.
  Future<UserProfile?> findRecordByUserId({
    required String userid
  }) async {
    late final Db db;
    late final DbCollection coll;

    try {
      db = await DbConnectionManager.dbConnection;
      coll = db.collection(_collName);
    } catch (e) {
      // ⚠️ TO-DO: Implement proper logging.
      stdout.writeln('Error initializing database connection: $e');
      rethrow;
    }
    try {
      final record = await coll.findOne({'userid': userid});
      if (record != null) {
        return UserProfile(
          userid: record['userid'].toString(),          
          displayname: record['displayname'].toString(),
        );
      } else {
        return null;
      }
    } catch (e) {
      // ⚠️ TO-DO: Implement proper logging.
      stdout.writeln('Error finding user by username: $e');
      rethrow;
    }
  }

    /// Adds a new user record with the given username and password. Returns 
  /// the username of the created user if registration is successful, or null.
  Future<bool?> addNewRecord({
    required String userid,
    required String displayname,
  }) async {
    late final Db db;
    late final DbCollection coll;

    try {
      db = await DbConnectionManager.dbConnection;
      coll = db.collection(_collName);
    } catch (e) {
      // ⚠️ TO-DO: Implement proper logging.
      stdout.writeln('Error initializing database connection: $e');
      rethrow;
    }

    try {      
      if (await findRecordByUserId(userid: userid) != null) {
        throw Exception('User with userid $userid already exists');
      } else {
        // Create a new user and add it to the in-memory store
        final newUser = UserProfile(
          userid: userid,
          displayname: displayname,
        );
        await coll.insertOne({
          'userid': newUser.userid,
          'displayname': newUser.displayname,
        });

        stdout.writeln('New user registered: $newUser'); // DEBUG
        return true;
      }
    } catch (e) {
      // ⚠️ TO-DO: Implement proper logging.
      stdout.writeln('Error inserting user into database: $e'); 
      rethrow;
    }
  }  
}
