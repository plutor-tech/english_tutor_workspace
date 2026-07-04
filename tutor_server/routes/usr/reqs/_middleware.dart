import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:tutor_server/src/authenticator.dart';

Handler middleware(Handler handler) {
  return handler
  .use(bearerAuthentication<String>(
      authenticator: (context, token) async {
        final uauth = context.read<UserAuthenticator>();
        return uauth.verifyToken(token);
      },
    ),
  );
}
