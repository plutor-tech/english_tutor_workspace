import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

/* Response onRequest(RequestContext context) {
  // Retrieve the injected Db instance from our middleware
  final db = context.read<Db>();

  if (db.isConnected) {
    return Response.json(
      body: {
        'status': 'success',
        'message': 'Tutor Server is running and connected to MongoDB.',
      },
    );
  } else {
    return Response.json(
      statusCode: 500,
      body: {
        'status': 'error',
        'message': 'Tutor Server is running, but database connection failed.',
      },
    );
  }
}
 */

Future<Response> onRequest(RequestContext context) async {
  // Read the injected MongoDB connection from context
  final db = context.read<Db>();
  //final collection = db.collection('items');

  switch (context.request.method) {
    case HttpMethod.get:
      print('Received GET request');
      return _handleGet(db/* , collection */);
    case HttpMethod.post:
      print('Received POST request');
      return _handlePost(context, db/* , collection */);
    case HttpMethod.put:
      print('Received PUT request');
      return Response(statusCode: 405, body: 'PUT method not supported');
    case HttpMethod.delete:
      print('Received DELETE request');
      return Response(statusCode: 405, body: 'DELETE method not supported');
    case HttpMethod.patch:
      print('Received PATCH request');
      return Response(statusCode: 405, body: 'PATCH method not supported');
    case HttpMethod.options:
      print('Received OPTIONS request');
      return Response(statusCode: 200, body: 'OPTIONS method received; supported methods are: GET, POST');
    case HttpMethod.head:
      print('Received HEAD request');
      return Response(statusCode: 200, body: 'HEAD method received');
  }
}

// GET: Fetch all documents from the collection
Future<Response> _handleGet(Db db/* , DbCollection collection */) async {
    if (db.isConnected) {
    return Response.json(
      body: {
        'status': 'success',
        'message': 'Get: Tutor Server is up and connected to MongoDB.',
      },
    );
  } else {
    return Response.json(
      statusCode: 500,
      body: {
        'status': 'error',
        'message': 'Get: Tutor Server is up, but failed to connect to MongoDB.',
      },
    );
  }
}

// POST: Extract JSON payload and insert into MongoDB
Future<Response> _handlePost(
  RequestContext context, Db db/* , DbCollection collection */
  ) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    
    if (!body.containsKey('name')) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing required field: name'},
      );
    }

    //final result = await collection.insertOne(body);

    return Response.json(
      statusCode: 201,
      body: {
        'message': 'Document inserted successfully',
        'id': null, //result.id?.toString(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Failed to process request: $e'},
    );
  }
}
