import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:tutor_server/src/common.dart';
import 'package:tutor_server/src/trace/trc_service.dart';

// TO-DO: "api/v1" ?? like: "routes.api.v1.usr.reqs.index.dart" ?
const fName = 'routes/usr/reqs/index.dart';


Future<Response> onRequest(RequestContext context) async {
  const fnSign = '$fName:onRequest';
  final method = context.request.method;
  final userid = context.read<String>();
  final req = context.read<RequestInfo>();
  final body = await context.request.body();

  ServiceTrace.debug(
    'Received user preferences access endpoint inquiry.',
    id: req.id,
    src: fnSign,
    tag: ServiceTraceTag.entry,
    name: 'x01',
    pld: {
      'method': method.name,
      'headers': context.request.headers.toString(),
      'user_id': userid,
      'body': body,
    },
  );

  return switch (method) {
    HttpMethod.get => _handleGet(context),
    HttpMethod.post => _handlePost(context),
    _ => Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {
        'service_id': req.id,
        'error': '${method.toString().toUpperCase()} method not supported'
      }
    ),
  };
}

Future<Response> _handleGet(RequestContext context) async {
  final req = context.read<RequestInfo>();
  return Response.json(body: {
    'service_id': req.id,
    'status': 'All good.'
  });
}

Future<Response> _handlePost(RequestContext context) async {
  final req = context.read<RequestInfo>();
  final task = await context.request.body();
  return Response.json(body: {
    'service_id': req.id,
    'recorded_task': task
  });
}
