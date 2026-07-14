import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:tutor_server/src/auth/auth_registrant.dart';
import 'package:tutor_server/src/common.dart';
import 'package:tutor_server/src/trace/trc_service.dart';

const fName = 'routes/usr/auth/register_native.dart';

Future<Response> onRequest(RequestContext context) async {
  const fnSign = '$fName:onRequest';
  final method = context.request.method;
  final req = context.read<RequestInfo>();

  ServiceTrace.debug( //DEBUG
    'Received user registration endpoint request.',
    id: req.id,
    src: fnSign,
    tag: ServiceTraceTag.entry,
    name: 'x01',
    pld: {
      'method': method.name,
      'headers': context.request.headers.toString(),
    },
  ); 

  return switch (method) {
    HttpMethod.post => await _handlePost(context),
    _ => Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {
        'service_id': req.id,
        'error': '${method.toString().toUpperCase()} method not supported'
      },
    ),
  };
}

/// Handle POST request for user registration
Future<Response> _handlePost(RequestContext context) async {
  const fnSign = '$fName:_handlePost';
  final body = await context.request.json() as Map<String, dynamic>;
  final req = context.read<RequestInfo>();

  ServiceTrace.debug(
    'Processing user registration request.',
    id: req.id,
    src: fnSign,
    tag: ServiceTraceTag.entry,
    name: 'x02',
    pld: {
      'request_body': body,
    },
  );

  if ((!body.containsKey('username')) || (!body.containsKey('password'))) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {
        'service_id': req.id,
        'error': 'Missing required fields: username and password'
      },
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
      ServiceTrace.info(
        'Requested Username conflicts with existing user.',
        id: req.id,
        src: fnSign,
        tag: ServiceTraceTag.exit,
        name: 'x05',
        pld: {
          'username': username,
        },
      );
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {
          'service_id': req.id,
          'error': 'Username already exists.'
        },
      );
    } else {
      ServiceTrace.info(
        'User registered successfully.',
        id: req.id,
        src: fnSign,
        tag: ServiceTraceTag.exit,
        name: 'x03',
        pld: {
          'username': username,
          'user_id': userid,
        },
      );
      return Response.json(
        statusCode: HttpStatus.created,
        body: {
          'service_id': req.id,
          'message': 'User registered successfully',
          'username': username,
        },
      );
    }
  } on ValidationException catch (ve) {
    return Response.json(
      statusCode: HttpStatus.unprocessableEntity,
      body: {
        'service_id': req.id,
        'error': 'Invalid value for ${ve.field}'
      },
    );
  } catch (e) {
    ServiceTrace.error(
      'Error during user registration: $e',
      id: req.id,
      src: fnSign,
      tag: ServiceTraceTag.error,
      name: 'x04',
      pld: {
        'error': e.toString(),
      },
    );
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'service_id': req.id,
        'error': 'Failed to serve the request.'
      },
    );
  }
}
