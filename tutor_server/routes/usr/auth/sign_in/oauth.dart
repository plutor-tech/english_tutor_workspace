import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

/// For Google and other Open Authorization sign in
Response onRequest(RequestContext context) {
  return Response.json(
    statusCode: HttpStatus.methodNotAllowed,
    body: 'Method not allowed',
  );
}
