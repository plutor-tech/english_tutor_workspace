import 'package:dart_frog/dart_frog.dart';
import 'package:tutor_server/src/auth/auth_registrant.dart';

final userReg = UserRegistrant();

Handler middleware(Handler handler) {
  return handler
  .use(attachUserRegistrant());
}

Middleware attachUserRegistrant() {
  return (handler) => (context) async {
    return handler(context.provide<UserRegistrant>(() => userReg));
  };
}
