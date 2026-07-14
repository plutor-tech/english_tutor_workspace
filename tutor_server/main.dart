import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:logging/logging.dart';
import 'package:tutor_server/src/auth/auth_authenticator.dart';
import 'package:tutor_server/src/auth/auth_registrant.dart';
import 'package:tutor_server/src/dbaas/db_connection_manager.dart';
import 'package:tutor_server/src/trace/trc_service.dart';
import 'package:tutor_server/src/trace/trc_system.dart';

const fName = 'main.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  const fnSignature = '$fName:run';
  const id = 'INIT';

  // Determine environment
  final isProductionEnv = Platform.environment['NODE_ENV'] == 'production';
  final operationalMode = Platform.environment['RUN_MODE'] ?? 'standard';

  /// 1. INITIALIZE LOGGING AND DATABASE

  await logSetup(
    isProductionEnv: isProductionEnv,
    operationalMode: operationalMode
  );
  SystemTrace.info(
    'Logging system initialized successfully.',
    id: id,
    src: fnSignature,
    tag: SystemTraceTag.step,
    name: 'x00',
  );
  SystemTrace.info(
    isProductionEnv
        ? 'Server is starting in Production environment.'
        : 'Server is starting in Development environment.',
    id: id,
    src: fnSignature,
    tag: SystemTraceTag.step,
    name: 'x01',
  );

  if (await dbSetup(isProductionEnv: isProductionEnv)) {
    SystemTrace.info(
      'Database system initialized successfully.',
      id: id,
      src: fnSignature,
      tag: SystemTraceTag.step,
      name: 'x02',
    );
  } else {
    SystemTrace.severe(
      'Database system initialization failed.',
      id: id,
      src: fnSignature,
      tag: SystemTraceTag.error,
      name: 'x03',
    );
  }

  /// 2. START THE SERVER
  
  try {
    SystemTrace.info(
      'Starting the server on $ip:$port.',
      id: id,
      src: fnSignature,
      tag: SystemTraceTag.step,
      name: 'x04',
    );
    return serve(handler, ip, port);
  } catch (e) {
    SystemTrace.severe(
      'Server startup failed with error: $e',
      id: id,
      src: fnSignature,
      tag: SystemTraceTag.error,
      name: 'x05',
    );

    rethrow;
  }
}

Future<bool> logSetup({
  required bool isProductionEnv,
  required String operationalMode
  }) async {
  // Enable hierarchical logging for the entire application.
  // hierarchicalLoggingEnabled = true;

  // Instantiation of system trace logger.
  SystemTrace.logger = Logger('ETS_System');
  SystemTrace.initLogger(
    isProduction: isProductionEnv,
    operationalMode: operationalMode
  );

  // Instantiation of service trace logger.
  ServiceTrace.logger = Logger('ETS_Service');
  ServiceTrace.initLogger(
    isProduction: isProductionEnv,
    operationalMode: operationalMode
  );

  // Instantiation of DbCM component trace logger.
  DbConnectionManager.trace.logger = Logger('ETS_DB_Mang');
  DbConnectionManager.trace.initLogger(isProductionEnv: isProductionEnv);

  // Instantiation of AuReg component trace logger.
  UserRegistrant.trace.logger = Logger('ETS_AU_Regt');
  UserRegistrant.trace.initLogger(isProductionEnv: isProductionEnv);

  // Instantiation of Au component trace logger.
  UserAuthenticator.trace.logger = Logger('ETS_AU_Auth');
  UserAuthenticator.trace.initLogger(isProductionEnv: isProductionEnv);

  return true;
}

Future<bool> dbSetup({required bool isProductionEnv}) async {
  try {
    if (isProductionEnv) {
      DbConnectionManager.uname = Platform.environment['DB_UNAME'] ?? '';
      DbConnectionManager.pword = Platform.environment['DB_PWORD'] ?? '';
      DbConnectionManager.clstr = Platform.environment['DB_CLSTR'] ?? '';
      DbConnectionManager.dname = Platform.environment['DB_DNAME'] ?? '';
      DbConnectionManager.aname = Platform.environment['WS_ANAME'] ?? '';
    } else {
      final env = DotEnv(includePlatformEnvironment: true)..load();
      DbConnectionManager.uname = env['DB_UNAME'] ?? '';
      DbConnectionManager.pword = env['DB_PWORD'] ?? '';
      DbConnectionManager.clstr = env['DB_CLSTR'] ?? '';
      DbConnectionManager.dname = env['DB_DNAME'] ?? '';
      DbConnectionManager.aname = env['WS_ANAME'] ?? '';
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
