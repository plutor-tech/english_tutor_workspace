import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:tutor_server/src/dbaas/db_connection_manager.dart';
import 'package:tutor_server/src/trace/logger.dart';
import 'package:tutor_server/src/trace/trace.dart';

const fName = 'main.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  const fnSignature = '$fName:run';
  const id = 'INIT';

  // Determine environment
  final isProductionEnv = Platform.environment['NODE_ENV'] == 'production';

  /// 1. INITIALIZE LOGGING AND DATABASE

  await logSetup(isProductionEnv: isProductionEnv);
  Trace.info(
    'Logging system initialized successfully.',
    id: id,
    src: fnSignature,
    tag: TraceTag.step,
    name: 'x00',
  );
  Trace.info(
    isProductionEnv
        ? 'Server is starting in Production environment.'
        : 'Server is starting in Development environment.',
    id: id,
    src: fnSignature,
    tag: TraceTag.step,
    name: 'x01',
  );

  if (await dbSetup(isProductionEnv: isProductionEnv)) {
    Trace.info(
      'Database system initialized successfully.',
      id: id,
      src: fnSignature,
      tag: TraceTag.step,
      name: 'x02',
    );
  } else {
    Trace.severe(
      'Database system initialization failed.',
      id: id,
      src: fnSignature,
      tag: TraceTag.error,
      name: 'x03',
    );
  }

  /// 2. START THE SERVER
  
  try {
    Trace.info(
      'Starting the server on $ip:$port.',
      id: id,
      src: fnSignature,
      tag: TraceTag.step,
      name: 'x04',
    );
    return serve(handler, ip, port);
  } catch (e) {
    Trace.severe(
      'Server startup failed with error: $e',
      id: id,
      src: fnSignature,
      tag: TraceTag.error,
      name: 'x05',
    );

    rethrow;
  }
}

Future<bool> logSetup({required bool isProductionEnv}) async {
  // Instantiation of streaming trace interceptors
  initLogger(isProduction: isProductionEnv);
  return true;
}

Future<bool> dbSetup({required bool isProductionEnv}) async {
  try {
    if (isProductionEnv) {
      DbConnectionManager.dbUname = Platform.environment['DB_UNAME'] ?? '';
      DbConnectionManager.dbPword = Platform.environment['DB_PWORD'] ?? '';
      DbConnectionManager.dbClstr = Platform.environment['DB_CLSTR'] ?? '';
      DbConnectionManager.dbDName = Platform.environment['DB_DNAME'] ?? '';
      DbConnectionManager.dbAName = Platform.environment['WS_ANAME'] ?? '';
    } else {
      final env = DotEnv(includePlatformEnvironment: true)..load();

      DbConnectionManager.dbUname = env['DB_UNAME'] ?? '';
      DbConnectionManager.dbPword = env['DB_PWORD'] ?? '';
      DbConnectionManager.dbClstr = env['DB_CLSTR'] ?? '';
      DbConnectionManager.dbDName = env['DB_DNAME'] ?? '';
      DbConnectionManager.dbAName = env['WS_ANAME'] ?? '';
    }

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
