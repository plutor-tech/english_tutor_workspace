import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:tutor_server/src/common.dart';
import 'package:tutor_server/src/trace/trace.dart';

// TO-DO: "api/v1" ?? like: "routes.api.v1.usr.reqs.index.dart" ?
const fName = 'routes/usr/reqs/index.dart';


Future<Response> onRequest(RequestContext context) async {
  const fnSignature = '$fName:onRequest';
  final method = context.request.method;
  final userid = context.read<String>();
  final req = context.read<RequestInfo>();
  final body = await context.request.body();

  Trace.debug( //DEBUG
    'Received user preferences access endpoint inquiry.',
    id: req.id,
    src: fnSignature,
    tag: TraceTag.entry,
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
