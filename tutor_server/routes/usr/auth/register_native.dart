import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:tutor_server/common.dart';
import 'package:tutor_server/registrant.dart';

Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;

  /// DEBUG: Log the incoming request method for debugging purposes
  stdout.writeln('U_Reg: Received ${method.toString().toUpperCase()} request');

  return switch (method) {
    HttpMethod.post => await _handlePost(context),
    _ => Response(
      statusCode: HttpStatus.methodNotAllowed,
      body: '${method.toString().toUpperCase()} method not supported',
    ),
  };
}

/// Handle POST request for user registration
Future<Response> _handlePost(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;

  if ((!body.containsKey('username')) || (!body.containsKey('password'))) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Missing required fields: username and password'},
    );
  }

  try {
    final ureg = context.read<UserRegistrant>();
    final username = body['username'] as String?;
    final password = body['password'] as String?;

    final userid = await ureg.registerUser(
      username: username,
      password: password,
    );

    if (userid == null) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {'error': 'Username already exists.'},
      );
    } else {
      return Response.json(
        statusCode: HttpStatus.created,
        body: {
          'message': 'User registered successfully',
          'username': username,
        },
      );
    }
  } on ValidationException catch (e) {
    return Response.json(
      statusCode: HttpStatus.unprocessableEntity,
      body: {'error': 'Invalid value for ${e.field}'},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to serve the request.'},
    );
  }
}
