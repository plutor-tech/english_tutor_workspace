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
      DbConnectionManager.trace.severe(
        'Error initializing database connection: $e.',
        name: '0x07',
      );
      rethrow; // NetworkException('$e'); ??
    }
    try {
      final record = await coll.findOne({'userid': userid});
      if (record != null) {
        return UserProfile(
          userid: record['userid'].toString(),          
          displayname: record['displayname'].toString(),
        );
      } else {
        DbConnectionManager.trace.info(
          'User not found.',
          name: '0x08',
          assoc: userid
        );
        return null;
      }
    } catch (e) {
      DbConnectionManager.trace.error(
        'Error finding user by userid: $e.',
        name: '0x09',
      );
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
      DbConnectionManager.trace.severe(
        'Error initializing database connection: $e.',
        name: '0x0a',
      );
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

        DbConnectionManager.trace.info(
          'New user registered: $newUser.',
          name: '0x0b',
        );
        return true;
      }
    } catch (e) {
      DbConnectionManager.trace.error(
        'DBaaS error inserting user into database: $e',
        name: '0x0c',
      );
      rethrow;
    }
  }  
}
