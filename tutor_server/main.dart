import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:tutor_server/src/dbaas/db_connection_manager.dart';
import 'package:tutor_server/src/trace/logger.dart';
import 'package:tutor_server/src/trace/trace.dart';

const fName = 'main.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  const fnSignature = '$fName:run';
  const id = 'INIT';

  // 1. ONE-TIME INITIALIZATION
  if (await logSetup()) {
    Trace.info(
      'Logging system initialized successfully.', id: id,
      src: fnSignature, tag: TraceTag.step, name: 'x01',
    );
  }
  if (await dbSetup()) {
    ;
    Trace.info(
      'Database system initialized successfully.', id: id,
      src: fnSignature, tag: TraceTag.step, name: 'x02',
    );
  } else {
    Trace.severe(
      'Database system initialization failed.', id: id,
      src: fnSignature, tag: TraceTag.error, name: 'x03',
    );
  }

  // 2. START THE SERVER
  try {
    Trace.info(
      'Starting the server on $ip:$port.', id: id,
      src: fnSignature, tag: TraceTag.step, name: 'x04',
    );
    return serve(handler, ip, port);
  } catch (e) {
    Trace.severe(
      'Server startup failed with error: $e', id: id,
      src: fnSignature, tag: TraceTag.error, name: 'x05',
    );
    rethrow;
  }
}

Future<bool> logSetup() async {
  // Determine environment targets dynamically
  final isProductionEnv = Platform.environment['NODE_ENV'] == 'production';

  // Instantiate standard streaming trace interceptors once at startup
  initLogger(isProduction: isProductionEnv);
  return true;
}

Future<bool> dbSetup() async {
  try {
    /// Initialize the database connection before starting the server. This
    /// ensures that the server is ready to handle requests immediately after
    /// startup and can fail fast if the database connection cannot be
    /// established.
    await DbConnectionManager.dbConnection;
    return true;
  } catch (e) {
    rethrow;
  }
}
