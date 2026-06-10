import 'package:dart_frog/dart_frog.dart';
import 'package:tutor_server/authenticator.dart';

final userAuth = UserAuthenticator();

Handler middleware(Handler handler) {
  return handler
  .use(attachUserAuthenticator());
}

Middleware attachUserAuthenticator() {
  return (handler) => (context) async {
    return handler(context.provide<UserAuthenticator>(() => userAuth));
  };
}
