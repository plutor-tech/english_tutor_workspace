import 'package:dart_frog/dart_frog.dart';
import 'package:tutor_server/src/auth/auth_authenticator.dart';

const fName = 'routes/usr/_middleware.dart';
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
