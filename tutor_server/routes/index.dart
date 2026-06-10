import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => Response.json(
      body: 'The English Tutor Server is up and running.',
    ),
    _ => Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: 'Method not allowed',
    ),
  };
}
