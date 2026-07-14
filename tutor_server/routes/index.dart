import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:tutor_server/src/common.dart';
import 'package:tutor_server/src/trace/trc_service.dart';

const fName = 'routes/index.dart';

Future<Response> onRequest(RequestContext context) async {
  const fnSign = '$fName:onRequest';
  final method = context.request.method;
  final req = context.read<RequestInfo>();

  ServiceTrace.debug( //DEBUG
    'Received server root endpoint inquiry.',
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
    HttpMethod.get => Response.json(
      body: 'The English Tutor Server is up and running.',
    ),
    _ => Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: 'Method not allowed',
    ),
  };
}
