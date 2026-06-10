import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:tutor_server/dbaas/db_connection_manager.dart';

Handler middleware(Handler handler) {
  return handler
  .use(attachDb());
}

Middleware attachDb() {
  return (handler) => (context) async {
    final db = await DbConnectionManager.dbConnection;
    return handler(context.provide<Db>(() => db));
  };
}

/* Handler middleware(Handler innerHandler) {
  return (context) async {
    /// ## PRE-PROCESSING THE REQUEST:
    /// Sanity Check: Can examine headers, query params, or bodies before the 
    /// request hits the code.
    /// 
    /// Dependency Injection: Making components like database pools, 
    /// environment configurations, or third-party service clients available to 
    /// route handlers via context.provide().
    /// 
    /// Authentication & Authorization: Can verify JWT tokens or API keys for
    /// user permissions in incoming request headers and reject unauthorized 
    /// requests with a 401 Unauthorized status before they reach the route 
    /// handlers.
    /// 
    /// Logging & Monitoring: Can log incoming requests, their metadata, and
    /// performance metrics for monitoring and debugging purposes.
    /// 
    /// CORS Management: Can attach cross-origin resource sharing headers to 
    /// responses so web frontends can securely communicate with your server 
    /// API.

    // 1. Get or establish the active database connection
    final db = await DatabaseManager.database;

    // 2. Inject the Db instance into the context pipeline
    final contextWithDb = context.provide<Db>(() => db);

    // ## FORWARDING THE REQUEST:
    // 3. Forward the request to the route handlers
    final response = await innerHandler(contextWithDb);

    /// ## POST-PROCESSING THE REQUEST:
    /// Security: Can modify the returned Response (like adding security 
    /// headers) before returning it to the user.

    // none for now.

    return response;
  };
} */
