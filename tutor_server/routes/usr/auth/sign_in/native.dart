import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:tutor_server/src/auth/auth_authenticator.dart';
import 'package:tutor_server/src/common.dart';
import 'package:tutor_server/src/trace/trc_service.dart';

const fName = 'routes/usr/auth/sign_in/native.dart';

Future<Response> onRequest(RequestContext context) async {
  const fnSignature = '$fName:onRequest';
  final method = context.request.method;
  final req = context.read<RequestInfo>();
  
  ServiceTrace.debug(//DEBUG
    'Received sign-in request',
    id: req.id,
    src: fnSignature,
    tag: ServiceTraceTag.entry,
    name: 'x01',
    pld: {
      'method': method.name,
      'headers': context.request.headers.toString(),
    },
  );

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
  const fnSignature = '$fName:_handlePost';
  final body = await context.request.json() as Map<String, dynamic>;
  final req = context.read<RequestInfo>();

  ServiceTrace.debug(
    'Processing sign-in request.',
    id: req.id,
    src: fnSignature,
    tag: ServiceTraceTag.entry,
    name: 'x02',
    pld: {
      'request_body': body,
    },
  );

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
      ServiceTrace.debug(
        'User $userid successfully authenticated.',
        id: req.id,
        src: fnSignature,
        tag: ServiceTraceTag.exit,
        name: 'x04',
        pld: {
          'username': username,
          'user_id': userid,          
        },
      );
      return Response.json(
        body: {
          'token': uauth.generateToken(userid: userid),
          'expiry': uauth.tokenExpiry,
        },
      );
    } else {
      ServiceTrace.debug(
        'Failed to authenticate the user $userid.',
        id: req.id,
        src: fnSignature,
        tag: ServiceTraceTag.error,
        name: 'x03',
        pld: {
          'username': username,
        },
      );
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'error': 'Failed to authenticate the user.'},
      );
    }
  } catch (e) {
    ServiceTrace.error(
      'Internal error during user authentication: $e',
      id: req.id,
      src: fnSignature,
      tag: ServiceTraceTag.error,
      name: 'x05',
      pld: {
        'error': e.toString(),
      },
    );
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to serve the request.'},
    );
  }
}
