import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) {
  final method = context.request.method;
  final userid = context.read<String>();

  /// DEBUG: Log the incoming request method for debugging purposes
  stdout.writeln(
    'U_Reqs: Received ${method.toString().toUpperCase()} '
    'request from user with ID: $userid.'
  );

  return switch (method) {
    HttpMethod.get => _handleGet(context),
    HttpMethod.post => _handlePost(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _handleGet(RequestContext context) async {
  return Response.json(body: {'status': 'All good.'});
}

Future<Response> _handlePost(RequestContext context) async {
  final task = await context.request.body();
  return Response.json(body: {'recorded_task': task});
}
