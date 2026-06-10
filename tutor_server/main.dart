import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:tutor_server/dbaas/db_connection_manager.dart';
// Import your database service here

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  // 1. ONE-TIME INITIALIZATION
  await dbSetup();

  // 2. START THE SERVER
  return serve(handler, ip, port);
}

Future<void> dbSetup() async {
  try {
    /// Initialize the database connection before starting the server. This 
    /// ensures that the server is ready to handle requests immediately after 
    /// startup and can fail fast if the database connection cannot be 
    /// established.
    await DbConnectionManager.dbConnection;
    // TO-DO: Implement proper logging.
    stdout.writeln('Database connection established successfully.');
  } catch (e) {
    // TO-DO: Implement proper logging.
    stderr.writeln('[STARTUP: CRITICAL ERROR] $e: Database connection failed.');
    rethrow;
  }
}
