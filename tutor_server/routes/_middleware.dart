import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:tutor_server/database.dart';

Handler middleware(Handler innerHandler) {
  return (context) async {
    // 1. Get or establish the active database connection
    final db = await DatabaseManager.database;

    // 2. Inject the Db instance into the context pipeline
    final contextWithDb = context.provide<Db>(() => db);

    // 3. Forward the request to the route handlers
    final response = await innerHandler(contextWithDb);
    
    return response;
  };
}
