import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:tutor_server/authenticator.dart';

Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;

  /// DEBUG: Log the incoming request method for debugging purposes
  stdout.writeln('U_Auth: Received ${method.toString().toUpperCase()} request');

  return switch (method) {
    HttpMethod.post => _handlePost(context),
    _ => Future.value(
      Response(
        statusCode: HttpStatus.methodNotAllowed,
        body: 'Method not allowed',
      ),
    ),
  };
}

/// Handle POST request for user sign-in
Future<Response> _handlePost(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;

  if ((!body.containsKey('username')) || (!body.containsKey('password'))) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Missing required fields: username and password'},
    );
  }

  try {
    final username = body['username'] as String?;
    final password = body['password'] as String?;

    if (username == null || password == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Fields username and password cannot be null'},
      );
    }

    final uauth = context.read<UserAuthenticator>();
    final userid = await uauth.authenticateUser(
      username: username,
      password: password,
    );

    if (userid != null) {
      // TO-DO: Implement proper logging.
      stdout.writeln('User $userid successfully authenticated.');
      return Response.json(
        body: {
          'token': uauth.generateToken(userid: userid),
          'expiry': uauth.tokenExpiry,
        },
      );
    } else {
      // TO-DO: Implement proper logging.
      stdout.writeln('Failed to authecticate the user $userid.');
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'error: Failed to authecticate the user.'},
      );
    }
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to serve the request.'},
    );
  }
}
