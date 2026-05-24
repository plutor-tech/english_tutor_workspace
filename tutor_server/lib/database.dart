import 'package:mongo_dart/mongo_dart.dart';

/// Manages the application's connection to the MongoDB database instance.
class DatabaseManager {
  static Db? _db;
  /// MongoDB Atlas username.
  static const String uname = 'plutoraritra';
  /// MongoDB Atlas password
  /// This should be stored securely and not hardcoded.
  static const String pword = 'uf36hSGyukBRjLWT';

  /// Replace with your actual MongoDB Atlas connection string.
  /// Note: In a production environment, this should be loaded from environment
  /// variables.
  static const String mongoUri = 'mongodb+srv://$uname:$pword@plutorcluster0.gfoh4ue.mongodb.net/?appName=PlutorCluster0';

  /// Returns an active instance of the database connection.
  /// Automatically initializes and opens the connection if it doesn't exist.
  static Future<Db> get database async {
    // Initialize the database connection if it hasn't been established yet.
    if (_db != null && _db!.isConnected) {
      return _db!;
    }

    // Replace with your local or MongoDB Atlas connection string
    try {
      _db = await Db.create(mongoUri);
      await _db!.open();
      print('Connecting to the database: SUCCESS');
      return _db!;
    } catch (e) {
      /// TO-DO: Implement proper logging instead of print statements in 
      /// production code.
      print('Error occurred while connecting to the database: $e');
      rethrow;
    }
  }
}
